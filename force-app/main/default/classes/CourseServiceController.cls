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
        ];

        List<Date> courseDateList = new List<Date>();
        List<String> courseNameList = new List<String>();

        for (Event evt : eventList) {
            coursesWithDates.courseDateList.add(evt.ActivityDate);
        }

        for (Course__c course : courseList) {
            coursesWithDates.courseNameList.add(course.Name);
        }

        return coursesWithDates;
    }

    @AuraEnabled
    public static String registerCourseContact(String firstName,
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

            List<Contact> contactList = [
                SELECT Email
                FROM Contact
                WHERE Email = : email
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

            try {
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
                        WHERE Email = : email
                        LIMIT 1
                    ];
                    ContactEvent__c newContactEvent = new ContactEvent__c(
                        Contact__c = newContactList[0].Id,
                        Name = lastName.right(30) + '-' + courseName.right(30),
                        EventId__c = eventList[0].Id,
                        Status__c = 'Waiting List'
                    );

                    insert newContactEvent;

                    msg = 'You successfully registered';
                } else {
                    throw new AuraHandledException(msg);
                }

            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }

        }

        return msg;
    }

    public class CoursesWithDates {

        @AuraEnabled
        public List<Date> courseDateList { get; set; }
        @AuraEnabled
        public List<String> courseNameList { get; set; }

        public CoursesWithDates() {
            this.courseDateList = new List<Date>();
            this.courseNameList = new List<String>();
        }
    }

}