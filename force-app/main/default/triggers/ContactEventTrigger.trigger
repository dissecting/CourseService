trigger ContactEventTrigger on ContactEvent__c (after insert, after update) {

    if (Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)) {
        ContactEventTriggerHandler.changeCourseStatus(Trigger.new);
    }
}