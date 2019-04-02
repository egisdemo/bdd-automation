pipeline {
    agent any

    environment {
        DOCKER_PROD_REPO_URL = 'http://nexus.navitas-labs.com:8083'
        DOCKER_PROD_REPO = 'nexus.navitas-labs.com:8083'
        DOCKER_NON_PROD_REPO = 'http://nexus.navitas-labs.com:8083'
        APP_NAME = "bdd-automation"
        SKIP_STAGE = "false"
        DOCKER_HUB = "https://docker.io"
        ENV_DT_NAMESPACE = "egis-dt"
        ENV_RT_NAMESPACE = "egis-rt"
        ENV_STAGE_NAMESPACE = "egis-stage"
        ENV_PROD_NAMESPACE = "egis-prod"
    
    }


    tools {
        maven 'Maven' 
         
    }
    options {
      
        timeout(time: 10, unit: 'MINUTES') 
 
        ansiColor('xterm')
        buildDiscarder(logRotator(numToKeepStr: '5'))
        disableConcurrentBuilds()
    }
    
    stages {
        
        stage('Setup') {
      steps {
        script {

            def deployTarget=""
            def isPR = false
            def readyForPROD = false
              /* Check the GIT_BRANCH to compute the target environment */
          if (env.GIT_BRANCH ==~ /feature-(.+)/) {
            deployTarget = 'dt'
            project_namespace = 'egis-dt'
          } else if (env.GIT_BRANCH ==~ /release-(.+)/) {
            deployTarget = 'rt'
            project_namespace = 'egis-rt'
          } else if (env.GIT_BRANCH == 'master') {
            deployTarget = 'prod'
            project_namespace = 'egis-prod'
            env.SKIP_STAGE = 'true'
          } else if (env.GIT_BRANCH ==~ /PR-(.+)/) {

                    isPR = true
                    if (env.CHANGE_TARGET ==~ /release-(.+)/) {
                        deployTarget = 'dt'
                        project_namespace = 'egis-dt'
                    } else if ( env.CHANGE_TARGET ==~ /master/){
                        deployTarget = 'stage'
                        project_namespace = 'egis-dt'
                        readyForPROD =  true
                    }
                    else  {

                    }
              
               
          } 
          
          else {
            error "Unknown branch type: ${env.GIT_BRANCH}"
          }
        
         
         
          env.GIT_CI_SHORT_COMMIT_SHA = getCommitShortSHA()
          env.GIT_CI_LONG_COMMIT_SHA = getCommitSHA()
          env.GIT_CI_CHANGE_ID = env.CHANGE_ID
          env.DEPLOY_TARGET= deployTarget
          env.PROJECT_NAME_SPACE = project_namespace
          env.IS_PR = isPR
          env.IS_READY_TO_PROMOTE = readyForPROD

          echo " Git Short Commit SHA ${env.GIT_CI_SHORT_COMMIT_SHA}" 
          echo " Git Long Commit SHA${env.GIT_CI_LONG_COMMIT_SHA}" 
          echo " Git BranchName ${env.GIT_BRANCH}" 
          echo " Git ChangeID  ${env.GIT_CI_CHANGE_ID}"
          echo " Deploy Target ${env.DEPLOY_TARGET}"
          echo " IS PR Request ${env.IS_PR}"
          echo " OC Project Name Space ${env.PROJECT_NAME_SPACE}"
          echo " Ready for PROD  ${env.IS_READY_TO_PROMOTE}"
          echo " Skip Stage  ${env.SKIP_STAGE}"
         
          currentBuild.displayName = "#${BUILD_NUMBER}-${env.GIT_CI_SHORT_COMMIT_SHA}"

        }
      }
    }
        stage('Build') {
            when {
                expression {
                     return env.SKIP_STAGE == 'false';
                }
            }
                steps {
                   

                     script {
                       
                        setPRBuildStatus('continuous-integration/jenkins/Compile', 'Pending', 'PENDING' )
                        
                        sh 'mvn clean install  -DskipTests=true'

                        setPRBuildStatus('continuous-integration/jenkins/Compile', 'Success', 'SUCCESS' )
                        
                    }

                }
        }

        stage('Unit Testing') {
            when {
                expression {
                     return env.SKIP_STAGE == 'false';
                }
            }
                steps {

                    script {
                       
                        setPRBuildStatus('continuous-integration/jenkins/Unit-Testing', 'Pending', 'PENDING' )
                        sh 'mvn test'

                        setPRBuildStatus('continuous-integration/jenkins/Unit-Testing', 'Completed', 'SUCCESS' )
                        
                    }

              
                  
                
                }
        }

    
        stage('SonarQube') {
              when {
                expression {
                     return env.SKIP_STAGE == 'false';
                }
            }
                    stages {
                            stage("Analysis") {
                                steps {
                                    
                                     script {
                       
                                    setPRBuildStatus('continuous-integration/jenkins/SonarQube', 'Pending', 'PENDING' )
                                     }
                                    
                                    withSonarQubeEnv('EGIS-Sonar') {
                                            sh 'mvn sonar:sonar'
                                        }
                                }
                            }
                            stage("Quality Gate") {
                                steps {
                                timeout(time: 1, unit: 'HOURS') {
                                    waitForQualityGate abortPipeline: false
                                }
                                  script {
                                    setPRBuildStatus('continuous-integration/jenkins/SonarQube', 'Success', 'SUCCESS' )
                                     }
                                }
                            }
                        }
            
            }


        stage('Fortify Scan') {
              when {
                expression {
                     return env.SKIP_STAGE == 'false';
                }
            }
            steps {

                script {
                       
                        setPRBuildStatus('continuous-integration/jenkins/OWASP dependency-check', 'Pending', 'PENDING' )
                        
                        sh 'mvn  dependency-check:check'
                        
                        dependencyCheckPublisher canComputeNew: false, defaultEncoding: '', healthy: '', pattern: '', unHealthy: ''
    
                        setPRBuildStatus('continuous-integration/jenkins/OWASP dependency-check', 'Success', 'SUCCESS' )
                        
                    }

                
                      }
        }

        stage('Build Docker') {
              when {
                expression {
                     return env.SKIP_STAGE == 'false';
                }
            }
          
            steps {
                echo 'Starting to build docker image with id ${env.GIT_CI_SHORT_COMMIT_SHA}'

                script {
                    def customImage1 = docker.build("${env.DOCKER_PROD_REPO}/${env.APP_NAME}:${env.GIT_CI_SHORT_COMMIT_SHA}")
                    def customImage2 = docker.build("iotcloudstack/${env.APP_NAME}:${env.GIT_CI_SHORT_COMMIT_SHA}")
                     
                }
            }
        }

   
     stage('Scan Docker Image') {
            steps {

                 withDockerRegistry([ credentialsId: "DOCKER_HUB_CREDENTIALS",url:"https://index.docker.io/v1/" ]) {

                sh "docker push iotcloudstack/${env.APP_NAME}:${env.GIT_CI_SHORT_COMMIT_SHA}"

                }

                script {

                    setPRBuildStatus('continuous-integration/jenkins/Docker-Scan', 'Pending', 'PENDING' )

                   

                    def imageLine = "docker.io/iotcloudstack/${env.APP_NAME}:${env.GIT_CI_SHORT_COMMIT_SHA} ${WORKSPACE}/Dockerfile"
                    writeFile file: 'anchore_images', text: imageLine
                     anchore name: 'anchore_images'
                    setPRBuildStatus('continuous-integration/jenkins/Docker-Scan', 'Success', 'SUCCESS' )
                }

            }
        }


        stage('Push to Repo') {
              when {
                expression {
                     return env.SKIP_STAGE == 'false';
                }
            }
          
            steps {
             //   withDockerRegistry([ credentialsId: "DOCKER_REPO_CREDENTIALS", url: "${env.DOCKER_PROD_REPO_URL}" ]) {

               // sh "docker push ${env.DOCKER_PROD_REPO}/${env.APP_NAME}:${env.GIT_CI_SHORT_COMMIT_SHA}"

               // }

                withDockerRegistry([ credentialsId: "DOCKER_HUB_CREDENTIALS",url:"https://index.docker.io/v1/" ]) {

                sh "docker push iotcloudstack/${env.APP_NAME}:${env.GIT_CI_SHORT_COMMIT_SHA}"

                }
             }
        }

        stage('Deploy') {
              when {
                expression {
                     return env.SKIP_STAGE == 'true';
                }
            }
            steps {
                 script {

            
                            echo "OpenShift Project Target  ${env.PROJECT_NAME_SPACE}"
              
                            
                            withCredentials([string(credentialsId: 'OCP_CLI_TOKEN', variable: 'OC_TOKEN')]) {
                                sh "oc login --server=https://apps.navitas-labs.com --token=${OC_TOKEN}"
                            }

                            sh "oc import-image ${env.APP_NAME}:${env.GIT_CI_SHORT_COMMIT_SHA} --from=docker.io/iotcloudstack/${env.APP_NAME}:${env.GIT_CI_SHORT_COMMIT_SHA} -n ${env.PROJECT_NAME_SPACE} --confirm"

                            openshift.withCluster( 'EGIS-Cluster' ) {

                                def template = openshift.withProject( "${env.PROJECT_NAME_SPACE }" ) {
                                            // Find the named template and unmarshal into a Groovy object
                                            openshift.selector('template','egis-microservices-api').object()
                                       
                                }
                                        // Explore the template model
                                 echo "Template contains ${template.parameters.size()} parameters"
 
                                 openshift.withProject( "${env.PROJECT_NAME_SPACE }" ) {

                                 openshift.create(openshift.process( template
                                                             , "-p",  "APP_NAME=${env.APP_NAME}-${env.GIT_CI_SHORT_COMMIT_SHA}"
                                                             , "-p", "IMAGE_NAME=docker-registry.default.svc:5000/${env.PROJECT_NAME_SPACE }/${env.APP_NAME}"
                                                             , "-p", "IMAGE_TAG=${env.GIT_CI_SHORT_COMMIT_SHA}"
                                                             , "-p", "APP_ENV=${env.DEPLOY_TARGET}" )) 

                                   
                                 def dc = openshift.selector('dc', "${env.APP_NAME}-${env.GIT_CI_SHORT_COMMIT_SHA}")
                                  //this will wait until the desired replicas are available
                                 dc.rollout().status()
                            

                                def route= openshift.selector('route', "${env.APP_NAME}-${env.GIT_CI_SHORT_COMMIT_SHA}")
                                  //this will wait until the desired replicas are available
                                  route.describe()
                                

                               


                                }
                                
                            }
                 }       
            }
        }

        stage('WebApp Scan') {
            steps {
                echo 'Starting to build docker image'
            }
        }



        stage('Testing') {
            when {
                expression {
                     return env.SKIP_STAGE == 'true';
                }
            }
            steps {

             
                 parallel(
                        "Integration Tests ": {
                            sh 'mvn verify -P integration-test'
                                 
                        },
                         "Functional Tests": {
                            echo 'Run integration testing'
                        },
                         "Smoke Test": {
                            echo 'Run integration testing'
                        }
                        
                )
                 
            }
        }    

    



        stage('Performance Testing') {
            steps {
                echo 'Starting to build docker image'
            }
        }     

         stage('Promote and Label to STAGE') {
              when {
                expression {
                     return env.IS_READY_TO_PROMOTE == 'true';
                }
            }  
            steps {
                script {

            
                            echo "OpenShift Project Target  ${env.PROJECT_NAME_SPACE}"
              
                            
                            withCredentials([string(credentialsId: 'OCP_CLI_TOKEN', variable: 'OC_TOKEN')]) {
                                sh "oc login --server=https://apps.navitas-labs.com --token=${OC_TOKEN}"
                            }

                            sh "oc tag ${env.ENV_DT_NAMESPACE}/${env.APP_NAME}:${env.GIT_CI_SHORT_COMMIT_SHA} ${env.ENV_STAGE_NAMESPACE}/${env.APP_NAME}:${env.GIT_CI_SHORT_COMMIT_SHA}"
                            
                                    openshift.withCluster( 'EGIS-Cluster' ) {

                                def template = openshift.withProject( "${env.ENV_STAGE_NAMESPACE }" ) {
                    
                                            openshift.selector('template','egis-microservices-api').object()
                                       
                                }
                                        // Explore the template model
                                 echo "Template contains ${template.parameters.size()} parameters"
 
                                 openshift.withProject( "${env.ENV_STAGE_NAMESPACE }" ) {

                                 openshift.create(openshift.process( template
                                                             , "-p",  "APP_NAME=${env.APP_NAME}-${env.GIT_CI_SHORT_COMMIT_SHA}"
                                                             , "-p", "IMAGE_NAME=docker-registry.default.svc:5000/${env.ENV_STAGE_NAMESPACE }/${env.APP_NAME}"
                                                             , "-p", "IMAGE_TAG=${env.GIT_CI_SHORT_COMMIT_SHA}"
                                                             , "-p", "APP_ENV=${env.DEPLOY_TARGET}" )) 

                                   
                                 def dc = openshift.selector('dc', "${env.APP_NAME}-${env.GIT_CI_SHORT_COMMIT_SHA}")
                                  //this will wait until the desired replicas are available
                                 dc.rollout().status()
                            

                                def route= openshift.selector('route', "${env.APP_NAME}-${env.GIT_CI_SHORT_COMMIT_SHA}")
                                  //this will wait until the desired replicas are available
                                  route.describe()
                                

                               


                                }
                                
                            }
                       
                  }
            }
        }   

         stage('Prod Deployment') {
            steps {
                echo 'Starting to build docker image'
            }
        } 


        stage('Clean') {
              when {
                expression {
                     return env.SKIP_STAGE == 'true';
                }
            }

             steps {
                 script {
            
                    openshift.withCluster( 'EGIS-Cluster' ) {

                                openshift.withProject( "${env.PROJECT_NAME_SPACE }" ) {

                                    if (openshift.selector('dc',  [ app:"${env.APP_NAME}-${env.GIT_CI_SHORT_COMMIT_SHA}" ]).exists()) {
                                       
                                            openshift.selector( 'dc', [ app:"${env.APP_NAME}-${env.GIT_CI_SHORT_COMMIT_SHA}" ] ).delete()
                                            openshift.selector( 'route', [ app:"${env.APP_NAME}-${env.GIT_CI_SHORT_COMMIT_SHA}"] ).delete()
                                            openshift.selector( 'service', [ app:"${env.APP_NAME}-${env.GIT_CI_SHORT_COMMIT_SHA}" ] ).delete()

                                    }

                            }
                    }
             }
            }
        }

    }

    post { 
        always { 

            script {
                    if ( env.SKIP_STAGE == 'true') {
                            
                            junit 'target/surefire-reports/*.xml'
                            junit 'target/failsafe-reports/*.xml'
                    
                }
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


def setPRBuildStatus(String stage, String message, String state) {
  
    if ( env.IS_PR) {
   
     //  githubNotify gitApiUrl: 'https://api.github.com', credentialsId: "GIT_SK_CREDENTIALS", repo: 'ccd-api', account: "egisdemo", context: stage, description: message, status: state, targetUrl: 'http://jenkins.navitas-labs.com'
      }
    else {
        echo "Skip Github notify ${env.IS_PR}"
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
           // slackSend channel: '#cicd_jenkins', color: colorCode, message: summary
            
          }
 
