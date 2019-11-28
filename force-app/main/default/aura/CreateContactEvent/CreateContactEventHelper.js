({
    handleShowToast: function(component, msgType, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": msgType === "SUCCESS" ? "Success!": "Error!",
            "type": msgType === "SUCCESS" ? "success": "error",
            "message": msg
        });
        toastEvent.fire();
    },

    handleSubmit: function (component) {
        var firstName = component.get("v.firstName");
        var lastName = component.get("v.lastName");
        var email = component.get("v.email");
        var eventId = component.get("v.recordId");
        var action = component.get("c.setContactEvent");
        action.setParams({
            firstName: firstName,
            lastName: lastName,
            email: email,
            eventId: eventId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var msgSuccess = "You successfully created Contact Event";
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
