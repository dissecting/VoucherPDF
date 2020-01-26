({
    handleInit : function(component, event) {
        var createRecordEvent = $A.get("e.force:createRecord");
        var action = component.get("c.getNoteSettings");

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                createRecordEvent.setParams({
                    "entityApiName": "Credit_Memo__c",
                    "defaultFieldValues": {
                        "Note__c" : response.getReturnValue()
                    }
                });
                createRecordEvent.fire();
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        });
        $A.enqueueAction(action);
    }
})
