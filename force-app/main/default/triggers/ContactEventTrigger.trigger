trigger ContactEventTrigger on ContactEvent__c (after delete, after undelete, after insert, after update, before delete, before insert, before update) {

    TriggerFactory.createHandler(ContactEvent__c.sObjectType);
}