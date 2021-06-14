@isTest
public class TestDataFactory {
    public static Account createAccount(String name, String phone) {
        return new Account(Name = name, Phone = phone);
    }

    public static Contact createContact(String lastName, Id acctId, String phone, String department) {
        return new Contact(LastName = lastName, AccountId = acctId, Phone = phone, Department = department);
    }
}
