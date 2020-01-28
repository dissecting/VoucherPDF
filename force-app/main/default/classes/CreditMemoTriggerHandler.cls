public with sharing class CreditMemoTriggerHandler {

    private static final String PATTERN_VALUE = Label.noteLinePatternValue;

    public static void updateCreditMemo(List<dissecting__Credit_Memo__c> creditMemoNewList, List<dissecting__Credit_Memo__c> creditMemoOldList) {
        Integer creditMemoIndex = 0;
        CreditMemoTriggerHandler creditMemoTriggerHandler  = new CreditMemoTriggerHandler();

        for (dissecting__Credit_Memo__c creditMemo : creditMemoNewList) {
            if (creditMemo.dissecting__Credit_Expiry_Date__c != creditMemoOldList[creditMemoIndex].dissecting__Credit_Expiry_Date__c) {
                creditMemoTriggerHandler.correctNoteField(creditMemo);
            }

            if (creditMemo.dissecting__Currency_ISO__c != creditMemoOldList[creditMemoIndex].dissecting__Currency_ISO__c) {
                creditMemoTriggerHandler.correctAmountByExchangeRate(creditMemo);
            }

            creditMemoIndex++;
        }
    }

    public static void insertCreditMemo(List<dissecting__Credit_Memo__c> creditMemoNewList) {
        CreditMemoTriggerHandler creditMemoTriggerHandler  = new CreditMemoTriggerHandler();

        for (dissecting__Credit_Memo__c creditMemo : creditMemoNewList) {
            creditMemoTriggerHandler.correctNoteField(creditMemo);
        }
    }

    private void correctNoteField(dissecting__Credit_Memo__c creditMemoValue) {
        String patternValue = '<li>' + PATTERN_VALUE;
        String newLineNoteFormat = '{0} {1}</li></ul>';
        Datetime expiryDate = (Datetime) creditMemoValue.dissecting__Credit_Expiry_Date__c;
        String formatedDate = expiryDate.formatGMT('dd MMMM yyyy');
        Boolean isCorrectNote = creditMemoValue.dissecting__Note__c != null
            && creditMemoValue.Note__c.contains(patternValue);
        Boolean isIncorrectNote = creditMemoValue.dissecting__Note__c == null
            || !creditMemoValue.dissecting__Note__c.contains('<ul><li>');

        if (isCorrectNote) {
            String dateNoteValue = creditMemoValue.dissecting__Note__c.substringBetween(patternValue, '</li>');

            creditMemoValue.dissecting__Note__c = creditMemoValue.dissecting__Note__c.replaceAll(dateNoteValue, ' ' + formatedDate);
        } else if (isIncorrectNote) {
            newLineNoteFormat = '<ul>' + newLineNoteFormat;
            creditMemoValue.dissecting__Note__c = this.getLineNoteFormat(
                newLineNoteFormat,
                patternValue,
                formatedDate
            );
        } else if (!creditMemoValue.dissecting__Note__c.contains(patternValue)) {
            newLineNoteFormat = this.getLineNoteFormat(
                newLineNoteFormat,
                patternValue,
                formatedDate
            );
            creditMemoValue.dissecting__Note__c = creditMemoValue.dissecting__Note__c.replace('</ul>', newLineNoteFormat);
        }
    }

    private String getLineNoteFormat(String lineFormat, String patternLineValue, String formatedDateValue) {
        String lineNoteFormat = String.format(lineFormat, new List<Object> {
            patternLineValue,
            formatedDateValue
        });

        return lineNoteFormat;
    }

    private void correctAmountByExchangeRate(Credit_Memo__c creditMemoValue) {

        try {
            creditMemoValue.dissecting__Amount__c *= Double.valueOf(creditMemoValue.dissecting__Exchange_Rate__c);
        }
        catch (TypeException e) {
            creditMemoValue.addError('Exchange Rate should be number');
        }
    }
}