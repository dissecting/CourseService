@isTest
private class ContactEventServiceControllerTest {

    @testSetup
    private static void prepareData() {
        Course__c course = new Course__c (
            Name = 'TestCourse'
        );

        insert course;

        List<Event> eventList = new List<Event>();
        Event event = new Event (
            OwnerId = UserInfo.getUserId(),
            Subject = 'Lesson',
            Max_Person__c = 2,
            ActivityDate = System.today() + 1,
            StartDateTime = System.today() + 1,
            EndDateTime = System.today() + 2,
            Course__c = course.Id
        );
        eventList.add(event);

        insert eventList;

        List<Contact> contactList = new List<Contact>();
        Contact firstContact = new Contact (
            FirstName = 'TestName123',
            LastName = 'TestName123',
            Email = 'test123@gmail.com'
        );
        contactList.add(firstContact);

        Contact secondContact = new Contact (
            FirstName = 'TestName999',
            LastName = 'TestName999',
            Email = 'test999@gmail.com'
        );
        contactList.add(secondContact);

        Contact thirdContact = new Contact (
            FirstName = 'Test3',
            LastName = 'Test3',
            Email = 'test3@gmail.com'
        );
        contactList.add(thirdContact);

        Contact fourthContact = new Contact (
            FirstName = 'TestName4',
            LastName = 'TestName4',
            Email = 'TestName4@gmail.com'
        );
        contactList.add(fourthContact);

        insert contactList;

        ContactEvent__c contactEvent = new ContactEvent__c (
            Name = 'TestEvent1',
            Status__c = 'Attended',
            EventId__c = event.Id,
            Contact__c = secondContact.Id
        );

        insert contactEvent;
    }

    @isTest
    private static void testSetContactEvent() {

        List<Event> eventList = [
            SELECT Subject, Course__r.Name, Max_Person__c, ActivityDate
            FROM Event
        ];

        List<Contact> contactList = [
            SELECT FirstName, LastName, Email
            FROM Contact
            WHERE LastName = 'TestName123'
        ];

        Test.startTest();

        ContactEventServiceController.setContactEvent(
            contactList[0].FirstName,
            contactList[0].LastName,
            contactList[0].Email,
            eventList[0].Id
        );

        Test.stopTest();

        List<ContactEvent__c> contactEventAttendedList = [
            SELECT Name, Status__c, EventId__c, Contact__c, CreatedDate
            FROM ContactEvent__c
            WHERE Status__c = 'Attended'
        ];

        System.assertEquals(2, contactEventAttendedList.size());
    }

    @isTest
    private static void testSetContactEventWithNewContact() {

        List<Event> eventList = [
            SELECT Subject, Course__r.Name, Max_Person__c, ActivityDate
            FROM Event
        ];

        List<Contact> contactList = new List<Contact>();
        Contact testContact = new Contact (
            FirstName = 'TestName888',
            LastName = 'TestName888',
            Email = 'test888@gmail.com'
        );
        contactList.add(testContact);

        Test.startTest();

        ContactEventServiceController.setContactEvent(
            contactList[0].FirstName,
            contactList[0].LastName,
            contactList[0].Email,
            eventList[0].Id
        );

        Test.stopTest();

        List<ContactEvent__c> contactEventAttendedList = [
            SELECT Name, Status__c, EventId__c, Contact__c, CreatedDate
            FROM ContactEvent__c
            WHERE Status__c = 'Attended'
        ];

        System.assertEquals(2, contactEventAttendedList.size());
    }

    @isTest
    private static void testGetContactEvents() {

        ContactEventServiceController.ContactEventsWithIndexes contactEventsWithIndexes = new ContactEventServiceController.ContactEventsWithIndexes();
        List<Event> eventList = [
            SELECT Subject, Course__r.Name, Max_Person__c, ActivityDate
            FROM Event
        ];

        List<ContactEvent__c> contactEventList = [
            SELECT Name, Status__c, EventId__c
            FROM ContactEvent__c
            WHERE EventId__c =: eventList[0].Id
        ];

        Test.startTest();
        contactEventsWithIndexes = ContactEventServiceController.getContactEvents(eventList[0].Id);
        Test.stopTest();

        System.assertEquals(1, contactEventsWithIndexes.contactEventObjectMap.size());
        System.assertEquals(1, contactEventsWithIndexes.contactEventList.size());
        System.assertEquals(contactEventList, contactEventsWithIndexes.contactEventList);
        System.assertEquals(contactEventList[0], contactEventsWithIndexes.contactEventObjectMap.get(0));
    }

    @isTest
    private static void testInsertNotFilledRecords() {

        String firstName;
        String lastName;
        String email;
        Id eventId;

        Test.startTest();
        try {
            ContactEventServiceController.setContactEvent(
                firstName,
                lastName,
                email,
                eventId
            );
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    private static void testInputIncorrectEmail() {

        List<Event> eventList = [
            SELECT Subject, Course__r.Name, Max_Person__c, ActivityDate
            FROM Event
        ];

        List<Contact> contactList = [
            SELECT FirstName, LastName, Email
            FROM Contact
            WHERE LastName = 'TestName123'
        ];

        String email = 'test';

        Test.startTest();

        try {
           ContactEventServiceController.setContactEvent(
                contactList[0].FirstName,
                contactList[0].LastName,
                email,
                eventList[0].Id
            );
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage());
        }

        Test.stopTest();
    }

    @isTest
    private static void testIncorrectSetExistContact() {

        List<Event> eventList = [
            SELECT Subject, Course__r.Name, Max_Person__c, ActivityDate
            FROM Event
        ];

        List<Contact> contactList = [
            SELECT FirstName, LastName, Email
            FROM Contact
            WHERE Email = 'test999@gmail.com'
        ];

        Test.startTest();

        try {
            ContactEventServiceController.setContactEvent(
                contactList[0].FirstName,
                contactList[0].LastName,
                contactList[0].Email,
                eventList[0].Id
            );
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage());
        }

        Test.stopTest();
    }

    @isTest
    private static void testDeleteContactEvent() {

        List<ContactEvent__c> contactEventList = [
            SELECT Name, Status__c, EventId__c, Contact__c, CreatedDate
            FROM ContactEvent__c
        ];

        Test.startTest();
        ContactEventServiceController.deleteContactEvent(contactEventList[0].Id);
        Test.stopTest();

        List<ContactEvent__c> newContactEventList = [
            SELECT Name, Status__c, EventId__c, Contact__c, CreatedDate
            FROM ContactEvent__c
        ];

        System.assertEquals(0, newContactEventList.size());
    }

    @isTest
    private static void testUpdateContactEvent() {

        List<ContactEvent__c> contactEventList = [
            SELECT Name, Status__c, EventId__c, Contact__c, CreatedDate
            FROM ContactEvent__c
        ];

        String newStatus = 'Waiting List';

        Test.startTest();
        ContactEventServiceController.updateContactEvent(contactEventList[0].Id, newStatus);
        Test.stopTest();

        List<ContactEvent__c> newContactEventList = [
            SELECT Name, Status__c, EventId__c, Contact__c, CreatedDate
            FROM ContactEvent__c
        ];

        System.assertEquals(1, newContactEventList.size());
    }

    @isTest
    private static void testErrorUpdateContactEvent() {

        List<Contact> contactList = [
            SELECT LastName, Email
            FROM Contact
        ];

        List<Event> eventList = [
            SELECT Subject, Course__r.Name, Max_Person__c
            FROM Event
        ];

        ContactEvent__c contactEvent = new ContactEvent__c(
            Contact__c = contactList[2].Id,
            Name = contactList[2].Email.right(30),
            EventId__c = eventList[0].Id,
            Status__c = 'Attended'
        );

        ContactEvent__c newContactEvent = new ContactEvent__c(
            Contact__c = contactList[3].Id,
            Name = contactList[3].Email.right(30),
            EventId__c = eventList[0].Id,
            Status__c = 'Waiting List'
        );

        List<ContactEvent__c> newContactEventList = new List<ContactEvent__c>();
        newContactEventList.add(contactEvent);
        newContactEventList.add(newContactEvent);

        insert newContactEventList;

        List<ContactEvent__c> contactEventList = [
            SELECT Name, Status__c, EventId__c, Contact__c, CreatedDate
            FROM ContactEvent__c
        ];

        String newStatus = 'Attended';

        Test.startTest();

        try {
            ContactEventServiceController.updateContactEvent(contactEventList[2].Id, newStatus);
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage());
        }

        Test.stopTest();
    }
}