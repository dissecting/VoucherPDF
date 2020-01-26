@isTest
private class VoucherPageControllerTest {

    @testSetup
    private static void setupTestData() {
        Document document = new Document(
            Name = 'testDocument',
            Body = Blob.valueOf('Some Text'),
            DeveloperName = 'testDocument',
            FolderId = UserInfo.getUserId(),
            Type = 'jpg'
        );

        insert document;

        Image_Storage__c imageStorage = new Image_Storage__c(
            Image_Name__c = document.DeveloperName,
            Expiry_From_Date__c = Date.today(),
            Expiry_To_Date__c = Date.today().addDays(1)
        );

        insert imageStorage;

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
            Image_Name__c = imageStorage.Image_Name__c,
            Credit_Expiry_Date__c = Date.today()
        );

        insert creditMemo;
    }

    @isTest
    private static void testVoucher() {
        List<Credit_Memo__c> creditMemoList = [
            SELECT Amount__c
            FROM Credit_Memo__c
            WHERE Amount__c = 100
        ];

        PageReference pageRef = ApexPages.currentPage();
        Test.setCurrentPageReference(pageRef);
        ApexPages.currentPage().getParameters().put('id', creditMemoList[0].Id);

        Test.startTest();

        ApexPages.StandardController sc = new ApexPages.StandardController(creditMemoList[0]);
        VoucherPageController voucherPageController = new VoucherPageController(sc);

        Test.stopTest();

        List<Document> documentList = [
            SELECT Id
            FROM Document
        ];

        String docUrl = '/servlet/servlet.FileDownload?file=' + documentList[0].Id;

        System.assertEquals(docUrl, voucherPageController.documentUrl);
    }
}