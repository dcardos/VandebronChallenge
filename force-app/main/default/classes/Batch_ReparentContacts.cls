public class Batch_ReparentContacts implements Database.Batchable<sObject>, Database.Stateful {
    public Integer contactsReparented = 0;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Phone, AccountId, Account.Phone ' +
            'FROM Contact ' +
            'WHERE Phone_Match_Account__c = false AND Phone != null'
        );
    }

    public void execute(Database.BatchableContext bc, List<Contact> scope) {
        Map<Id,Contact> contactsMap = new Map<Id,Contact>(scope);
        Map<String,Set<Id>> phoneToContactsMap = new Map<String,Set<Id>>(); 
        for (Contact missParentedContact : contactsMap.values()) {
            if (phoneToContactsMap.containsKey(missParentedContact.Phone)) {
                phoneToContactsMap.get(missParentedContact.Phone).add(missParentedContact.Id);
            } else {
                phoneToContactsMap.put(missParentedContact.Phone, new Set<Id>{missParentedContact.Id});
            }
        }
        // if more than one account has the same phone number, then the most recent created account will be the parent
        List<Account> parentAccounts = [
            SELECT Phone 
            FROM Account 
            WHERE Phone IN :phoneToContactsMap.keySet() 
            ORDER BY CreatedDate ASC 
            LIMIT 50000
        ];
        List<Contact> contactsToReparent = new List<Contact>();
        for (Account parentAccount : parentAccounts) {
            for (Id contactId : phoneToContactsMap.get(parentAccount.Phone)) {
                Contact toBeReparentedContact =  contactsMap.get(contactId);
                toBeReparentedContact.AccountId = parentAccount.Id; 
                toBeReparentedContact.Phone = parentAccount.Phone;
                contactsToReparent.add(toBeReparentedContact);
            }
        }
        contactsReparented += contactsToReparent.size(); 
        update contactsToReparent;
    }

    public void finish(Database.BatchableContext bc){
        System.debug(contactsReparented + ' contacts reparented!');
    }
}