({
    handleInit : function(component) {
        var action = component.get("c.getCoursesWithDates");
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                component.set("v.courseDateMap", response.getReturnValue().courseDateMap);
                var courseList = [];
                for (var i = 0; i < response.getReturnValue().courseNameList.length; i++) {
                    courseList.push({
                        label:  response.getReturnValue().courseNameList[i],
                        value:  response.getReturnValue().courseNameList[i]
                    });
                }
                component.set("v.courseNameList", courseList);
            } else if (state === "ERROR") {
                var errors = response.getError();
                this.handleShowToast(component, state, errors[0].message);
                console.error(errors);
            }
        });
        $A.enqueueAction(action);
    },

    handleShowToast: function(component, msgType, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": msgType === "SUCCESS" ? "Success!": "Error!",
            "type": msgType === "SUCCESS" ? "success": "error",
            "message": msg
        });
        toastEvent.fire();
    },

    handleChange: function (component, selectedOptionValue) {
        component.set("v.courseName", selectedOptionValue);
        var courseDateMap = component.get("v.courseDateMap");
        var selectedCourseDate = courseDateMap[selectedOptionValue];

        var picker = component.get("v.picker");
        if (picker != null) {
            picker.destroy();
        }

        selectedCourseDate ? component.set("v.isUnassigned", false) : component.set("v.isUnassigned", true);

        var enabledDatesList = [];
        var toDay = new Date();

        for (var i = 0; i < selectedCourseDate.length; i++) {
            var isGreaterThenToDay = Number(selectedCourseDate[i].split("-")[0]) >= toDay.getFullYear()
                && Number(selectedCourseDate[i].split("-")[1]) >= Number(toDay.getMonth() + 1)
                && Number(selectedCourseDate[i].split("-")[2]) >= toDay.getDate();

            var monthIsGreaterThenToDay = Number(selectedCourseDate[i].split("-")[0]) >= toDay.getFullYear()
                && Number(selectedCourseDate[i].split("-")[1]) > Number(toDay.getMonth() + 1);

            var yearIsGreaterThenToDay = Number(selectedCourseDate[i].split("-")[0]) > toDay.getFullYear();

            if (isGreaterThenToDay || monthIsGreaterThenToDay || yearIsGreaterThenToDay) {
                enabledDatesList.push(selectedCourseDate[i]);
            }
        }

        picker = new Pikaday({
            field: document.getElementById("dateId"),
            disableDayFn: function(theDate) {
                var dateFormated = theDate.getFullYear()
                    + "-" + (theDate.getMonth() + 1)
                    + "-" + (theDate.getDate() < 10 ? "0" + theDate.getDate() : theDate.getDate());
                var isEnabled = enabledDatesList.includes(dateFormated);

                return !isEnabled;
            }
        });

        component.set("v.picker", picker);
    },

    handleChangeDate: function (component) {
        var months = {
            "Jan" : "01",
            "Feb" : "02",
            "Mar" : "03",
            "Apr" : "04",
            "May" : "05",
            "Jun" : "06",
            "Jul" : "07",
            "Aug" : "08",
            "Sep" : "09",
            "Oct" : "10",
            "Nov" : "11",
            "Dec" : "12"
        }
        var newDate = document.getElementById("dateId").value.split(" ")[3] + "-" +
            months[document.getElementById("dateId").value.split(" ")[1]] + "-" +
            document.getElementById("dateId").value.split(" ")[2];
        component.set("v.courseDate", newDate);
    },

    handleSubmit: function (component) {
        var firstName = component.get("v.firstName");
        var lastName = component.get("v.lastName");
        var email = component.get("v.email");
        var courseName = component.get("v.courseName");
        var courseDate = component.get("v.courseDate");
        var action = component.get("c.registerCourseContact");
        action.setParams({
            firstName: firstName,
            lastName: lastName,
            email: email,
            courseName: courseName,
            courseDate: courseDate
        });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var msgSuccess = "You successfully registered";
                this.handleShowToast(component, state, msgSuccess);
            } else if (state === "ERROR") {
                var errors = response.getError();
                this.handleShowToast(component, state, errors[0].message);
                console.error(JSON.stringify(errors));
            }
        });
        $A.enqueueAction(action);
    }
})
