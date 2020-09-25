from tableaudocumentapi import Workbook

sourceWB = Workbook('workbook__31__5ebd2e77c610660027445090_output.twbx')

for i in range(0,(len(sourceWB.datasources))):
    sourceWB.datasources[i].connections[0].server = "sandbox3.opexanalytics.com"
    sourceWB.datasources[i].connections[0].dbname = "qa_tableau_test_app_5ed5fba9c966080027ea792a"
    sourceWB.datasources[i].connections[0].username = "reports_5ed5fba9c966080027ea792a"
    sourceWB.datasources[i].connections[0].password = "hVVzHDMdCbMC6NQ5"
    print("Updated for : ", (sourceWB.datasources[i].caption))

sourceWB.save()

