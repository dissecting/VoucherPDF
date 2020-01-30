({
    handleInit : function(component, event) {
        var closeQuickAction = $A.get("e.force:closeQuickAction");
        var recordId = component.get("v.recordId");

        closeQuickAction.fire();
        window.location.href = '/apex/dissecting__ImagePreviewPage?scontrolCaching=1&id=' + recordId;
    }
})
