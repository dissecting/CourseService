({
    doInit: function(component, event, helper) {
        helper.handleInit(component);
    },

    onChange: function (component, event, helper) {
        var selectedOptionValue = event.getParam("value");
        var changeIndex = event.getSource().get("v.tabindex");
        helper.handleChange(component, selectedOptionValue, changeIndex);
    },

    onUpdate: function (component, event, helper) {
        var updatedIndex = event.getSource().get("v.tabindex");
        helper.handleUpdate(component, updatedIndex);
    },

    onDelete: function (component, event, helper) {
        var deletedIndex = event.getSource().get("v.tabindex");
        helper.handleDelete(component, deletedIndex);
    }
})
