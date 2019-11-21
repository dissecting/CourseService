trigger ContactEventTrigger on ContactEvent__c (after insert, after delete) {

    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isDelete)) {
        ContactEventTriggerHandler.changeCourseStatus(Trigger.new);
    }
}