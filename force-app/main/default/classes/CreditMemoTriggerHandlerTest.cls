@isTest
private class CreditMemoTriggerHandlerTest {

    @testSetup
    private static void setupTestData() {
        Account testAccount = new Account(
            Name = 'testAccount'
        );

        insert testAccount;

        String noteLines = '<ul><li>Valid for these countries</li><li>Valid for</li><li>Valid for</li></ul>';
        dissecting__NoteSettings__c noteSettings = new dissecting__NoteSettings__c (
            dissecting__NoteLines__c = noteLines
        );

        insert noteSettings;

        dissecting__Credit_Memo__c creditMemo = new dissecting__Credit_Memo__c(
            dissecting__Account__c = testAccount.Id,
            dissecting__Currency_ISO__c = '$',
            dissecting__Exchange_Rate__c = '0.91',
            dissecting__Amount__c = 100,
            dissecting__Note__c = noteLines,
            dissecting__Credit_Expiry_Date__c = Date.today()
        );

        insert creditMemo;
    }

    @isTest
    private static void testInsertCreditMemo() {
        Account account = [
            SELECT Name
            FROM Account
        ];

        dissecting__NoteSettings__c noteSettings = dissecting__NoteSettings__c.getInstance();
        String noteLines = noteSettings.dissecting__NoteLines__c;

        dissecting__Credit_Memo__c creditMemo = new dissecting__Credit_Memo__c(
            dissecting__Account__c = account.Id,
            dissecting__Currency_ISO__c = '$',
            dissecting__Exchange_Rate__c = '1',
            dissecting__Amount__c = 300,
            dissecting__Note__c = noteLines,
            dissecting__Credit_Expiry_Date__c = Date.today()
        );

        Test.startTest();

        insert creditMemo;

        Test.stopTest();

        Datetime expiryDate = (Datetime) Date.today();
        String formatedDate = expiryDate.format('dd MMMM yyyy');
        String newLineNote = '<li>Valid for any​ ​new​ ​bookings​ ​made​ ​by ' + formatedDate;
        Boolean isContained = false;

        List<dissecting__Credit_Memo__c> creditMemoList = [
            SELECT dissecting__Note__c, dissecting__Amount__c
            FROM dissecting__Credit_Memo__c
            WHERE dissecting__Amount__c = 300
        ];

        for (dissecting__Credit_Memo__c newCreditMemo : creditMemoList) {
            if (newCreditMemo.dissecting__Note__c.contains(newLineNote)) {
                isContained = true;
            }
        }

        System.assert(isContained);
    }

    @isTest
    private static void testUpdateCreditExpiryDate() {
        List<dissecting__Credit_Memo__c> creditMemoList = [
            SELECT dissecting__Amount__c, dissecting__Credit_Expiry_Date__c
            FROM dissecting__Credit_Memo__c
            WHERE dissecting__Amount__c = 100
        ];
        creditMemoList[0].dissecting__Credit_Expiry_Date__c = Date.today().addDays(1);

        Test.startTest();

        update creditMemoList;

        Test.stopTest();

        Date newDate = Date.today().addDays(1);
        Datetime expiryDate = (Datetime) newDate;
        String formatedDate = expiryDate.format('dd MMMM yyyy');
        String newLineNote = '<li>Valid for any​ ​new​ ​bookings​ ​made​ ​by ' + formatedDate;
        Boolean isContained = false;

        List<dissecting__Credit_Memo__c> newCreditMemoList = [
            SELECT dissecting__Note__c, dissecting__Credit_Expiry_Date__c, dissecting__Amount__c
            FROM dissecting__Credit_Memo__c
            WHERE dissecting__Credit_Expiry_Date__c = :newDate
        ];

        for (dissecting__Credit_Memo__c newCreditMemo : newCreditMemoList) {
            if (newCreditMemo.dissecting__Note__c.contains(newLineNote)) {
                isContained = true;
            }
        }

        System.assert(isContained);
        System.assertEquals(creditMemoList.size(), newCreditMemoList.size());
    }

    @isTest
    private static void testUpdateCreditExpiryDateByNullNote() {
        List<dissecting__Credit_Memo__c> creditMemoList = [
            SELECT dissecting__Note__c, dissecting__Amount__c, dissecting__Credit_Expiry_Date__c
            FROM dissecting__Credit_Memo__c
            WHERE dissecting__Amount__c = 100
        ];
        creditMemoList[0].dissecting__Note__c = '';
        creditMemoList[0].dissecting__Credit_Expiry_Date__c = Date.today().addDays(1);

        Test.startTest();

        update creditMemoList;

        Test.stopTest();

        Date newDate = Date.today().addDays(1);
        Datetime expiryDate = (Datetime) newDate;
        String formatedDate = expiryDate.format('dd MMMM yyyy');
        String newLineNote = '<li>Valid for any​ ​new​ ​bookings​ ​made​ ​by ' + formatedDate;
        Boolean isContained = false;

        List<dissecting__Credit_Memo__c> newCreditMemoList = [
            SELECT dissecting__Note__c, dissecting__Credit_Expiry_Date__c, dissecting__Amount__c
            FROM dissecting__Credit_Memo__c
            WHERE dissecting__Credit_Expiry_Date__c = :newDate
        ];

        for (dissecting__Credit_Memo__c newCreditMemo : newCreditMemoList) {
            if (newCreditMemo.dissecting__Note__c.contains(newLineNote)) {
                isContained = true;
            }
        }

        System.assert(isContained);
        System.assertEquals(creditMemoList.size(), newCreditMemoList.size());
    }

    @isTest
    private static void testUpdateCurrencyISO() {
        List<dissecting__Credit_Memo__c> creditMemoList = [
            SELECT dissecting__Currency_ISO__c, dissecting__Amount__c
            FROM dissecting__Credit_Memo__c
            WHERE dissecting__Currency_ISO__c = '$'
        ];
        creditMemoList[0].dissecting__Currency_ISO__c = '€';
        Double oldAmount = creditMemoList[0].dissecting__Amount__c;

        Test.startTest();

        update creditMemoList;

        Test.stopTest();

        List<dissecting__Credit_Memo__c> newCreditMemoList = [
            SELECT dissecting__Currency_ISO__c, dissecting__Amount__c, dissecting__Exchange_Rate__c
            FROM dissecting__Credit_Memo__c
            WHERE dissecting__Currency_ISO__c = '€'
        ];
        Double newAmount = newCreditMemoList[0].dissecting__Amount__c;
        Double exchangeRate = Double.valueOf(newCreditMemoList[0].dissecting__Exchange_Rate__c);

        System.assertEquals(creditMemoList.size(), newCreditMemoList.size());
        System.assertEquals(oldAmount * exchangeRate, newAmount);
    }
}