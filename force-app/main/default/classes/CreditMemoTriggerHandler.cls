public with sharing class CreditMemoTriggerHandler {

    public static void updateCreditMemo(List<Credit_Memo__c> creditMemoNewList, List<Credit_Memo__c> creditMemoOldList) {
        Integer creditMemoIndex = 0;

        for (Credit_Memo__c creditMemo : creditMemoNewList) {
            if (creditMemo.Credit_Expiry_Date__c != creditMemoOldList[creditMemoIndex].Credit_Expiry_Date__c) {
                CreditMemoTriggerHandler.correctNoteField(creditMemo);
            }

            if (creditMemo.Currency_ISO__c != creditMemoOldList[creditMemoIndex].Currency_ISO__c) {
                CreditMemoTriggerHandler.correctAmountByExchangeRate(creditMemo);
            }

            creditMemoIndex++;
        }
    }

    public static void insertCreditMemo(List<Credit_Memo__c> creditMemoNewList) {

        for (Credit_Memo__c creditMemo : creditMemoNewList) {
            CreditMemoTriggerHandler.correctNoteField(creditMemo);
        }
    }

    private static void correctNoteField(Credit_Memo__c creditMemoValue) {
        String patternValue = '<li>Valid for any​ ​new​ ​bookings​ ​made​ ​by';
        String newLineNoteFormat = '{0} {1}</li></ul>';
        Datetime expiryDate = (Datetime) creditMemoValue.Credit_Expiry_Date__c;
        String formatedDate = expiryDate.format('dd MMMM yyyy');
        Boolean isCorrectNote = creditMemoValue.Note__c != null
            && creditMemoValue.Note__c.contains(patternValue)
            && !creditMemoValue.Note__c.split(patternValue)[1].contains('<li>');

        if (isCorrectNote) {
            String updatedNoteValue = creditMemoValue.Note__c.substring(
                0,
                creditMemoValue.Note__c.indexOf(patternValue)
            );

            updatedNoteValue += CreditMemoTriggerHandler.getLineNoteFormat(
                newLineNoteFormat,
                patternValue,
                formatedDate
            );
            creditMemoValue.Note__c = updatedNoteValue;
        } else if (creditMemoValue.Note__c == null || !creditMemoValue.Note__c.contains('<ul><li>')) {
            newLineNoteFormat = '<ul>' + newLineNoteFormat;
            creditMemoValue.Note__c = CreditMemoTriggerHandler.getLineNoteFormat(
                newLineNoteFormat,
                patternValue,
                formatedDate
            );
        } else if (!creditMemoValue.Note__c.contains(patternValue)) {
            newLineNoteFormat = CreditMemoTriggerHandler.getLineNoteFormat(
                newLineNoteFormat,
                patternValue,
                formatedDate
            );
            creditMemoValue.Note__c = creditMemoValue.Note__c.replace('</ul>', newLineNoteFormat);
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
            creditMemoValue.Amount__c *= Double.valueOf(creditMemoValue.Exchange_Rate__c);
        }
        catch (TypeException e) {
            creditMemoValue.addError('Exchange Rate should be number');
        }
    }
}