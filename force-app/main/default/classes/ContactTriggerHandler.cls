public with sharing class ContactTriggerHandler {
    public static void handleTrigger(Map<Id,Contact> workingContactsMap, Map<Id,Contact> oldContacsMap, System.TriggerOperation triggerEvent ) {
        switch on triggerEvent {
            // when BEFORE_INSERT { }
            when AFTER_INSERT { 
                updateRelatedAcctDigitalContactsCount(workingContactsMap, oldContacsMap, triggerEvent);
            }
            // when BEFORE_UPDATE { }
            when AFTER_UPDATE { 
                updateRelatedAcctDigitalContactsCount(workingContactsMap, oldContacsMap, triggerEvent);
            }
            // when BEFORE_DELETE { }
            when AFTER_DELETE {
                updateRelatedAcctDigitalContactsCount(workingContactsMap, oldContacsMap, triggerEvent);
            }
            when AFTER_UNDELETE {
                updateRelatedAcctDigitalContactsCount(workingContactsMap, oldContacsMap, triggerEvent);
            }
        }
    }

    private static void updateRelatedAcctDigitalContactsCount(Map<Id,Contact> workingContactsMap, Map<Id,Contact> oldContactsMap, System.TriggerOperation triggerEvent) {
        Map<Id,Integer> acctIdToUpdateCountMap = new Map<Id,Integer>();
        if (triggerEvent == System.TriggerOperation.AFTER_DELETE) {
            for (Contact oldContact : oldContactsMap.values()) {
                if (String.isNotBlank(oldContact.Department) && oldContact.Department.equalsIgnoreCase('Digital')) {
                    acctIdToUpdateCountMap = updateAcctValueMap(acctIdToUpdateCountMap, oldContact.AccountId, -1);
                }
            }
        } else {
            for (Contact workingContact : workingContactsMap.values()) { // no working contact if delete operation
                if ( 
                    (triggerEvent == System.TriggerOperation.AFTER_INSERT || triggerEvent == System.TriggerOperation.AFTER_UNDELETE) && 
                    String.isNotBlank(workingContact.Department) && workingContact.Department.equalsIgnoreCase('Digital')
                ) {
                    acctIdToUpdateCountMap = updateAcctValueMap(acctIdToUpdateCountMap, workingContact.AccountId, +1);
                } else if (triggerEvent == System.TriggerOperation.AFTER_UPDATE) {
                    Contact oldContact = oldContactsMap.get(workingContact.Id);
                    if (departmentChangedFromDigital(oldContact, workingContact)) {
                        acctIdToUpdateCountMap = updateAcctValueMap(
                            acctIdToUpdateCountMap, 
                            // did account also change?
                            oldContact.AccountId != workingContact.AccountId ? oldContact.AccountId : workingContact.AccountId, 
                            -1
                        );
                    } else if (departmentChangedToDigital(oldContact, workingContact)) {
                        acctIdToUpdateCountMap = updateAcctValueMap(acctIdToUpdateCountMap, workingContact.AccountId, +1);
                    } else if (
                        departmentStillDigital(oldContact, workingContact) && 
                        oldContact.AccountId != workingContact.AccountId
                    ) {
                        acctIdToUpdateCountMap = updateAcctValueMap(acctIdToUpdateCountMap, oldContact.AccountId, -1);
                        acctIdToUpdateCountMap = updateAcctValueMap(acctIdToUpdateCountMap, workingContact.AccountId, +1);
                    }
                }
            }
        }
        updateAcctsDigitalCount(acctIdToUpdateCountMap);
    }
    
    private static Map<Id,Integer> updateAcctValueMap(Map<Id,Integer> acctValueMap, Id acctId, Integer increment) {
        Map<Id,Integer> acctValueUpdatedMap = new Map<Id,Integer>(acctValueMap);
        if (acctId == null || increment == null) {
            return acctValueUpdatedMap;
        }
        if (acctValueMap.containsKey(acctId)) {
            acctValueUpdatedMap.put(acctId, acctValueMap.get(acctId) + increment);
        } else {
            acctValueUpdatedMap.put(acctId, increment);
        }
        return acctValueUpdatedMap;
    }

    private static void updateAcctsDigitalCount(Map<Id,Integer> acctValueMap) {
        List<Account> acctsToUpdate = [SELECT Digital_Dept_Contacts__c FROM Account WHERE Id IN :acctValueMap.keySet()];
        for (Account acct : acctsToUpdate) {
            Decimal previousValue = acct.Digital_Dept_Contacts__c == null ? 0 : acct.Digital_Dept_Contacts__c;
            acct.Digital_Dept_Contacts__c = previousValue + acctValueMap.get(acct.Id);
        }
        update acctsToUpdate;
    }

    private static boolean departmentChangedToDigital(Contact oldContact, Contact newContact) {
        return 
            (String.isBlank(oldContact.Department) || !oldContact.Department.equalsIgnoreCase('Digital')) &&
            (String.isNotBlank(newContact.Department) && newContact.Department.equalsIgnoreCase('Digital'));
    }

    private static boolean departmentChangedFromDigital(Contact oldContact, Contact newContact) {
        return 
            (String.isNotBlank(oldContact.Department) && oldContact.Department.equalsIgnoreCase('Digital')) &&
            (String.isBlank(newContact.Department) || !newContact.Department.equalsIgnoreCase('Digital'));
    }

    private static boolean departmentStillDigital(Contact oldContact, Contact newContact) {
        return 
            (String.isNotBlank(oldContact.Department) && oldContact.Department.equalsIgnoreCase('Digital')) &&
            (String.isNotBlank(newContact.Department) && newContact.Department.equalsIgnoreCase('Digital'));
    }
}
