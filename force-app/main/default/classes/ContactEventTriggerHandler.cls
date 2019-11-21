public with sharing class ContactEventTriggerHandler {

    public static void changeCourseStatus(List<ContactEvent__c> contactEventList) {

        List<ContactEvent__c> contactEventAttendedList = [
            SELECT Name, Status__c, EventId__c, Contact__c, CreatedDate
            FROM ContactEvent__c
            WHERE Status__c = 'Attended'
            ORDER BY CreatedDate DESC
        ];

        List<ContactEvent__c> contactEventWaitingList = [
            SELECT Name, Status__c, EventId__c, Contact__c, CreatedDate
            FROM ContactEvent__c
            WHERE Status__c = 'Waiting List'
            ORDER BY CreatedDate
        ];

        Set<Id> contactEventIdSet = new Set<Id>();
        List<ContactEvent__c> attendedContactEventList = new List<ContactEvent__c>();
        List<ContactEvent__c> waitingContactEventList = new List<ContactEvent__c>();
        List<ContactEvent__c> newContactEventList = new List<ContactEvent__c>();

        for (ContactEvent__c contEvt : contactEventAttendedList) {
            contactEventIdSet.add(contEvt.EventId__c);
        }

        List<Event> eventList = [
            SELECT Subject, Course__r.Name, Max_Person__c
            FROM Event
            WHERE Id IN :contactEventIdSet
        ];

        Map<String, List<ContactEvent__c>> eventMap = new Map<String, List<ContactEvent__c>>();

        for (ContactEvent__c contEvt : contactEventAttendedList) {

            if (eventMap.containsKey(contEvt.EventId__c)) {
                List<ContactEvent__c> evtList = eventMap.get(contEvt.EventId__c);
                evtList.add(contEvt);
                eventMap.put(contEvt.EventId__c, evtList);
            } else {
                eventMap.put(contEvt.EventId__c, new List<ContactEvent__c> { contEvt });
            }
        }

        if (!eventList.isEmpty()) {
            for (Event evt : eventList) {

                if (evt.Max_Person__c < eventMap.get(evt.Id).size()) {
                    waitingContactEventList.add(eventMap.get(evt.Id)[0]);
                } else if (evt.Max_Person__c > eventMap.get(evt.Id).size()) {
                    if (!contactEventWaitingList.isEmpty()) {
                        attendedContactEventList.add(contactEventWaitingList[0]);
                    }
                }
            }

            for (ContactEvent__c contEvt : waitingContactEventList) {
                contEvt.Status__c = 'Waiting List';
            }

            for (ContactEvent__c contEvt : attendedContactEventList) {
                contEvt.Status__c = 'Attended';
            }

            newContactEventList.addAll(waitingContactEventList);
            newContactEventList.addAll(attendedContactEventList);

            if (!newContactEventList.isEmpty()) {
                update newContactEventList;
            }
        }
    }
}