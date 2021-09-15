#Convert to MDAPI format for deployment to prod
#echo "Converting to MDAPI format..."
#sfdx force:source:convert -d deploy_uat -r force-app 

#Deploy to prod & run all tests
#echo "Deploying to qualidade & running all tests..."
#sfdx force:mdapi:deploy -u UAT -d deploy_uat/ -w -1 -l RunAllTestsInOrg

sfdx force:source:deploy --checkonly --sourcepath force-app --targetusername brave-org --testlevel RunLocalTests

sfdx force:source:deploy --targetusername brave-org --validateddeployrequestid jobID