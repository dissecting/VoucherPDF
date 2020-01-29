@isTest
private class VoucherPageControllerTest {

    @testSetup
    private static void setupTestData() {
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            dissecting__Expiry_From_Date__c = Date.today(),
            dissecting__Expiry_To_Date__c = Date.today().addDays(1),
            VersionData = Blob.valueOf('Test Content')
        );

        insert contentVersion;

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
            dissecting__Image_Name__c = contentVersion.Title,
            dissecting__Credit_Expiry_Date__c = Date.today()
        );

        insert creditMemo;

        System.assertNotEquals(null, contentVersion.Id, 'Record is not created');
        System.assertNotEquals(null, testAccount.Id, 'Record is not created');
        System.assertNotEquals(null, noteSettings.Id, 'Record is not created');
        System.assertNotEquals(null, creditMemo.Id, 'Record is not created');
    }

    @isTest
    private static void testVoucher() {
        List<dissecting__Credit_Memo__c> creditMemoList = [
            SELECT dissecting__Amount__c, dissecting__Credit_Expiry_Date__c, dissecting__Image_Name__c
            FROM dissecting__Credit_Memo__c
            WHERE dissecting__Amount__c = 100
        ];

        PageReference pageRef = ApexPages.currentPage();
        Test.setCurrentPageReference(pageRef);
        ApexPages.currentPage().getParameters().put('id', creditMemoList[0].Id);

        Test.startTest();

        ApexPages.StandardController sc = new ApexPages.StandardController(creditMemoList[0]);
        VoucherPageController voucherPageController = new VoucherPageController(sc);

        Test.stopTest();

        List<ContentVersion> contentVersionList = [
            SELECT Id
            FROM ContentVersion
        ];

        String docUrl = '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Jpg&versionId=' + contentVersionList[0].Id;

        System.assertEquals(docUrl, voucherPageController.documentUrl);
    }
}