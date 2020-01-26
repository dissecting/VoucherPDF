trigger CreditMemoTrigger on Credit_Memo__c (before insert, before update) {

    if (Trigger.isBefore && Trigger.isUpdate) {
        CreditMemoTriggerHandler.updateCreditMemo(Trigger.new, Trigger.old);
    } else if (Trigger.isBefore && Trigger.isInsert) {
        CreditMemoTriggerHandler.insertCreditMemo(Trigger.new);
    }
}