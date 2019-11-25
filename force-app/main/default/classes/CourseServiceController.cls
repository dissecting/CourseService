public without sharing class CourseServiceController {

    @AuraEnabled
    public static CoursesWithDates getCoursesWithDates() {

        CoursesWithDates coursesWithDates = new CoursesWithDates();

        List<Course__c> courseList = [
            SELECT Name, Description__c
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

        String msg = 'Error';
        Boolean isBlankField = String.isBlank(firstName)
            || String.isBlank(lastName)
            || String.isBlank(email)
            || String.isBlank(courseName)
            || courseDate == null;

        if (isBlankField) {
            throw new AuraHandledException(Label.errMsgFieldsMustBeFilled);
        } else {

            Boolean isCorrectEmail = (Pattern.matches(Label.emailPattern, email));

            if (!isCorrectEmail) {
                throw new AuraHandledException(Label.errMsgIncorrectEmail);
            }

            List<Contact> contactList = [
                SELECT Email
                FROM Contact
                WHERE Email = :email
                LIMIT 1
            ];

            List<Event> eventList = [
                SELECT Course__r.Name, ActivityDate
                FROM Event
                WHERE Course__r.Name = :courseName
                    AND ActivityDate = :courseDate
            ];

            Contact newContact = new Contact(
                FirstName = firstName,
                LastName = lastName,
                Email = email
            );

            if (contactList.isEmpty()) {
                insert newContact;
            } else {
                contactList[0].FirstName = firstName;
                contactList[0].LastName = lastName;
                contactList[0].Email = email;

                update contactList;
            }

            if (!eventList.isEmpty()) {
                List<Contact> newContactList = [
                    SELECT Email
                    FROM Contact
                    WHERE Email = :email
                    LIMIT 1
                ];

                List<ContactEvent__c> contactEventList = [
                    SELECT Contact__c
                    FROM ContactEvent__c
                    WHERE Contact__c = :newContactList[0].Id
                ];

                if (contactEventList.isEmpty()) {
                    ContactEvent__c newContactEvent = new ContactEvent__c(
                        Contact__c = newContactList[0].Id,
                        Name = email.right(30) + '-' + courseName.right(30),
                        EventId__c = eventList[0].Id,
                        Status__c = 'Waiting List'
                    );

                    insert newContactEvent;
                } else {
                    throw new AuraHandledException('This contact already been registered');
                }
            } else {
                throw new AuraHandledException(msg);
            }
        }
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