@isTest
private class CourseServiceControllerTest {

    @testSetup
    static void prepareData() {
        Course__c course = new Course__c (
            Name = 'TestCourse'
        );

        insert course;

        Event event = new Event (
            OwnerId = UserInfo.getUserId(),
            Subject = 'Lesson',
            Max_Person__c = 2,
            StartDateTime = System.today() + 1,
            EndDateTime = System.today() + 2,
            Course__r = course
        );

        insert event;
    }

    @isTest
    static void testRegisterCourseContact() {

        List<Event> eventList = [
            SELECT Subject, Course__r.Name, Max_Person__c, StartDateTime
            FROM Event
        ];

        List<Course__c> courseList = [
            SELECT Name
            FROM Course__c
        ];

        List<Contact> contactList = new List<Contact>();
        Contact firstContact = new Contact (
            FirstName = 'TestName1',
            LastName = 'TestName1',
            Email = 'test1@gmail.com'
        );
        contactList.add(firstContact);

        Test.startTest();
        Date eventDate = Date.valueOf(eventList[0].StartDateTime);
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
        System.assertEquals(1, contactEventAttendedList.size());
    }
}