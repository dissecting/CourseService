({
    handleInit : function(component) {
        component.set("v.firstDate", null);
        component.set("v.lastDate", null);
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

        if (selectedCourseDate) {
            component.set("v.firstDate", selectedCourseDate[0]);
            component.set("v.lastDate", selectedCourseDate[courseDateMap[selectedOptionValue].length - 1]);
            component.set("v.isUnassigned", false);
        } else {
            component.set("v.isUnassigned", true);
        }
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
                console.error(errors);
            }
        });
        $A.enqueueAction(action);
    }
})
