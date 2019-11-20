trigger ContactEventTrigger on ContactEvent__c (after insert) {

    if (Trigger.isAfter && Trigger.isInsert) {
        ContactEventTriggerHandler.changeCourseStatus(Trigger.new);
    }
}