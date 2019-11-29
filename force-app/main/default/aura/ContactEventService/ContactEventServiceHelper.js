({
    handleInit : function(component) {

        var action = component.get("c.getContactEvents");
        var eventId = component.get("v.recordId");

        action.setParams({
            eventId: eventId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                component.set("v.contactEventList", response.getReturnValue().contactEventList);
                component.set("v.contactEventMap", response.getReturnValue().contactEventObjectMap);
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

    handleChange: function (component, selectedOptionValue, changeIndex) {

        var contactEventMap = component.get("v.contactEventMap");
        contactEventMap[changeIndex].Status__c = selectedOptionValue;
        component.set("v.contactEventMap", contactEventMap)
    },

    handleDelete: function (component, deletedIndex) {

        var contactEventMap = component.get("v.contactEventMap");
        var deletedId = contactEventMap[deletedIndex].Id;
        var action = component.get("c.deleteContactEvent");

        action.setParams({
            deletedId: deletedId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var msgSuccess = "Record successfully deleted";
                this.handleShowToast(component, state, msgSuccess);
            } else if (state === "ERROR") {
                var errors = response.getError();
                this.handleShowToast(component, state, errors[0].message);
                console.error(JSON.stringify(errors));
            }
        });

        $A.enqueueAction(action);

        this.handleInit(component);
    },

    handleUpdate: function (component, updatedIndex) {

        var contactEventMap = component.get("v.contactEventMap");
        var updatedId = contactEventMap[updatedIndex].Id;
        var newStatus = contactEventMap[updatedIndex].Status__c;
        var action = component.get("c.updateContactEvent");

        action.setParams({
            updatedId: updatedId,
            newStatus: newStatus
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var msgSuccess = "Record successfully updated";
                this.handleShowToast(component, state, msgSuccess);
            } else if (state === "ERROR") {
                var errors = response.getError();
                this.handleShowToast(component, state, errors[0].message);
                console.error(JSON.stringify(errors));
            }
        });

        $A.enqueueAction(action);

        this.handleInit(component);
    }
})
