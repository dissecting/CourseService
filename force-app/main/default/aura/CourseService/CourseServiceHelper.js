({
    handleInit : function(component) {
        var action = component.get("c.getCoursesWithDates");
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                component.set("v.courseDateList", response.getReturnValue().courseDateList);
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
    },

    handleSubmit: function (component, firstName, lastName, email, courseName, courseDate) {
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
                var msgSuccess = response.getReturnValue();
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
