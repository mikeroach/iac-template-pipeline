pipeline {
    agent any 
    options {
        skipDefaultCheckout() // Perform this inside the pipeline after forced git-crypt reset.
        skipStagesAfterUnstable()
    }
    environment {
        /* Setting this environment variable allows us to omit a persistent Google Cloud SDK
        configuration and still use those pesky third-party Terraform modules that run gcloud
        helper scripts via local-exec provisioners. */
        CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE = "secrets/project-factory-seed-service-account.json"
    }
    stages {
        stage('Checkout and Unlock Repository'){
            environment {
                GIT_CRYPT_KEY = credentials('GitCrypt_Key_iac-template-pipeline')
            }
            steps {
                // Perform SCM checkout from within pipeline and decrypt repository secret files
                sh label: 'Reset git-crypt status before SCM checkout', script: 'git-crypt lock --force', returnStatus: true
                checkout scm
                sh label: 'Decrypt repository with git-crypt', script: 'git-crypt unlock ${GIT_CRYPT_KEY}'
                sendNotifications 'STARTED'
            }
        }
        stage('Terraform Validation') { // FIXME: Add unit & integration tests.
            steps {
                sh label: 'Run Terraform initialization and validation test suite', script: 'make test'
            }
        }
        stage('Generate Plan') {
            steps {
                sh label: 'Generate Terraform plan', script: 'make plan'
            }
        }
        stage('Build Environment') {
            when {
                branch 'master'
            }
            steps {
                sh label: 'Run Terraform apply', script: 'make environment'
            }
        }
        stage('Integration Tests') {
            when {
                branch 'master'
            }
            steps {
                sleep(time:30, unit:"SECONDS") // Wait 30 seconds for DDNS daemon set to register new address, if applicable.
                sh label: 'Run HTTP check against newly built environment', script: '/usr/lib/nagios/plugins/check_http -H `make -s http-host` -v -u "/"'
            }
        }
        stage('Tag Module Release') {
            when {
                branch 'master'
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'GitHub_Jenkins-GCP', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                    sh label: 'Tag new version of composed infrastructure module', script: '''
                        git config --local user.email "jenkins@borrowingcarbon.net" && git config --local user.name "Jenkins"
                        git config --local credential.helper "!p() { echo username="$GIT_USERNAME" ; echo password="$GIT_PASSWORD" ; }; p"
                        git tag -m "Tagging new module version v${BUILD_NUMBER}" v${BUILD_NUMBER}
                        git push origin v${BUILD_NUMBER}
                    '''
                }
            }
        }
    }
    post {
        always {  // Don't fail the pipeline if something goes wrong with destroying the environment.
            sh label: 'Destroy sample environment', script: 'make destroy', returnStatus: true
        }
        success {
            script {
                if (env.CHANGE_ID) { // Only interact with pull requests if this job was triggered by one
                    /* Because we merge and close the pull request with the GitHub Pipeline plugin during this
                       job's post-success script, the Branch Source plugin can't update the pr-merge status
                       check on GitHub. To solve this we'll set test status from within the post script. */
                    pullRequest.createStatus(status: 'success',
                     context: 'continuous-integration/jenkins/pr-merge',
                     description: 'All tests passed',
                     targetUrl: "${env.BUILD_URL}/display/redirect")

                    // Attempt to auto-merge this PR into master unless the 'no-merge' label exists to indicate otherwise.
                    if (! pullRequest.labels.contains("no-merge")) {
                        echo "No-merge label absent; attempting auto-merge."

                        // Merge and close the PR if conflict-free, otherwise leave it open with a comment.
                        if (pullRequest.mergeable) {
                            pullRequest.comment('[Jenkins] All tests for this PR succeeded, merging and closing.')
                            pullRequest.merge('[Jenkins] Automatically merged by Jenkins.')
                        } else {
                            pullRequest.comment('[Jenkins] All tests for this PR succeeded, but PR is unmergeable. Please investigate.')
                        }
                    } else {
                        echo "No-merge label detected; skipping auto-merge."
                        pullRequest.comment('[Jenkins] All tests for this PR succeeded, skipping merge due to "no-merge" label.')
                    }
                }
            }
        }
        cleanup {
            sh label: 'Remove stray Terraform state files', script: 'rm -f terraform.tfstate terraform.tfstate.backup', returnStatus: true
            sh label: 'Lock repository secret files', script: 'git-crypt lock --force', returnStatus: true
            sendNotifications currentBuild.result
        }
    }
}

// Retrieve changelog for notifications adapted from https://support.cloudbees.com/hc/en-us/articles/217630098-How-to-access-Changelogs-in-a-Pipeline-Job-
def getChangeString() {
 MAX_MSG_LEN = 100
 def changeString = ""

 echo "Gathering SCM changes"
 def changeLogSets = currentBuild.changeSets
 for (int i = 0; i < changeLogSets.size(); i++) {
 def entries = changeLogSets[i].items
 for (int j = 0; j < entries.length; j++) {
 def entry = entries[j]
 truncated_msg = entry.msg.take(MAX_MSG_LEN)
 changeString += " - ${truncated_msg} [${entry.author}]\n"
 }
 }

 if (!changeString) {
 changeString = " - No new changes"
 }
 return changeString
}

// Send Slack notifications adapted from https://jenkins.io/blog/2017/02/15/declarative-notifications/
/* MIT License

Copyright (c) 2017 Liam Newman

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. */
def sendNotifications(String buildStatus = 'STARTED') {
  // build status of null means successful
  buildStatus = buildStatus ?: 'SUCCESS'

  // Default values
  def colorName = 'RED'
  def colorCode = '#FF0000'
  def emoji = ":question:"
  def subject = "${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
  def summary = "${subject} (${env.BUILD_URL})"
    
  // Override default values based on build status
  if (buildStatus == 'STARTED') {
    emoji = ":construction:"
    color = 'YELLOW'
    colorCode = '#FFFF00'
    summary = "${emoji} ${subject} (${env.BUILD_URL})\n " + getChangeString()
  } else if (buildStatus == 'SUCCESS') {
    emoji = ":white_check_mark:"
    color = 'GREEN'
    colorCode = '#00FF00'
    summary = "${emoji} ${subject} (${env.BUILD_URL})"
  } else {
    emoji = ":x:"
    color = 'RED'
    colorCode = '#FF0000'
    summary = "${emoji} ${subject} (${env.BUILD_URL})" 
  }

  // Send notifications
  slackSend (channel: "roachtest", color: colorCode, message: summary)
}