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
