({
    handleInit : function(component, event) {
        component.set("v.componentURL", window.location.href);

        var createRecordEvent = $A.get("e.force:createRecord");
        var action = component.get("c.getNoteSettings");

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                createRecordEvent.setParams({
                    "entityApiName": "dissecting__Credit_Memo__c",
                    "defaultFieldValues": {
                        "dissecting__Note__c" : response.getReturnValue()
                    }
                });

                createRecordEvent.fire();
            } else if (state === "ERROR") {
                var errors = response.getError();
                alert(errors);
            }
        });
        $A.enqueueAction(action);
    },

    handleUpdate : function(component, event) {
        component.set("v.modalURL", window.location.href);

        var componentURL = component.get("v.componentURL");
        var modalURL = component.get("v.modalURL");

        if (componentURL === modalURL) {
            var redirectURL = componentURL.substring(0, componentURL.indexOf("dissecting__Credit_Memo__c"));

            redirectURL += "dissecting__Credit_Memo__c/home";
            window.location.href = redirectURL;
        }
    }
})
