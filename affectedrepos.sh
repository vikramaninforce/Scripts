#!/bin/bash

# git fetch
# git checkout qa
# git pull origin qa
# git checkout prod
# git pull origin prod
# git checkout -b NFR-1280
# git merge qa
# git push origin NFR-1280

echo "\033[34m"
rm -fv *.txt
DATE=$1
TIME=$2
QA_BRANCH=$3
PROD_BRANCH=$4
JIRA_PROJECT=$5
CREATE_PR=$6
LINK=https://github.com/OpexAnalytics-RAD/
REPOS=( platform-v3 selfserve-analytics-center job_processor enframe_macros scheduler connector_documentation connector_api socket_shaft jarvis-helper-bot jenkins-dev_ops enframe-deployment enframe-init )

affectedrepos() {
for X in ${REPOS[@]}
 do
 unset STATUS
 rm -rf $X 
 git clone -b $QA_BRANCH "$LINK""$X".git || STATUS=$(echo "Failed to clone $X")
 echo "$STATUS"
 if [ -z "$STATUS" ]
  then
  cd $X
  git fetch 
  git pull origin $QA_BRANCH || STATUS=$(echo "Failed to pull $QA_BRANCH for $X")
  echo "$STATUS"
  if [ -z "$STATUS" ]
   then
   echo -e "\033[32m git pull origin $QA_BRANCH is successfull."
   LOG=$(git log --after="'$DATE 00:00:00'" --pretty=format:%s|sed /\*/d)
    if [[ "$LOG" =~ [A-Za-z] ]]
    then
    echo -e "\033[32m $X repo is affected"
    IMPACTEDREPOS=("${IMPACTEDREPOS} ${X}")
    LOGS=( "$LOGS\n $X:\n $LOG\n" ) 
    else
    echo -e "\033[32m $X repo is not affected"
    fi
  fi
  cd ..
 fi
done
echo "\033[32m Impacted repos: ${IMPACTEDREPOS[@]}"
jira
}

jira() {
 LOGS=("Date mentioned/inputed date to fetch impacted repos: $DATE\n ${LOGS[@]}")
 echo "Below are its impacted repos and its corresponding jira's:\n $LOGS"
 JIRAID=$(curl -s https://opexanalytics.atlassian.net/rest/api/2/issue/ -u vikraman.arutchelvan@opexanalytics.com:L9w3DsxZK2gVhOxnZrGwF5A7 \
   -X POST \
   --data '{
    "fields": {
       "project": 
       {
          "id": "'"$JIRA_PROJECT"'"
       },
       "summary": "Deployment ticket",
       "description": "Below are the impacted repos and its corresponding jira id:\n Impacted repos are: '"${IMPACTEDREPOS[@]}"' \n\n '"$(echo "$LOGS" | sed 's/$/\\n/g' | tr -d '\n')"'",
       "issuetype": {
          "name": "Task"
       }
      }
    }' -H "Content-Type:application/json"|jq -r '.key')
  echo "Deployment jira id: $JIRAID" 
}

merge() {
# echo "jira $JIRAID"
for X in ${IMPACTEDREPOS[@]}
do
# echo $X
 cd $X
 git fetch 
 git pull origin qa
  if [ "$?" -eq "0" ]
  then
   echo -e "\033[32m Merging starting for $X repo"
   git checkout $PROD_BRANCH
    if [ "$?" -eq "0" ]
    then
    git pull origin $PROD_BRANCH
     if [ "$?" -eq "0" ]
     then
     git checkout -b $JIRAID
      if [ "$?" -eq "0" ]
      then
      git merge qa -m"automated merge"
       if [ "$?" -eq "0" ]
       then
       echo -e "\033[32m Merging sucessfull for $X repo"
       git push origin $JIRAID
        if [ "$?" -eq "0" ]
        then
        PR=$(hub pull-request -f -b OpexAnalytics-RAD/${X}:${PROD_BRANCH} -m "Automated PR for ${X} repo to ${PROD_BRANCH} branch")
         if [ "$?" -eq "0" ]
         then
         echo -e "\033[32m Pull request created for $X repo"
         else
         echo -e "\033[31m Failed to create pull request for $X repo"
         fi
        else
        echo -e "\033[31m Failed to push origin $JIRAID"
        fi
       else
       echo -e "\033[31m Failed to merge qa for $X repo - merge qa"
       fi
      else
      echo -e "\033[31m Failed to checkout -b $JIRAID"
      fi
     else
     echo -e "\033[31m Failed to git pull origin $PROD_BRANCH for $X"
     fi
    else
    echo -e "\033[31m Failed to checkout $PROD_BRANCH for $X"
    fi
  else
  echo -e "\033[31m Failed to git pull qa for $X"
  fi
  cd ..
echo "${X}\n" "${PR}\n" >> PR.txt
done
# echo "$PR" > PR.txt
curl -s https://opexanalytics.atlassian.net/rest/api/2/issue/"$JIRAID"/attachments -u vikraman.arutchelvan@opexanalytics.com:L9w3DsxZK2gVhOxnZrGwF5A7 \
   -X POST -H "X-Atlassian-Token: nocheck" -F "file=@PR.txt"
buildStatus
}

buildStatus() {
if [ -f $debug ]
 then
 if grep -q Failed "debug.txt"
  then
  COMMENT=$(echo "Automated build Failed for this build trigger: $DATE please check latest debug.txt file attached.")
  curl -u vikraman.arutchelvan@opexanalytics.com:L9w3DsxZK2gVhOxnZrGwF5A7 \
   -X POST \
   --data '{
    "body": "'"$COMMENT"'"
   }' -H "Content-Type: application/json" \
   https://opexanalytics.atlassian.net/rest/api/2/issue/"$JIRAID"/comment
  else
  COMMENT=$(echo "Automated build successfull for this build trigger: $DATE")
  curl -u vikraman.arutchelvan@opexanalytics.com:L9w3DsxZK2gVhOxnZrGwF5A7 \
   -X POST \
   --data '{
    "body": "'"$COMMENT"'"
   }' -H "Content-Type: application/json" \
   https://opexanalytics.atlassian.net/rest/api/2/issue/"$JIRAID"/comment
 fi
 else
 echo "Failed - debug.txt not found"
fi
}

if [ "$CREATE_PR" = true ]
  then
    affectedrepos >> debug.txt
    merge >> debug.txt
    curl -s https://opexanalytics.atlassian.net/rest/api/2/issue/"$JIRAID"/attachments -u vikraman.arutchelvan@opexanalytics.com:L9w3DsxZK2gVhOxnZrGwF5A7 \
   -X POST -H "X-Atlassian-Token: nocheck" -F "file=@debug.txt"
  else
    affectedrepos
fi


