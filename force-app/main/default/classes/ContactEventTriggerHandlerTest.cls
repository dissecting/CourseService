@isTest
private class ContactEventTriggerHandlerTest {
    @testSetup
    private static void prepareData() {
        Course__c course = new Course__c (
            Name = 'TestCourse'
        );

        insert course;

        Event event = new Event (
            OwnerId = UserInfo.getUserId(),
            Subject = 'Lesson',
            Max_Person__c = 3,
            StartDateTime = DateTime.now(),
            EndDateTime = DateTime.now(),
            Course__r = course
        );

        insert event;

        List<Contact> contactList = new List<Contact>();
        Contact firstContact = new Contact (
            LastName = 'TestName1',
            Email = 'test1@gmail.com'
        );
        contactList.add(firstContact);
        Contact secondContact = new Contact (
            LastName = 'TestName2',
            Email = 'test2@gmail.com'
        );
        contactList.add(secondContact);
        Contact thirdContact = new Contact (
            LastName = 'TestName3',
            Email = 'test3@gmail.com'
        );
        contactList.add(thirdContact);
        Contact fourthContact = new Contact (
            LastName = 'TestName4',
            Email = 'test4@gmail.com'
        );
        contactList.add(fourthContact);

        insert contactList;
    }

    @isTest
    private static void testInsertContactEvent() {

        List<Event> eventList = [
            SELECT Subject, Course__r.Name, Max_Person__c
            FROM Event
        ];

        List<Course__c> courseList = [
            SELECT Name
            FROM Course__c
        ];

        List<Contact> contactList = [
            SELECT LastName, Email
            FROM Contact
        ];

        ContactEvent__c firstContactEvent = new ContactEvent__c(
            Contact__c = contactList[0].Id,
            Name = contactList[0].Email.right(30) + '-' + courseList[0].Name.right(30),
            EventId__c = eventList[0].Id,
            Status__c = 'Attended'
        );

        ContactEvent__c secondContactEvent = new ContactEvent__c(
            Contact__c = contactList[1].Id,
            Name = contactList[1].Email.right(30) + '-' + courseList[0].Name.right(30),
            EventId__c = eventList[0].Id,
            Status__c = 'Attended'
        );

        ContactEvent__c thirdContactEvent = new ContactEvent__c(
            Contact__c = contactList[2].Id,
            Name = contactList[2].Email.right(30) + '-' + courseList[0].Name.right(30),
            EventId__c = eventList[0].Id,
            Status__c = 'Attended'
        );

        ContactEvent__c fourthContactEvent = new ContactEvent__c(
            Contact__c = contactList[3].Id,
            Name = contactList[3].Email.right(30) + '-' + courseList[0].Name.right(30),
            EventId__c = eventList[0].Id,
            Status__c = 'Attended'
        );

        List<ContactEvent__c> newContactEventList = new List<ContactEvent__c>();
        newContactEventList.add(firstContactEvent);
        newContactEventList.add(secondContactEvent);
        newContactEventList.add(thirdContactEvent);
        newContactEventList.add(fourthContactEvent);

        Test.startTest();
        insert newContactEventList;
        Test.stopTest();

        List<ContactEvent__c> contactEventAttendedList = [
            SELECT Name, Status__c, EventId__c, Contact__c, CreatedDate
            FROM ContactEvent__c
            WHERE Status__c = 'Attended'
        ];

        List<ContactEvent__c> contactEventWaitingList = [
            SELECT Name, Status__c, EventId__c, Contact__c, CreatedDate
            FROM ContactEvent__c
            WHERE Status__c = 'Waiting List'
        ];

        System.assertEquals(3, contactEventAttendedList.size());
        System.assertEquals(1, contactEventWaitingList.size());
    }

    @isTest
    private static void testInsertSingleNewContactEvent() {

        List<Event> eventList = [
            SELECT Subject, Course__r.Name, Max_Person__c
            FROM Event
        ];

        List<Course__c> courseList = [
            SELECT Name
            FROM Course__c
        ];

        List<Contact> contactList = [
            SELECT LastName, Email
            FROM Contact
        ];

        ContactEvent__c contactEvent = new ContactEvent__c(
            Contact__c = contactList[0].Id,
            Name = contactList[0].Email.right(30) + '-' + courseList[0].Name.right(30),
            EventId__c = eventList[0].Id,
            Status__c = 'Attended'
        );

        ContactEvent__c newContactEvent = new ContactEvent__c(
            Contact__c = contactList[1].Id,
            Name = contactList[1].Email.right(30) + '-' + courseList[0].Name.right(30),
            EventId__c = eventList[0].Id,
            Status__c = 'Attended'
        );

        List<ContactEvent__c> oldContactEventList = new List<ContactEvent__c>();
        List<ContactEvent__c> newContactEventList = new List<ContactEvent__c>();
        newContactEventList.add(newContactEvent);
        oldContactEventList.add(contactEvent);

        insert oldContactEventList;

        Test.startTest();
        insert newContactEventList;
        Test.stopTest();

        List<ContactEvent__c> contactEventAttendedList = [
            SELECT Name, Status__c, EventId__c, Contact__c, CreatedDate
            FROM ContactEvent__c
            WHERE Status__c = 'Attended'
        ];

        List<ContactEvent__c> contactEventWaitingList = [
            SELECT Name, Status__c, EventId__c, Contact__c, CreatedDate
            FROM ContactEvent__c
            WHERE Status__c = 'Waiting List'
        ];

        System.assertEquals(2, contactEventAttendedList.size());
        System.assertEquals(0, contactEventWaitingList.size());
    }

    @isTest
    private static void testInsertNextContactEvent() {

        List<Event> eventList = [
            SELECT Subject, Course__r.Name, Max_Person__c
            FROM Event
        ];

        List<Course__c> courseList = [
            SELECT Name
            FROM Course__c
        ];

        List<Contact> contactList = [
            SELECT LastName, Email
            FROM Contact
        ];

        ContactEvent__c firstContactEvent = new ContactEvent__c(
            Contact__c = contactList[0].Id,
            Name = contactList[0].Email.right(30) + '-' + courseList[0].Name.right(30),
            EventId__c = eventList[0].Id,
            Status__c = 'Waiting List'
        );

        ContactEvent__c secondContactEvent = new ContactEvent__c(
            Contact__c = contactList[1].Id,
            Name = contactList[1].Email.right(30) + '-' + courseList[0].Name.right(30),
            EventId__c = eventList[0].Id,
            Status__c = 'Attended'
        );

        ContactEvent__c thirdContactEvent = new ContactEvent__c(
            Contact__c = contactList[2].Id,
            Name = contactList[2].Email.right(30) + '-' + courseList[0].Name.right(30),
            EventId__c = eventList[0].Id,
            Status__c = 'Attended'
        );

        ContactEvent__c fourthContactEvent = new ContactEvent__c(
            Contact__c = contactList[3].Id,
            Name = contactList[3].Email.right(30) + '-' + courseList[0].Name.right(30),
            EventId__c = eventList[0].Id,
            Status__c = 'Attended'
        );

        List<ContactEvent__c> newContactEventList = new List<ContactEvent__c>();
        List<ContactEvent__c> nextContactEventList = new List<ContactEvent__c>();
        newContactEventList.add(firstContactEvent);
        newContactEventList.add(secondContactEvent);
        newContactEventList.add(thirdContactEvent);
        nextContactEventList.add(fourthContactEvent);

        Test.startTest();
        insert newContactEventList;
        insert nextContactEventList;
        Test.stopTest();

        List<ContactEvent__c> contactEventAttendedList = [
            SELECT Name, Status__c, EventId__c, Contact__c, CreatedDate
            FROM ContactEvent__c
            WHERE Status__c = 'Attended'
        ];

        List<ContactEvent__c> contactEventWaitingList = [
            SELECT Name, Status__c, EventId__c, Contact__c, CreatedDate
            FROM ContactEvent__c
            WHERE Status__c = 'Waiting List'
        ];

        System.assertEquals(3, contactEventAttendedList.size());
        System.assertEquals(1, contactEventWaitingList.size());
    }

    @isTest
    private static void testUpdateContactEvent() {

        List<Event> eventList = [
            SELECT Subject, Course__r.Name, Max_Person__c
            FROM Event
        ];

        List<Course__c> courseList = [
            SELECT Name
            FROM Course__c
        ];

        List<Contact> contactList = [
            SELECT LastName, Email
            FROM Contact
        ];

        ContactEvent__c firstContactEvent = new ContactEvent__c(
            Contact__c = contactList[0].Id,
            Name = contactList[0].Email.right(30) + '-' + courseList[0].Name.right(30),
            EventId__c = eventList[0].Id,
            Status__c = 'Attended'
        );

        ContactEvent__c secondContactEvent = new ContactEvent__c(
            Contact__c = contactList[1].Id,
            Name = contactList[1].Email.right(30) + '-' + courseList[0].Name.right(30),
            EventId__c = eventList[0].Id,
            Status__c = 'Attended'
        );

        ContactEvent__c thirdContactEvent = new ContactEvent__c(
            Contact__c = contactList[2].Id,
            Name = contactList[2].Email.right(30) + '-' + courseList[0].Name.right(30),
            EventId__c = eventList[0].Id,
            Status__c = 'Attended'
        );

        ContactEvent__c fourthContactEvent = new ContactEvent__c(
            Contact__c = contactList[3].Id,
            Name = contactList[3].Email.right(30) + '-' + courseList[0].Name.right(30),
            EventId__c = eventList[0].Id,
            Status__c = 'Waiting List'
        );

        List<ContactEvent__c> newContactEventList = new List<ContactEvent__c>();
        newContactEventList.add(firstContactEvent);
        newContactEventList.add(secondContactEvent);
        newContactEventList.add(thirdContactEvent);
        newContactEventList.add(fourthContactEvent);
        insert newContactEventList;

        Test.startTest();

        List<ContactEvent__c> contactEventList = [
            SELECT Name, Status__c, EventId__c, Contact__c, CreatedDate
            FROM ContactEvent__c
            WHERE Contact__c = :contactList[0].Id
        ];

        contactEventList[0].Status__c = 'Waiting List';

        update contactEventList;

        Test.stopTest();

        List<ContactEvent__c> contactEventAttendedList = [
            SELECT Name, Status__c, EventId__c, Contact__c, CreatedDate
            FROM ContactEvent__c
            WHERE Status__c = 'Attended'
        ];

        List<ContactEvent__c> contactEventWaitingList = [
            SELECT Name, Status__c, EventId__c, Contact__c, CreatedDate
            FROM ContactEvent__c
            WHERE Status__c = 'Waiting List'
        ];

        List<ContactEvent__c> contactEventUpdatedList = [
            SELECT Name, Status__c, EventId__c, Contact__c, CreatedDate
            FROM ContactEvent__c
            WHERE Contact__c = :contactList[3].Id
                AND Status__c = 'Attended'
        ];

        System.assertEquals(3, contactEventAttendedList.size());
        System.assertEquals(1, contactEventWaitingList.size());
        System.assertEquals(1, contactEventUpdatedList.size());
    }

    @isTest
    private static void testErrorUpdateContactEvent() {

        List<Event> eventList = [
            SELECT Subject, Course__r.Name, Max_Person__c
            FROM Event
        ];

        List<Course__c> courseList = [
            SELECT Name
            FROM Course__c
        ];

        List<Contact> contactList = [
            SELECT LastName, Email
            FROM Contact
        ];

        ContactEvent__c firstContactEvent = new ContactEvent__c(
            Contact__c = contactList[0].Id,
            Name = contactList[0].Email.right(30) + '-' + courseList[0].Name.right(30),
            EventId__c = eventList[0].Id,
            Status__c = 'Attended'
        );

        ContactEvent__c secondContactEvent = new ContactEvent__c(
            Contact__c = contactList[1].Id,
            Name = contactList[1].Email.right(30) + '-' + courseList[0].Name.right(30),
            EventId__c = eventList[0].Id,
            Status__c = 'Attended'
        );

        ContactEvent__c thirdContactEvent = new ContactEvent__c(
            Contact__c = contactList[2].Id,
            Name = contactList[2].Email.right(30) + '-' + courseList[0].Name.right(30),
            EventId__c = eventList[0].Id,
            Status__c = 'Attended'
        );

        ContactEvent__c fourthContactEvent = new ContactEvent__c(
            Contact__c = contactList[3].Id,
            Name = contactList[3].Email.right(30) + '-' + courseList[0].Name.right(30),
            EventId__c = eventList[0].Id,
            Status__c = 'Waiting List'
        );

        List<ContactEvent__c> newContactEventList = new List<ContactEvent__c>();
        newContactEventList.add(firstContactEvent);
        newContactEventList.add(secondContactEvent);
        newContactEventList.add(thirdContactEvent);
        newContactEventList.add(fourthContactEvent);
        insert newContactEventList;

        Test.startTest();

        List<ContactEvent__c> contactEventList = [
            SELECT Name, Status__c, EventId__c, Contact__c, CreatedDate
            FROM ContactEvent__c
            WHERE Contact__c = :contactList[3].Id
        ];

        contactEventList[0].Status__c = 'Attended';

        try {
            update contactEventList;
        } catch (DmlException e) {
            System.assertNotEquals(null, e.getMessage());
        }

        Test.stopTest();
    }

    @isTest
    private static void testDeleteContactEvent() {

        List<Event> eventList = [
            SELECT Subject, Course__r.Name, Max_Person__c
            FROM Event
        ];

        List<Course__c> courseList = [
            SELECT Name
            FROM Course__c
        ];

        List<Contact> contactList = [
            SELECT LastName, Email
            FROM Contact
        ];

        List<ContactEvent__c> newContactEventList = new List<ContactEvent__c>();

        ContactEvent__c firstContactEvent = new ContactEvent__c(
            Contact__c = contactList[0].Id,
            Name = contactList[0].Email.right(30) + '-' + courseList[0].Name.right(30),
            EventId__c = eventList[0].Id,
            Status__c = 'Attended'
        );
        newContactEventList.add(firstContactEvent);

        ContactEvent__c secondContactEvent = new ContactEvent__c(
            Contact__c = contactList[1].Id,
            Name = contactList[1].Email.right(30) + '-' + courseList[0].Name.right(30),
            EventId__c = eventList[0].Id,
            Status__c = 'Attended'
        );
        newContactEventList.add(secondContactEvent);

        ContactEvent__c thirdContactEvent = new ContactEvent__c(
            Contact__c = contactList[2].Id,
            Name = contactList[2].Email.right(30) + '-' + courseList[0].Name.right(30),
            EventId__c = eventList[0].Id,
            Status__c = 'Attended'
        );
        newContactEventList.add(thirdContactEvent);

        ContactEvent__c fourthContactEvent = new ContactEvent__c(
            Contact__c = contactList[3].Id,
            Name = contactList[3].Email.right(30) + '-' + courseList[0].Name.right(30),
            EventId__c = eventList[0].Id,
            Status__c = 'Attended'
        );
        newContactEventList.add(fourthContactEvent);

        insert newContactEventList;

        List<ContactEvent__c> contactEventList = [
            SELECT Name, Status__c, EventId__c, Contact__c, CreatedDate
            FROM ContactEvent__c
            WHERE Status__c = 'Attended'
        ];

        Test.startTest();
        List<ContactEvent__c> deletedList = new List<ContactEvent__c>();
        deletedList.add(contactEventList[0]);
        deletedList.add(contactEventList[1]);

        delete deletedList;
        Test.stopTest();

        List<ContactEvent__c> contactEventAttendedList = [
            SELECT Name, Status__c, EventId__c, Contact__c, CreatedDate
            FROM ContactEvent__c
            WHERE Status__c = 'Attended'
        ];

        List<ContactEvent__c> contactEventWaitingList = [
            SELECT Name, Status__c, EventId__c, Contact__c, CreatedDate
            FROM ContactEvent__c
            WHERE Status__c = 'Waiting List'
        ];

        System.assertEquals(2, contactEventAttendedList.size());
        System.assertEquals(0, contactEventWaitingList.size());
    }
}