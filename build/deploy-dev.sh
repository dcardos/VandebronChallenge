#Convert to MDAPI format for deployment to prod
#echo "Converting to MDAPI format..."

#sfdx force:source:convert -d deploy_dev -r force-app 
#Parse Test classes

#for entry in $(ls force-app/main/default/classes/ | grep "Test.cls$")
#do  
#    classes="$(basename "$entry" .cls),${classes}" 
#done

#Deploy to dev & run local tests
#echo "Deploying to DevOrg & running deployed tests..."
#sfdx force:mdapi:deploy -u DEV -d deploy_dev/ -w -1 -l RunSpecifiedTests -r ${classes::-1}

# validade deployment
sfdx force:source:deploy --checkonly --sourcepath force-app --targetusername brave-org --testlevel RunLocalTests