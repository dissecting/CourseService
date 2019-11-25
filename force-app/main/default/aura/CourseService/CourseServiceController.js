({
    doInit: function(component, event, helper) {
        helper.handleInit(component);
    },

    onChange: function (component, event, helper) {
        var selectedOptionValue = event.getParam("value");
        helper.handleChange(component, selectedOptionValue);
    },

    onSubmit: function (component, event, helper) {
        helper.handleSubmit(component);
    }
})
