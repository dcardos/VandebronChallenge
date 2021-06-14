# Vandebron Challenge

Project developed by Danilo Cardoso for the technical interview at Vandebron

## item 1 - Sales agents would like to see Accounts that they own and related Contacts 
LWC component created using grid data table: [AccountsContactsGrid](force-app/main/default/lwc/accountsContactsGrid/)  
Component added in the Sales app home page

## item 2 - number of related contacts belonging to the Digital department in an Account 
Number field created on Account object: Digital_Dept_Contacts__c (read only)  
Trigger associated: [ContactTrigger](force-app/main/default/triggers/ContactTrigger.trigger)  
Trigger handler: [ContactTriggerHandlerHandler](force-app/main/default/classes/ContactTriggerHandler.cls)  

## item 3: Fix contacts related to the wrong Accounts
Formula field created on Contact object: Phone_Match_Account__c (not visible)  
Batch class created: [Batch_ReparentContacts](force-app/main/default/classes/Batch_ReparentContacts.cls)
