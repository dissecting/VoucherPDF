public with sharing class CreditMemoTriggerHandler {

    public static void updateCreditMemo(List<dissecting__Credit_Memo__c> creditMemoNewList, List<dissecting__Credit_Memo__c> creditMemoOldList) {
        Integer creditMemoIndex = 0;

        for (dissecting__Credit_Memo__c creditMemo : creditMemoNewList) {
            if (creditMemo.dissecting__Credit_Expiry_Date__c != creditMemoOldList[creditMemoIndex].dissecting__Credit_Expiry_Date__c) {
                CreditMemoTriggerHandler.correctNoteField(creditMemo);
            }

            if (creditMemo.dissecting__Currency_ISO__c != creditMemoOldList[creditMemoIndex].dissecting__Currency_ISO__c) {
                CreditMemoTriggerHandler.correctAmountByExchangeRate(creditMemo);
            }

            creditMemoIndex++;
        }
    }

    public static void insertCreditMemo(List<dissecting__Credit_Memo__c> creditMemoNewList) {

        for (dissecting__Credit_Memo__c creditMemo : creditMemoNewList) {
            CreditMemoTriggerHandler.correctNoteField(creditMemo);
        }
    }

    private static void correctNoteField(dissecting__Credit_Memo__c creditMemoValue) {
        String patternValue = '<li>Valid for any​ ​new​ ​bookings​ ​made​ ​by';
        String newLineNoteFormat = '{0} {1}</li></ul>';
        Datetime expiryDate = (Datetime) creditMemoValue.dissecting__Credit_Expiry_Date__c;
        String formatedDate = expiryDate.formatGMT('dd MMMM yyyy');
        Boolean isCorrectNote = creditMemoValue.dissecting__Note__c != null
            && creditMemoValue.Note__c.contains(patternValue)
            && !creditMemoValue.Note__c.split(patternValue)[1].contains('<li>');

        if (isCorrectNote) {
            String updatedNoteValue = creditMemoValue.dissecting__Note__c.substring(
                0,
                creditMemoValue.dissecting__Note__c.indexOf(patternValue)
            );

            updatedNoteValue += CreditMemoTriggerHandler.getLineNoteFormat(
                newLineNoteFormat,
                patternValue,
                formatedDate
            );
            creditMemoValue.dissecting__Note__c = updatedNoteValue;
        } else if (creditMemoValue.dissecting__Note__c == null || !creditMemoValue.dissecting__Note__c.contains('<ul><li>')) {
            newLineNoteFormat = '<ul>' + newLineNoteFormat;
            creditMemoValue.dissecting__Note__c = CreditMemoTriggerHandler.getLineNoteFormat(
                newLineNoteFormat,
                patternValue,
                formatedDate
            );
        } else if (!creditMemoValue.dissecting__Note__c.contains(patternValue)) {
            newLineNoteFormat = CreditMemoTriggerHandler.getLineNoteFormat(
                newLineNoteFormat,
                patternValue,
                formatedDate
            );
            creditMemoValue.dissecting__Note__c = creditMemoValue.dissecting__Note__c.replace('</ul>', newLineNoteFormat);
        }
    }

    private static String getLineNoteFormat(String lineFormat, String patternLineValue, String formatedDateValue) {
        String lineNoteFormat = String.format(lineFormat, new List<Object> {
            patternLineValue,
            formatedDateValue
        });

        return lineNoteFormat;
    }

    private static void correctAmountByExchangeRate(Credit_Memo__c creditMemoValue) {

        try {
            creditMemoValue.dissecting__Amount__c *= Double.valueOf(creditMemoValue.dissecting__Exchange_Rate__c);
        }
        catch (TypeException e) {
            creditMemoValue.addError('Exchange Rate should be number');
        }
    }
}