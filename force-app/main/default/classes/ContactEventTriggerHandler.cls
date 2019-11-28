public without sharing class ContactEventTriggerHandler implements ITrigger {

    public void bulkBefore() {}

    public void bulkAfter() {}

    public void beforeInsert(List<SObject> newlstObj) {

        Map<String, List<ContactEvent__c>> eventMap = new Map<String, List<ContactEvent__c>>();
        List<ContactEvent__c> attendedContactEventList = new List<ContactEvent__c>();
        List<ContactEvent__c> waitingContactEventList = new List<ContactEvent__c>();
        Set<Id> contactEventIdSet = new Set<Id>();
        List<ContactEvent__c> newContactEventLst = newlstObj;

        for (ContactEvent__c contEvt : newContactEventLst) {
            contactEventIdSet.add(contEvt.EventId__c);
        }

        List<Event> eventList = getEventList(contactEventIdSet);
        List<ContactEvent__c> contactEventAttendedList = ContactEventTriggerHandler.contactEventAttendedList(
            ContactEventTriggerHandler.getEventIdSet(eventList)
        );

        eventMap = ContactEventTriggerHandler.getEventMap(contactEventAttendedList);

        if (!eventList.isEmpty()) {
            for (Event evt : eventList) {

                if (!eventMap.isEmpty()) {
                    Integer index = 0;
                    Integer mapSize = eventMap.get(evt.Id).size();
                    while (evt.Max_Person__c < mapSize + 1) {
                        if (newContactEventLst.size() > index) {
                            waitingContactEventList.add(newContactEventLst[index]);
                        }

                        index++;
                        mapSize--;
                    }

                    while (evt.Max_Person__c > mapSize) {
                        if (newContactEventLst.size() > index) {
                            attendedContactEventList.add(newContactEventLst[index]);
                        }

                        index++;
                        mapSize++;
                    }
                } else {

                    for (Integer i = 0; i < evt.Max_Person__c; i++) {
                        if (newContactEventLst.size() > i) {
                            attendedContactEventList.add(newContactEventLst[i]);
                        }
                    }

                    if (newContactEventLst.size() > Integer.valueOf(evt.Max_Person__c)) {
                        for (Integer i = Integer.valueOf(evt.Max_Person__c); i < newContactEventLst.size(); i++) {
                            waitingContactEventList.add(newContactEventLst[i]);
                        }
                    }
                }
            }

            ContactEventTriggerHandler.contactEventChangeStatusToAttended(attendedContactEventList);
            ContactEventTriggerHandler.contactEventChangeStatusToWaiting(waitingContactEventList);
        }
    }

    public void beforeUpdate(List<SObject> newlstObj, List<SObject> oldlstObj, Map<Id, SObject> newMapObj, Map<Id, SObject> oldMapObj) {}

    public void beforeDelete(List<SObject> oldlstObj, Map<Id, SObject> oldMapObj) {}

    public void afterInsert(List<SObject> newlstObj, Map<Id, SObject> newMapObj) {}

    public void afterUpdate(List<SObject> newlstObj, List<SObject> oldlstObj, Map<Id, SObject> newMapObj, Map<Id, SObject> oldMapObj) {
        List<ContactEvent__c> newContactEventLst = newlstObj;
        List<ContactEvent__c> oldContactEventLst = oldlstObj;
        Map<String, List<ContactEvent__c>> eventMap = new Map<String, List<ContactEvent__c>>();
        List<ContactEvent__c> attendedContactEventList = new List<ContactEvent__c>();
        List<ContactEvent__c> newAttendedContactEventList = new List<ContactEvent__c>();
        List<ContactEvent__c> waitingContactEventList = new List<ContactEvent__c>();
        Set<Id> contactEventIdSet = new Set<Id>();
        Boolean isStatusChanged = false;
        Integer contactEventIndex = 0;

        for (ContactEvent__c contEvt : newContactEventLst) {

            if (contEvt.Status__c != oldContactEventLst[contactEventIndex].Status__c) {
                isStatusChanged = true;
            }
            contactEventIndex++;
            contactEventIdSet.add(contEvt.EventId__c);
        }

        if (isStatusChanged) {
            List<Event> eventList = ContactEventTriggerHandler.getEventList(contactEventIdSet);
            List<ContactEvent__c> contactEventAttendedList = ContactEventTriggerHandler.contactEventAttendedList(
                ContactEventTriggerHandler.getEventIdSet(eventList)
            );
            List<ContactEvent__c> contactEventWaitingList = ContactEventTriggerHandler.contactEventWaitingList(
                ContactEventTriggerHandler.getEventIdSet(eventList)
            );

            eventMap = ContactEventTriggerHandler.getEventMap(contactEventAttendedList);

            if (!eventList.isEmpty()) {
                for (Event evt : eventList) {

                    if (!eventMap.isEmpty()) {
                        Integer index = 0;
                        Integer mapSize = eventMap.get(evt.Id).size();

                        while (evt.Max_Person__c > mapSize) {

                            if (newContactEventLst.size() > index) {
                                if (newContactEventLst[index].Status__c == 'Waiting List') {
                                    if (contactEventWaitingList.size() > index && newContactEventLst[index].Id != contactEventWaitingList[index].Id) {
                                        newAttendedContactEventList.add(contactEventWaitingList[index]);
                                    }

                                }
                            }

                            index++;
                            mapSize++;
                        }

                        while (evt.Max_Person__c < mapSize) {

                            if (newContactEventLst.size() > index) {
                                if (newContactEventLst[index].Status__c == 'Attended') {
                                    throw new TriggerException('Max member size!');
                                }
                            }

                            index++;
                            mapSize--;
                        }

                    } else {

                        for (Integer i = 0; i < evt.Max_Person__c; i++) {
                            if (newContactEventLst.size() > i) {
                                attendedContactEventList.add(newContactEventLst[i]);
                            }
                        }

                        if (newContactEventLst.size() > Integer.valueOf(evt.Max_Person__c)) {
                            for (Integer i = Integer.valueOf(evt.Max_Person__c); i < newContactEventLst.size(); i++) {
                                waitingContactEventList.add(newContactEventLst[i]);
                            }
                        }
                    }
                }

                ContactEventTriggerHandler.contactEventChangeStatusToAttended(newAttendedContactEventList);

                if (!newAttendedContactEventList.isEmpty()) {
                    update newAttendedContactEventList;
                }
            }
        }
    }

    public void afterDelete(List<SObject> oldlstObj, Map<Id, SObject> oldMapObj) {

        List<ContactEvent__c> oldContactEventLst = oldlstObj;
        List<ContactEvent__c> attendedContactEventList = new List<ContactEvent__c>();
        Set<Id> contactEventIdSet = new Set<Id>();
        Map<String, List<ContactEvent__c>> eventMap = new Map<String, List<ContactEvent__c>>();

        for (ContactEvent__c contEvt : oldContactEventLst) {

            if (contEvt.Status__c == 'Attended') {
                contactEventIdSet.add(contEvt.EventId__c);
                if (eventMap.containsKey(contEvt.EventId__c)) {
                    List<ContactEvent__c> evtList = eventMap.get(contEvt.EventId__c);
                    evtList.add(contEvt);
                    eventMap.put(contEvt.EventId__c, evtList);
                } else {
                    eventMap.put(contEvt.EventId__c, new List<ContactEvent__c> { contEvt });
                }
            }
        }

        if (!contactEventIdSet.isEmpty()) {

            List<Event> eventList = ContactEventTriggerHandler.getEventList(contactEventIdSet);
            List<ContactEvent__c> contactEventWaitingList = ContactEventTriggerHandler.contactEventWaitingList(
                ContactEventTriggerHandler.getEventIdSet(eventList)
            );

            if (!eventList.isEmpty() && !contactEventWaitingList.isEmpty()) {
                for (Event evt : eventList) {

                    Integer index = 0;
                    Integer mapSize = eventMap.get(evt.Id).size();
                    Integer numberOfFreePlaces = Integer.valueOf(evt.Max_Person__c) - mapSize;

                    while (numberOfFreePlaces > 0) {

                        if (contactEventWaitingList.size() > index) {
                            attendedContactEventList.add(contactEventWaitingList[index]);
                        }

                        index++;
                        numberOfFreePlaces--;
                    }
                }

                ContactEventTriggerHandler.contactEventChangeStatusToAttended(attendedContactEventList);

                if (!attendedContactEventList.isEmpty()) {
                    update attendedContactEventList;
                }
            }
        }
    }

    public void andFinally() {}

    private static List<Event> getEventList(Set<Id> contactEventIdSet) {

        List<Event> eventList = [
            SELECT Subject, Course__r.Name, Max_Person__c
            FROM Event
            WHERE Id IN :contactEventIdSet
        ];

        return eventList;
    }

    private static List<ContactEvent__c> contactEventAttendedList(Set<Id> eventIdSet) {

        List<ContactEvent__c> contactEventAttendedList = [
            SELECT Name, Status__c, EventId__c, Contact__c, CreatedDate
            FROM ContactEvent__c
            WHERE Status__c = 'Attended'
                AND EventId__c IN :eventIdSet
        ];

        return contactEventAttendedList;
    }

    private static void contactEventChangeStatusToAttended(List<ContactEvent__c> attendedContactEventList) {

        for (ContactEvent__c contEvt : attendedContactEventList) {
            contEvt.Status__c = 'Attended';
        }
    }

    private static void contactEventChangeStatusToWaiting(List<ContactEvent__c> waitingContactEventList) {

        for (ContactEvent__c contEvt : waitingContactEventList) {
            contEvt.Status__c = 'Waiting List';
        }
    }

    private static Set<Id> getEventIdSet(List<Event> eventList) {

        Set<Id> eventIdSet = new Set<Id>();

        for (Event evt : eventList) {
            eventIdSet.add(evt.Id);
        }

        return eventIdSet;
    }

    private static List<ContactEvent__c> contactEventWaitingList(Set<Id> eventIdSet) {

        List<ContactEvent__c> contactEventWaitingList = [
            SELECT Name, Status__c, EventId__c, Contact__c, CreatedDate
            FROM ContactEvent__c
            WHERE Status__c = 'Waiting List'
                AND EventId__c IN :eventIdSet
            ORDER BY CreatedDate
        ];

        return contactEventWaitingList;
    }

    private static Map<String, List<ContactEvent__c>> getEventMap(List<ContactEvent__c> contactEventAttendedList) {

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

        return eventMap;
    }
}