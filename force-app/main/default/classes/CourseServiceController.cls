public without sharing class CourseServiceController {

    @AuraEnabled
    public static CoursesWithDates getCoursesWithDates() {

        CoursesWithDates coursesWithDates = new CoursesWithDates();

        List<Course__c> courseList = [
            SELECT Name
            FROM Course__c
        ];

        List<Event> eventList = [
            SELECT Course__r.Name, ActivityDate
            FROM Event
            WHERE Course__r.Name != NULL
            ORDER BY ActivityDate
        ];

        for (Event evt : eventList) {
            if (coursesWithDates.courseDateMap.containsKey(evt.Course__r.Name)) {
                List<Date> evtDateList = coursesWithDates.courseDateMap.get(evt.Course__r.Name);
                evtDateList.add(evt.ActivityDate);
                coursesWithDates.courseDateMap.put(evt.Course__r.Name, evtDateList);
            } else {
                coursesWithDates.courseDateMap.put(evt.Course__r.Name, new List<Date> { evt.ActivityDate });
            }
        }

        for (Course__c course : courseList) {
            coursesWithDates.courseNameList.add(course.Name);
        }

        return coursesWithDates;
    }

    @AuraEnabled
    public static void registerCourseContact(String firstName,
                                            String lastName,
                                            String email,
                                            String courseName,
                                            Date courseDate) {

        Boolean isBlankField = String.isBlank(firstName)
            || String.isBlank(lastName)
            || String.isBlank(email)
            || String.isBlank(courseName)
            || courseDate == null;

        if (isBlankField) {
            throw new AuraHandledException(Label.errMsgFieldsMustBeFilled);
        } else {

            Boolean isCorrectEmail = Pattern.matches(Label.emailPattern, email);
            List<Contact> contactList = CourseServiceController.getContactList(email);
            List<Event> eventList = CourseServiceController.getEventList(courseName, courseDate);

            if (!isCorrectEmail) {
                throw new AuraHandledException(Label.errMsgIncorrectEmail);
            }

            Set<Id> eventIdSet = new Set<Id>();

            for (Event evt : eventList) {
                eventIdSet.add(evt.Id);
            }

            if (contactList.isEmpty()) {
                CourseServiceController.insertContact(firstName, lastName, email);
            } else {
                CourseServiceController.updateContact(contactList, firstName, lastName, email);
            }

            if (CourseServiceController.getContactEventList(CourseServiceController.getContactList(email)[0].Id, eventIdSet, email).isEmpty()) {
                CourseServiceController.insertContactEvent(CourseServiceController.getContactList(email)[0].Id, eventList, email, courseName);
            } else {
                throw new AuraHandledException(Label.msgContactAlreadyRegistered);
            }
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

    private static List<Event> getEventList(String courseName, Date courseDate) {
        List<Event> eventList = [
            SELECT Course__r.Name, ActivityDate
            FROM Event
            WHERE Course__r.Name = :courseName
                AND ActivityDate = :courseDate
        ];

        return eventList;
    }

    private static List<ContactEvent__c> getContactEventList(Id contactId, Set<Id> eventIdSet, String email) {
        List<ContactEvent__c> contactEventList = [
            SELECT Contact__c, EventId__c
            FROM ContactEvent__c
            WHERE Contact__c = :contactId
                AND EventId__c IN :eventIdSet
        ];

        return contactEventList;
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

    private static void insertContactEvent(Id contactId, List<Event> eventList, String email, String courseName) {
        ContactEvent__c newContactEvent = new ContactEvent__c(
            Contact__c = contactId,
            Name = email.right(30) + '-' + courseName.right(30),
            EventId__c = eventList[0].Id,
            Status__c = 'Attended'
        );

        insert newContactEvent;
    }

    public class CoursesWithDates {

        @AuraEnabled
        public Map<String, List<Date>> courseDateMap { get; set; }
        @AuraEnabled
        public List<String> courseNameList { get; set; }

        public CoursesWithDates() {
            this.courseDateMap = new Map<String, List<Date>>();
            this.courseNameList = new List<String>();
        }
    }

}