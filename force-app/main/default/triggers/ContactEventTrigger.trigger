trigger ContactEventTrigger on ContactEvent__c (after delete, after update, before insert) {

    TriggerFactory.createHandler(ContactEvent__c.sObjectType);
}