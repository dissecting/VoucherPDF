@isTest
private class CreditMemoTriggerHandlerTest {

    @testSetup
    private static void setupTestData() {
        Account testAccount = new Account(
            Name = 'testAccount'
        );

        insert testAccount;

        String noteLines = '<ul><li>Valid for these countries</li><li>Valid for</li><li>Valid for</li></ul>';
        NoteSettings__c noteSettings = new NoteSettings__c (
            NoteLines__c = noteLines
        );

        insert noteSettings;

        Credit_Memo__c creditMemo = new Credit_Memo__c(
            Account__c = testAccount.Id,
            Currency_ISO__c = '$',
            Exchange_Rate__c = '0.91',
            Amount__c = 100,
            Note__c = noteLines,
            Credit_Expiry_Date__c = Date.today()
        );

        insert creditMemo;
    }

    @isTest
    private static void testInsertCreditMemo() {
        Account account = [
            SELECT Name
            FROM Account
        ];

        NoteSettings__c noteSettings = NoteSettings__c.getInstance();
        String noteLines = noteSettings.NoteLines__c;

        Credit_Memo__c creditMemo = new Credit_Memo__c(
            Account__c = account.Id,
            Currency_ISO__c = '$',
            Exchange_Rate__c = '1',
            Amount__c = 300,
            Note__c = noteLines,
            Credit_Expiry_Date__c = Date.today()
        );

        Test.startTest();

        insert creditMemo;

        Test.stopTest();

        Datetime expiryDate = (Datetime) Date.today();
        String formatedDate = expiryDate.format('dd MMMM yyyy');
        String newLineNote = '<li>Valid for any​ ​new​ ​bookings​ ​made​ ​by ' + formatedDate;
        Boolean isContained = false;

        List<Credit_Memo__c> creditMemoList = [
            SELECT Note__c, Amount__c
            FROM Credit_Memo__c
            WHERE Amount__c = 300
        ];

        for (Credit_Memo__c newCreditMemo : creditMemoList) {
            if (newCreditMemo.Note__c.contains(newLineNote)) {
                isContained = true;
            }
        }

        System.assert(isContained);
    }

    @isTest
    private static void testUpdateCreditExpiryDate() {
        List<Credit_Memo__c> creditMemoList = [
            SELECT Amount__c, Credit_Expiry_Date__c
            FROM Credit_Memo__c
            WHERE Amount__c = 100
        ];
        creditMemoList[0].Credit_Expiry_Date__c = Date.today().addDays(1);

        Test.startTest();

        update creditMemoList;

        Test.stopTest();

        Date newDate = Date.today().addDays(1);
        Datetime expiryDate = (Datetime) newDate;
        String formatedDate = expiryDate.format('dd MMMM yyyy');
        String newLineNote = '<li>Valid for any​ ​new​ ​bookings​ ​made​ ​by ' + formatedDate;
        Boolean isContained = false;

        List<Credit_Memo__c> newCreditMemoList = [
            SELECT Note__c, Credit_Expiry_Date__c, Amount__c
            FROM Credit_Memo__c
            WHERE Credit_Expiry_Date__c = :newDate
        ];

        for (Credit_Memo__c newCreditMemo : newCreditMemoList) {
            if (newCreditMemo.Note__c.contains(newLineNote)) {
                isContained = true;
            }
        }

        System.assert(isContained);
        System.assertEquals(creditMemoList.size(), newCreditMemoList.size());
    }

    @isTest
    private static void testUpdateCreditExpiryDateByNullNote() {
        List<Credit_Memo__c> creditMemoList = [
            SELECT Note__c, Amount__c, Credit_Expiry_Date__c
            FROM Credit_Memo__c
            WHERE Amount__c = 100
        ];
        creditMemoList[0].Note__c = '';
        creditMemoList[0].Credit_Expiry_Date__c = Date.today().addDays(1);

        Test.startTest();

        update creditMemoList;

        Test.stopTest();

        Date newDate = Date.today().addDays(1);
        Datetime expiryDate = (Datetime) newDate;
        String formatedDate = expiryDate.format('dd MMMM yyyy');
        String newLineNote = '<li>Valid for any​ ​new​ ​bookings​ ​made​ ​by ' + formatedDate;
        Boolean isContained = false;

        List<Credit_Memo__c> newCreditMemoList = [
            SELECT Note__c, Credit_Expiry_Date__c, Amount__c
            FROM Credit_Memo__c
            WHERE Credit_Expiry_Date__c = :newDate
        ];

        for (Credit_Memo__c newCreditMemo : newCreditMemoList) {
            if (newCreditMemo.Note__c.contains(newLineNote)) {
                isContained = true;
            }
        }

        System.assert(isContained);
        System.assertEquals(creditMemoList.size(), newCreditMemoList.size());
    }

    @isTest
    private static void testUpdateCurrencyISO() {
        List<Credit_Memo__c> creditMemoList = [
            SELECT Currency_ISO__c, Amount__c
            FROM Credit_Memo__c
            WHERE Currency_ISO__c = '$'
        ];
        creditMemoList[0].Currency_ISO__c = '€';
        Double oldAmount = creditMemoList[0].Amount__c;

        Test.startTest();

        update creditMemoList;

        Test.stopTest();

        List<Credit_Memo__c> newCreditMemoList = [
            SELECT Currency_ISO__c, Amount__c, Exchange_Rate__c
            FROM Credit_Memo__c
            WHERE Currency_ISO__c = '€'
        ];
        Double newAmount = newCreditMemoList[0].Amount__c;
        Double exchangeRate = Double.valueOf(newCreditMemoList[0].Exchange_Rate__c);

        System.assertEquals(creditMemoList.size(), newCreditMemoList.size());
        System.assertEquals(oldAmount * exchangeRate, newAmount);
    }
}