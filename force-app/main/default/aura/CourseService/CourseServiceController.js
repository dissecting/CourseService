({
    doInit: function(component, event, helper) {
        helper.handleInit(component);
    },

    onChange: function (component, event, helper) {
        var selectedOptionValue = event.getParam("value");
        helper.handleChange(component, selectedOptionValue);
    },

    onSubmit: function (component, event, helper) {
        var firstName = component.get("v.firstName");
        var lastName = component.get("v.lastName");
        var email = component.get("v.email");
        var courseName = component.get("v.courseName");
        var courseDate = component.get("v.courseDate");
        helper.handleSubmit(component, firstName, lastName, email, courseName, courseDate);
    }
})
