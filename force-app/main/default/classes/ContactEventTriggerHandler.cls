public without sharing class ContactEventTriggerHandler implements ITrigger {

    public void bulkBefore() {

        if (trigger.isInsert) {

        } else if (trigger.isUpdate) {

        } else if (trigger.isDelete) {

        } else if (trigger.isUndelete) {

        }
    }

    public void bulkAfter() {

        if (trigger.isInsert) {

        } else if (trigger.isUpdate) {

        } else if (trigger.isDelete) {

        } else if (trigger.isUndelete) {

        }
    }

    public void beforeInsert(List<SObject> newlstObj) {

        Map<String, List<ContactEvent__c>> eventMap = new Map<String, List<ContactEvent__c>>();
        List<ContactEvent__c> attendedContactEventList = new List<ContactEvent__c>();
        List<ContactEvent__c> waitingContactEventList = new List<ContactEvent__c>();
        Set<Id> eventIdSet = new Set<Id>();
        Set<Id> contactEventIdSet = new Set<Id>();
        List<ContactEvent__c> newContactEventLst = newlstObj;

        for (ContactEvent__c contEvt : newContactEventLst) {
            contactEventIdSet.add(contEvt.EventId__c);
        }

        List<Event> eventList = [
            SELECT Subject, Course__r.Name, Max_Person__c
            FROM Event
            WHERE Id IN :contactEventIdSet
        ];

        for (Event evt : eventList) {
            eventIdSet.add(evt.Id);
        }

        List<ContactEvent__c> contactEventAttendedList = [
            SELECT Name, Status__c, EventId__c, Contact__c, CreatedDate
            FROM ContactEvent__c
            WHERE Status__c = 'Attended'
                AND EventId__c IN :eventIdSet
        ];

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

            for (ContactEvent__c contEvt : attendedContactEventList) {
                contEvt.Status__c = 'Attended';
            }

            for (ContactEvent__c contEvt : waitingContactEventList) {
                contEvt.Status__c = 'Waiting List';
            }
        }
    }

    public void beforeUpdate(List<SObject> newlstObj, List<SObject> oldlstObj, Map<Id, SObject> newMapObj, Map<Id, SObject> oldMapObj) {

        List<ContactEvent__c> newContactEventLst = newlstObj;
        List<ContactEvent__c> oldContactEventLst = oldlstObj;
        Map<String, List<ContactEvent__c>> eventMap = new Map<String, List<ContactEvent__c>>();
        List<ContactEvent__c> attendedContactEventList = new List<ContactEvent__c>();
        List<ContactEvent__c> waitingContactEventList = new List<ContactEvent__c>();
        Set<Id> eventIdSet = new Set<Id>();
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
            List<Event> eventList = [
                SELECT Subject, Course__r.Name, Max_Person__c
                FROM Event
                WHERE Id IN :contactEventIdSet
            ];

            for (Event evt : eventList) {
                eventIdSet.add(evt.Id);
            }

            List<ContactEvent__c> contactEventAttendedList = [
                SELECT Name, Status__c, EventId__c, Contact__c, CreatedDate
                FROM ContactEvent__c
                WHERE Status__c = 'Attended'
                    AND EventId__c IN :eventIdSet
            ];

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

                    if (!eventMap.isEmpty()) {
                        Integer index = 0;
                        Integer mapSize = eventMap.get(evt.Id).size();

                        while (evt.Max_Person__c < mapSize + 1) {

                            if (newContactEventLst.size() > index) {
                                if (newContactEventLst[index].Status__c == 'Waiting List') {
                                    waitingContactEventList.add(newContactEventLst[index]);
                                } else {
                                    throw new TriggerException('Max member size!');
                                }
                            }

                            index++;
                            mapSize--;
                        }

                        while (evt.Max_Person__c > mapSize) {

                            if (newContactEventLst.size() > index) {
                                if (newContactEventLst[index].Status__c == 'Attended') {
                                    attendedContactEventList.add(newContactEventLst[index]);
                                }
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

                for (ContactEvent__c contEvt : attendedContactEventList) {
                    contEvt.Status__c = 'Attended';
                }

                for (ContactEvent__c contEvt : waitingContactEventList) {
                    contEvt.Status__c = 'Waiting List';
                }
            }
        }

    }

    public void beforeDelete(List<SObject> oldlstObj, Map<Id, SObject> oldMapObj) {

    }

    public void afterInsert(List<SObject> newlstObj, Map<Id, SObject> newMapObj) {

    }

    public void afterUpdate(List<SObject> newlstObj, List<SObject> oldlstObj, Map<Id, SObject> newMapObj, Map<Id, SObject> oldMapObj) {

    }

    public void afterDelete(List<SObject> oldlstObj, Map<Id, SObject> oldMapObj) {

        List<ContactEvent__c> oldContactEventLst = oldlstObj;
        List<ContactEvent__c> attendedContactEventList = new List<ContactEvent__c>();
        Set<Id> contactEventIdSet = new Set<Id>();
        Set<Id> eventIdSet = new Set<Id>();
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

            List<Event> eventList = [
                SELECT Subject, Course__r.Name, Max_Person__c
                FROM Event
                WHERE Id IN :contactEventIdSet
            ];

            for (Event evt : eventList) {
                eventIdSet.add(evt.Id);
            }

            List<ContactEvent__c> contactEventWaitingList = [
                SELECT Name, Status__c, EventId__c, Contact__c, CreatedDate
                FROM ContactEvent__c
                WHERE Status__c = 'Waiting List'
                    AND EventId__c IN :eventIdSet
                ORDER BY CreatedDate
            ];

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

                for (ContactEvent__c contEvt : attendedContactEventList) {
                    contEvt.Status__c = 'Attended';
                }

                if (!attendedContactEventList.isEmpty()) {
                    update attendedContactEventList;
                }
            }
        }
    }

    public void andFinally() {

    }
}