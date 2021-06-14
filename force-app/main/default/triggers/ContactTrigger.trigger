trigger ContactTrigger on Contact (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    ContactTriggerHandler.handleTrigger(Trigger.newMap, Trigger.oldMap, Trigger.operationType);
}