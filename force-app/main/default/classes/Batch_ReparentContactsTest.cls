@isTest
private class Batch_ReparentContactsTest {
    private static final String PHONE1 = '0642140111';
    private static final String PHONE2 = '0642140222';

    @TestSetup
    static void makeData() {
        Account testAcct1 = TestDataFactory.createAccount('Wind Farm Utrecht', PHONE1);
        Account testAcct2 = TestDataFactory.createAccount('Solar Farm Utrecht', PHONE2);
        insert new List<Account>{testAcct1, testAcct2};
    }

    @isTest
    private static void batch_ReparentContactsLogicalTest() {
        Account acct1 = [SELECT Id FROM Account WHERE Phone = :PHONE1];
        Account acct2 = [SELECT Id FROM Account WHERE Phone = :PHONE2];
        List<Contact> contacts = new List<Contact>{
            TestDataFactory.createContact('Liu', acct1.Id, PHONE1, 'Development'),
            TestDataFactory.createContact('Korobovich', acct1.Id, PHONE2, 'Digital'),
            TestDataFactory.createContact('Grycko', null, PHONE2, 'HR'),
            TestDataFactory.createContact('Paul', null, '0642140000', 'Management'),
            TestDataFactory.createContact('Kim', acct2.Id, null, 'Finance')
        };
        insert contacts;

        System.assertEquals(4, [SELECT COUNT() FROM Contact WHERE Phone_Match_Account__c = false], '3 contacts should have the flag for mismatching their accounts phone number as false');

        Test.startTest();
        Database.executeBatch(new Batch_ReparentContacts());
        Test.stopTest();
        System.assertEquals(acct1.Id, [SELECT AccountId FROM Contact WHERE Id = :contacts[0].Id].AccountId, 'This contact should not have been reparented');
        System.assertEquals(acct2.Id, [SELECT AccountId FROM Contact WHERE Id = :contacts[1].Id].AccountId, 'This contact should have been reparented');
        System.assertEquals(acct2.Id, [SELECT AccountId FROM Contact WHERE Id = :contacts[2].Id].AccountId, 'This contact should have been reparented');
        System.assertEquals(null, [SELECT AccountId FROM Contact WHERE Id = :contacts[3].Id].AccountId, 'This contact should not have been reparented');
        System.assertEquals(acct2.Id, [SELECT AccountId FROM Contact WHERE Id = :contacts[4].Id].AccountId, 'This contact should not have been reparented');
    }

    @isTest
    private static void batch_ReparentContactsLoadTest() {
        List<Contact> contactsOk = new List<Contact>();
        List<Contact> contactsMissParented = new List<Contact>();
        Id acct1Id = [SELECT Id FROM Account WHERE Phone = :PHONE1].Id;
        Integer i;
        final Integer NUM_REC = 1000;
        for (i = 0; i < NUM_REC; i++) {
            contactsOk.add(TestDataFactory.createContact('Test' + i, acct1Id, PHONE1, 'Digital'));
        }
        for (; i < NUM_REC*2; i++) {
            contactsMissParented.add(TestDataFactory.createContact('Test' + i, acct1Id, PHONE2, 'Digital'));
        }
        insert contactsOk;
        insert contactsMissParented;
        System.assertEquals(NUM_REC, [SELECT COUNT() FROM Contact WHERE Phone_Match_Account__c = false], NUM_REC + ' contacts should have the flag for mismatching their accounts phone number as false');

        Test.startTest();
        Database.executeBatch(new Batch_ReparentContacts(), 2000);
        Test.stopTest();

        Id acct2Id = [SELECT Id FROM Account WHERE Phone = :PHONE2].Id;
        System.assertEquals(NUM_REC, [SELECT COUNT() FROM Contact WHERE AccountId = :acct2Id], NUM_REC + ' records should have been reparented');
    }
}
