#!/bin/bash

# git fetch
# git checkout qa
# git pull origin qa
# git checkout prod
# git pull origin prod
# git checkout -b NFR-1280
# git merge qa
# git push origin NFR-1280

rm -fv *.txt
JIRAID=$1
QA_BRANCH=$2
PROD_BRANCH=$3
shift 3
REPOS=$@
LINK=https://github.com/OpexAnalytics-RAD/

merge() {
for X in ${REPOS[@]}
do
 rm -rf $X 
 git clone -b $QA_BRANCH "$LINK""$X".git || STATUS=$(echo "Failed to clone $X") && echo "$STATUS"
 cd $X
 git fetch 
 git pull origin $QA_BRANCH
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
      git merge $QA_BRANCH -m"automated merge"
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
       echo -e "\033[31m Failed to merge $QA_BRANCH for $X repo - merge $QA_BRANCH"
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
  echo -e "\033[31m Failed to git pull $QA_BRANCH for $X"
  fi
  cd ..
echo "$X \n" "$PR \n" >> PR.txt
done
# echo "$PR" > PR.txt
buildStatus
}

buildStatus() {
 if grep -q Failed "debug.txt"
  then
  COMMENT=$(echo "Automated build Failed for this build trigger ${REPOS[@]} please check latest debug.txt file attached ")
  curl -u vikraman.arutchelvan@opexanalytics.com:L9w3DsxZK2gVhOxnZrGwF5A7 \
   -X POST \
   --data '{
    "body": "'"$COMMENT"'"
   }' -H "Content-Type: application/json" \
   https://opexanalytics.atlassian.net/rest/api/2/issue/"$JIRAID"/comment
  else
  COMMENT=$(echo "Automated build successfull for this build trigger ${REPOS[@]}")
  curl -u vikraman.arutchelvan@opexanalytics.com:L9w3DsxZK2gVhOxnZrGwF5A7 \
   -X POST \
   --data '{
    "body": "'"$COMMENT"'"
   }' -H "Content-Type: application/json" \
   https://opexanalytics.atlassian.net/rest/api/2/issue/"$JIRAID"/comment
  fi
}
merge >> debug.txt
curl -s https://opexanalytics.atlassian.net/rest/api/2/issue/"$JIRAID"/attachments -u vikraman.arutchelvan@opexanalytics.com:L9w3DsxZK2gVhOxnZrGwF5A7 \
   -X POST -H "X-Atlassian-Token: nocheck" -F "file=@debug.txt"
