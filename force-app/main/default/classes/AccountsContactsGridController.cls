public with sharing class AccountsContactsGridController {

    public class ParsedAccount {
        @auraEnabled public String id;
        @auraEnabled public String link;
        @auraEnabled public String name;
        @auraEnabled public String phoneNumber;
        @auraEnabled public String address;
        @auraEnabled public Integer digitalContactsAmount;
        @auraEnabled public List<ParsedContact> contacts;

        public ParsedAccount(Id id, String name, String phoneNumber, Address address, Decimal digitalContactsAmount, List<ParsedContact> contacts) {
            this.id = id;
            this.link = URL.getSalesforceBaseUrl().toExternalForm() + '/' + id;
            this.name = name;
            this.phoneNumber = phoneNumber;
            this.address = address != null ? address.getCity() : '';
            this.digitalContactsAmount = Integer.valueOf(digitalContactsAmount);
            this.contacts = contacts;
        }
    }

    public class ParsedContact {
        @auraEnabled public String id;
        @auraEnabled public String link;
        @auraEnabled public String name;
        @auraEnabled public String phoneNumber;
        @auraEnabled public String address;
        @auraEnabled public String department;

        public ParsedContact(Id id, String name, String phoneNumber, Address address, String department) {
            this.id = id;
            this.link = URL.getSalesforceBaseUrl().toExternalForm() + '/' + id;
            this.name = name;
            this.phoneNumber = phoneNumber;
            this.address = address != null ? address.getCity() : '';
            this.department = department;
        }
    }

    @AuraEnabled(cacheable = true)
    public static List<ParsedAccount> getAcctContactData() {
        List<ParsedAccount> parsedAccounts = new List<ParsedAccount>();
        try {
            List<Contact> contacts = [
                SELECT Name, Account.Name, Phone, Account.Phone, MailingAddress, Account.BillingAddress, Department, Account.Digital_Dept_Contacts__c, AccountId 
                FROM Contact 
                WHERE Account.OwnerId = :UserInfo.getUserId()
                WITH SECURITY_ENFORCED
                ORDER BY Account.Name, Name
                LIMIT 1000
            ];
            Map<Id,ParsedAccount> parsedAcctsMap = new Map<Id,ParsedAccount>();
            for (Contact singleContact : contacts) {
                ParsedContact contactParsed = new ParsedContact(singleContact.Id, singleContact.Name, singleContact.Phone, singleContact.MailingAddress, singleContact.Department);
                if (parsedAcctsMap.containsKey(singleContact.AccountId)) {
                    parsedAcctsMap.get(singleContact.AccountId).contacts.add(contactParsed);
                } else {
                    parsedAcctsMap.put(
                        singleContact.AccountId,
                        new ParsedAccount(
                            singleContact.AccountId, singleContact.Account.Name, singleContact.Account.Phone, singleContact.Account.BillingAddress, singleContact.Account.Digital_Dept_Contacts__c, 
                            new List<ParsedContact>{contactParsed}
                        )
                    );
                }
            }
            return parsedAcctsMap.values();
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

}
