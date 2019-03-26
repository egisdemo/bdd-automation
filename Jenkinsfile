pipeline {
    agent any

    environment {
        DOCKER_PROD_REPO_URL = 'http://nexus.steadystatecd.com:8083'
        DOCKER_PROD_REPO = 'nexus.steadystatecd.com:8083'
        DOCKER_NON_PROD_REPO = 'http://nexus.steadystatecd.com:8083'
        APP_NAME = "flow-api"
      
    }


    tools {
        maven 'Maven' 
         
    }
    options {
      
        timeout(time: 10, unit: 'MINUTES') 
        timestamps() 
        ansiColor('xterm')
        buildDiscarder(logRotator(numToKeepStr: '5'))
        disableConcurrentBuilds()
    }
    
    stages {
        
        stage('Setup') {
      steps {
        script {

             
            def isPR = false
       
            if (env.GIT_BRANCH ==~ /PR-(.+)/) {

                    isPR = true
                    
           
          } 
          
         

         
          env.GIT_CI_SHORT_COMMIT_SHA = getCommitShortSHA()
          env.GIT_CI_LONG_COMMIT_SHA = getCommitSHA()
          env.GIT_CI_CHANGE_ID = env.CHANGE_ID

          env.IS_PR = isPR
         

          echo " Git Short Commit SHA ${env.GIT_CI_SHORT_COMMIT_SHA}" 
          echo " Git Long Commit SHA${env.GIT_CI_LONG_COMMIT_SHA}" 
          echo " Git BranchName ${env.GIT_BRANCH}" 
          echo " Git ChangeID  ${env.GIT_CI_CHANGE_ID}"
          echo " Deploy Target ${env.DEPLOY_TARGET}"
          echo " IS PR Request ${env.IS_PR}"
        
         
         
        }
      }
    }
        stage('Build') {
           
                steps {
                   

                     script {
                       
                         
                        sh 'mvn clean install  -DskipTests=true'

                            
                    }

                }
        }

        stage('Unit Testing') {
            
                steps {

                    script {
                       
                          sh 'mvn test'

                       
                    }

              
                  
                
                }
        }

    
        stage('SonarQube') {
           
                    stages {
                            stage("Analysis") {
                                steps {
                                        
                                    withSonarQubeEnv('EGIS-Sonar') {
                                            sh 'mvn sonar:sonar'
                                        }
                                }
                            }
                            stage("Quality Gate") {
                                steps {
                                timeout(time: 10, unit: 'MINUTES') {
                                    waitForQualityGate abortPipeline: false
                                }
                                 
                                }
                            }
                        }
            
            }


        stage('Fortify Scan') {
          
            steps {

                script {
                       
                        
                        sh 'mvn  dependency-check:check'
                        
                        dependencyCheckPublisher canComputeNew: false, defaultEncoding: '', healthy: '', pattern: '', unHealthy: ''
    
                         
                    }

                
                      }
        }

   

   

      


   

    }

    post { 
        always { 

            script {

                junit allowEmptyResults: true, testResults: 'target/surefire-reports/*.xml'
                         
              
            }
           
       
        }
        failure { 
            echo 'Failed'
        }
        success { 
            echo 'Success!'
        }
        unstable { 
            echo 'Unstable'
        }
         

    }
}


 

def getCommitSHA(refname = 'HEAD') {
  def commit = sh(returnStdout: true, script: "git rev-parse ${refname} 2>/dev/null")
  return commit ? commit.trim() : ''
}

def getCommitShortSHA(refname = 'HEAD') {
  def commit = sh(returnStdout: true, script: "git rev-parse --short ${refname}  2>/dev/null")
  return commit ? commit.trim() : ''
}


def notifyBuild(String buildStatus = 'STARTED') {
     
            buildStatus =  buildStatus ?: 'SUCCESSFUL'

            // Default values
            def colorName = 'RED'
            def colorCode = '#FF0000'
            def subject = "${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
            def summary = "${subject} (${env.BUILD_URL})"

            // Override default values based on build status
            if (buildStatus == 'STARTED') {
              color = 'YELLOW'
              colorCode = '#FFFF00'
            } else if (buildStatus == 'SUCCESSFUL') {
              color = 'GREEN'
              colorCode = '#00FF00'
            } else {
              color = 'RED'
              colorCode = '#FF0000'
            }

            // Send notifications
            slackSend channel: '#cicd_jenkins', color: colorCode, message: summary
            
          }
 