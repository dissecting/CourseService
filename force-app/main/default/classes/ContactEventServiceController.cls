public with sharing class ContactEventServiceController {

    @AuraEnabled
    public static ContactEventsWithIndexes getContactEvents(Id eventId) {

        ContactEventsWithIndexes contactEventsWithIndexes = new ContactEventsWithIndexes();
        Map<Integer, Object> contactEventObjectMap = new Map<Integer, Object>();
        Integer index = 0;

        List<ContactEvent__c> contactEventList = [
            SELECT Name, Status__c, EventId__c
            FROM ContactEvent__c
            WHERE EventId__c = :eventId
        ];

        for (ContactEvent__c contEvt : contactEventList) {
            contactEventObjectMap.put(index, contEvt);
            index++;
        }

        contactEventsWithIndexes.contactEventList = contactEventList;
        contactEventsWithIndexes.contactEventObjectMap = contactEventObjectMap;

        return contactEventsWithIndexes;
    }

    @AuraEnabled
    public static void setContactEvent(String firstName,
                                    String lastName,
                                    String email,
                                    Id eventId) {

        Boolean isBlankField = String.isBlank(firstName)
            || String.isBlank(lastName)
            || String.isBlank(email)
            || eventId == null;

        if (isBlankField) {
            throw new AuraHandledException(Label.errMsgFieldsMustBeFilled);
        } else {

            Boolean isCorrectEmail = Pattern.matches(Label.emailPattern, email);
            Boolean isEmptyContactEventList = ContactEventServiceController.getContactEventList(eventId, email).isEmpty();
            List<Contact> contactList = ContactEventServiceController.getContactList(email);
            List<Contact> newContactList = new List<Contact>();

            if (!isCorrectEmail) {
                throw new AuraHandledException(Label.errMsgIncorrectEmail);
            }

            if (contactList.isEmpty()) {
                ContactEventServiceController.insertContact(firstName, lastName, email);
            } else {
                ContactEventServiceController.updateContact(contactList, firstName, lastName, email);
            }

            if (isEmptyContactEventList) {
                newContactList = ContactEventServiceController.getContactList(email);
                ContactEventServiceController.insertContactEvent(
                    eventId,
                    email,
                    ContactEventServiceController.getCourseName(eventId),
                    newContactList[0].Id
                );
            } else {
                throw new AuraHandledException(Label.msgContactAlreadyRegistered);
            }
        }
    }

    @AuraEnabled
    public static void deleteContactEvent(Id deletedId) {

        List<ContactEvent__c> contactEventList = [
            SELECT Id
            FROM ContactEvent__c
            WHERE Id = :deletedId
        ];

        delete contactEventList;
    }

    @AuraEnabled
    public static void updateContactEvent(Id updatedId, String newStatus) {

        List<ContactEvent__c> contactEventList = [
            SELECT Status__c
            FROM ContactEvent__c
            WHERE Id = :updatedId
        ];

        contactEventList[0].Status__c = newStatus;

        try {
            update contactEventList;
        } catch (DMLException e){
            throw new AuraHandledException('Max member size!');
        }
    }

    private static List<Contact> getContactList(String email) {
        List<Contact> contactList = [
            SELECT Email
            FROM Contact
            WHERE Email = :email
            LIMIT 1
        ];

        return contactList;
    }

    private static void insertContact(String firstName, String lastName, String email) {
        Contact newContact = new Contact(
            FirstName = firstName,
            LastName = lastName,
            Email = email
        );

        insert newContact;
    }

    private static void updateContact(List<Contact> contactList, String firstName, String lastName, String email) {
        contactList[0].FirstName = firstName;
        contactList[0].LastName = lastName;
        contactList[0].Email = email;

        update contactList;
    }

    private static void insertContactEvent(Id eventId, String email, String courseName, Id contactId) {
        ContactEvent__c newContactEvent = new ContactEvent__c(
            Contact__c = contactId,
            Name = email.right(30) + '-' + courseName.right(30),
            EventId__c = eventId,
            Status__c = 'Waiting List'
        );

        insert newContactEvent;
    }

    private static String getCourseName(Id eventId) {

        Event event = [
            SELECT Course__r.Name
            FROM Event
            WHERE Id = :eventId
            LIMIT 1
        ];

        return event.Course__r.Name;
    }

    private static List<ContactEvent__c> getContactEventList(Id eventId, String email) {
        List<ContactEvent__c> contactEventList = [
            SELECT Contact__c, EventId__c
            FROM ContactEvent__c
            WHERE Contact__r.Email = :email
                AND EventId__c = :eventId
            LIMIT 1
        ];

        return contactEventList;
    }

    public class ContactEventsWithIndexes {

        @AuraEnabled
        public Map<Integer, Object> contactEventObjectMap { get; set; }
        @AuraEnabled
        public List<ContactEvent__c> contactEventList { get; set; }

        public ContactEventsWithIndexes() {
            this.contactEventObjectMap = new Map<Integer, Object>();
            this.contactEventList = new List<ContactEvent__c>();
        }
    }

}