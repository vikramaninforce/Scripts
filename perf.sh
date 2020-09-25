DOMAIN="https://avengers.opexanalytics.com"
APP_PATH="/apps/large_app_sample_1/"
AUTH="/auth/login"
COPY_SCENARIO="/scenario/copy/3"
CREATE_SCENARIO="/scenario"
DELETE_SCENARIO="/scenario?scenarioIds=7"
ARCHIVE_SCENARIO="/archiving?scenarioIds=4"
EDIT_SCENARIO="/scenario/3"
RUN_SCRIPT="/execution/run/35/1?type=scripts"

copyScenario() {
	APP_PATH=$1
	PASSWORD=$2
	TOKEN=$(curl -d "username=opextestautomation@opexanalytics.com&password=$PASSWORD"  $DOMAIN$APP_PATH$AUTH |\jq -r '.token')
	echo "$TOKEN"
	echo "Copying Scenario"
	JSONDATA='{"newScenarioName": "copyper"}'
	COPY_SCENARIO_RESULT=$(curl -d "$JSONDATA" --header "Content-Type:application/json" --header "token:$TOKEN" $DOMAIN$APP_PATH$COPY_SCENARIO)
	echo "$COPY_SCENARIO_RESULT"

}
createScenario() {
	echo "Creating Scenario"
	JSONDATA='{"name": "masterfi", "templateId": "1", "tag": "1"}'
	CREATE_SCENARIO_RESULT=$(curl -w "@curl-format.txt" -d "$JSONDATA" --header "Content-Type:application/json" --header "token:$TOKEN" $DOMAIN$APP_PATH$CREATE_SCENARIO)
	echo "Result $CREATE_SCENARIO_RESULT"
}
deleteScenario() {
	
	echo "Deleting Scenario"
	JSONDATA='{"scenarioIds": "67"}'
	DELETE_SCENARIO_RESULT=$(curl -d "$JSONDATA" --header "Content-Type:application/json" --header "token:$TOKEN" -X DELETE $DOMAIN$APP_PATH$DELETE_SCENARIO)
	echo "$DELETE_SCENARIO_RESULT"
}

archiveScenario() {
	echo "Archiving Scenario"
	JSONDATA='{"scenarioIds": "15"}'
	ARCHIVE_SCENARIO_RESULT=$(curl -d "$JSONDATA" --header "Content-Type:application/json" --header "token:$TOKEN" $DOMAIN$APP_PATH$ARCHIVE_SCENARIO)
	echo "$ARCHIVE_SCENARIO_RESULT"
}
editScenario() {
	echo "Editing Scenario"
	JSONDATA='{"name": "Capacity Jan 28", "tagID": "1"}'
	EDIT_SCENARIO_RESULT=$(curl -X PUT -H "Content-Type: application/json" -d "$JSONDATA"  --header "token:$TOKEN" $DOMAIN$APP_PATH$EDIT_SCENARIO)
	echo "$EDIT_SCENARIO_RESULT"
}
openScenario() {
	APP_PATH=$1
	PASSWORD=$2
	TOKEN=$(curl -d "username=Administrator&password=$PASSWORD"  $DOMAIN$APP_PATH$AUTH |\jq -r '.token')
	echo "$TOKEN"
	echo "Opening Scenario"
	JSONDATA='{"type": "input_refresh", "limit": "1", "executionIds": "2,4"}'
	OPEN_SCENARIO=$(curl --header "Content-Type:application/json" --header "token:$TOKEN" -X GET https://avengers.opexanalytics.com/apps/large_app_sample_1/#/project/1/inputs)
	OPEN_SCENARIO_RESULT=$(curl -w "@curl-format.txt" -d "$JSONDATA" --header "Content-Type:application/json" --header "token:$TOKEN" -X GET -s "https://ccbcc-uat.opexanalytics.com/masterfix/execution/history/15?type=input_refresh&limit=1&executionIds=2,4")
	echo "$OPEN_SCENARIO_RESULT"
}
copyScenario "large_app_sample_1" "Opex@123"
createScenario "large_app_sample_1" "Opex@123"
deleteScenario "large_app_sample_1" "Opex@123"
archiveScenario "large_app_sample_1" "Opex@123"
editScenario "large_app_sample_1" "Opex@123"
openScenario "large_app_sample_1" "Opex@123"
