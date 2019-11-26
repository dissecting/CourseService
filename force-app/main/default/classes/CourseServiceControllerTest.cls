@isTest
private class CourseServiceControllerTest {

    @testSetup
    private static void prepareData() {
        Course__c course = new Course__c (
            Name = 'TestCourse'
        );

        insert course;

        List<Event> eventList = new List<Event>();
        Event firstEvent = new Event (
            OwnerId = UserInfo.getUserId(),
            Subject = 'Lesson',
            Max_Person__c = 2,
            ActivityDate = System.today() + 1,
            StartDateTime = System.today() + 1,
            EndDateTime = System.today() + 2,
            Course__c = course.Id
        );
        eventList.add(firstEvent);

        Event secondEvent = new Event (
            OwnerId = UserInfo.getUserId(),
            Subject = 'Lesson',
            Max_Person__c = 3,
            ActivityDate = System.today() + 3,
            StartDateTime = System.today() + 3,
            EndDateTime = System.today() + 4,
            Course__c = course.Id
        );
        eventList.add(secondEvent);

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

        insert contactList;

        ContactEvent__c contactEvent = new ContactEvent__c (
            Name = 'TestEvent1',
            Status__c = 'Attended',
            EventId__c = firstEvent.Id,
            Contact__c = secondContact.Id
        );

        insert contactEvent;
    }

    @isTest
    private static void testRegisterCourseContact() {

        List<Event> eventList = [
            SELECT Subject, Course__r.Name, Max_Person__c, ActivityDate
            FROM Event
        ];

        List<Course__c> courseList = [
            SELECT Name
            FROM Course__c
        ];

        List<Contact> contactList = new List<Contact>();
        Contact testContact = new Contact (
            FirstName = 'TestName1',
            LastName = 'TestName1',
            Email = 'test1@gmail.com'
        );
        contactList.add(testContact);

        Test.startTest();
        Date eventDate = eventList[0].ActivityDate;
        CourseServiceController.registerCourseContact(
            contactList[0].FirstName,
            contactList[0].LastName,
            contactList[0].Email,
            courseList[0].Name,
            eventDate
        );
        Test.stopTest();

        List<Contact> newContactList = new List<Contact>();
        newContactList = [
            SELECT FirstName, LastName, Email
            FROM Contact
            WHERE Email = 'test1@gmail.com'
        ];
        List<ContactEvent__c> contactEventAttendedList = [
            SELECT Name, Status__c, EventId__c, Contact__c, CreatedDate
            FROM ContactEvent__c
            WHERE Status__c = 'Attended'
        ];

        System.assertEquals(1, newContactList.size());
        System.assertEquals(2, contactEventAttendedList.size());
    }

    @isTest
    private static void testRegisterCourseExistContact() {

        List<Event> eventList = [
            SELECT Subject, Course__r.Name, Max_Person__c, ActivityDate
            FROM Event
        ];

        List<Course__c> courseList = [
            SELECT Name
            FROM Course__c
        ];

        List<Contact> contactList = new List<Contact>();
        Contact testContact = new Contact (
            FirstName = 'TestName123',
            LastName = 'TestName123',
            Email = 'test123@gmail.com'
        );
        contactList.add(testContact);

        Test.startTest();
        Date eventDate = eventList[0].ActivityDate;
        CourseServiceController.registerCourseContact(
            contactList[0].FirstName,
            contactList[0].LastName,
            contactList[0].Email,
            courseList[0].Name,
            eventDate
        );
        Test.stopTest();

        List<Contact> newContactList = new List<Contact>();
        newContactList = [
            SELECT FirstName, LastName, Email
            FROM Contact
            WHERE Email = 'test123@gmail.com'
        ];

        System.assertEquals(1, newContactList.size());
    }

    @isTest
    private static void testGetCoursesWithDates() {

        CourseServiceController.CoursesWithDates coursesWithDates = new CourseServiceController.CoursesWithDates();
        List<Event> eventList = [
            SELECT Subject, Course__r.Name, Max_Person__c, ActivityDate
            FROM Event
        ];

        List<Course__c> courseList = [
            SELECT Name
            FROM Course__c
        ];

        Test.startTest();
        coursesWithDates = CourseServiceController.getCoursesWithDates();
        Test.stopTest();

        System.assertEquals(1, coursesWithDates.courseDateMap.size());
        System.assertEquals(1, coursesWithDates.courseNameList.size());
        System.assertEquals(courseList[0].Name, coursesWithDates.courseNameList[0]);
        System.assertEquals(eventList[0].ActivityDate, coursesWithDates.courseDateMap.get(courseList[0].Name)[0]);
    }

    @isTest
    private static void testInsertNotFilledRecords() {

        String firstName;
        String lastName;
        String email;
        String courseName;
        Date courseDate;

        Test.startTest();
        try {
            CourseServiceController.registerCourseContact(
                firstName,
                lastName,
                email,
                courseName,
                courseDate
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

        List<Course__c> courseList = [
            SELECT Name
            FROM Course__c
        ];

        List<ContactEvent__c> contactEventAttendedList = [
            SELECT Name, Status__c, EventId__c, Contact__c, CreatedDate
            FROM ContactEvent__c
            WHERE Status__c = 'Attended'
        ];

        List<Contact> contactList = new List<Contact>();
        Contact testContact = new Contact (
            FirstName = 'TestName999',
            LastName = 'TestName999',
            Email = 'test999'
        );
        contactList.add(testContact);

        Test.startTest();
        try {
            Date eventDate = eventList[0].ActivityDate;
            CourseServiceController.registerCourseContact(
                contactList[0].FirstName,
                contactList[0].LastName,
                contactList[0].Email,
                courseList[0].Name,
                eventDate
            );
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    private static void testIncorrectRegisterCourseExistContact() {

        List<Event> eventList = [
            SELECT Subject, Course__r.Name, Max_Person__c, ActivityDate
            FROM Event
        ];

        List<Course__c> courseList = [
            SELECT Name
            FROM Course__c
        ];

        List<ContactEvent__c> contactEventAttendedList = [
            SELECT Name, Status__c, EventId__c, Contact__c, CreatedDate
            FROM ContactEvent__c
            WHERE Status__c = 'Attended'
        ];

        List<Contact> contactList = new List<Contact>();
        Contact testContact = new Contact (
            FirstName = 'TestName999',
            LastName = 'TestName999',
            Email = 'test999@gmail.com'
        );
        contactList.add(testContact);

        Test.startTest();
        try {
            Date eventDate = eventList[0].ActivityDate;
            CourseServiceController.registerCourseContact(
                contactList[0].FirstName,
                contactList[0].LastName,
                contactList[0].Email,
                courseList[0].Name,
                eventDate
            );
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }
}