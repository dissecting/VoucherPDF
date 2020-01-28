@isTest
private class NewCreditMemoControllerTest {

    @testSetup
    private static void setupTestData() {
        String noteLines = '<ul><li>Valid for these countries</li><li>Valid for</li><li>Valid for</li></ul>';
        dissecting__NoteSettings__c noteSettings = new dissecting__NoteSettings__c (
            dissecting__NoteLines__c = noteLines
        );

        insert noteSettings;

        System.assertNotEquals(null, noteSettings.Id, 'Record is not created');
    }

    @isTest
    private static void testOverrideRedirect() {
        ApexPages.StandardController sc = new ApexPages.StandardController(new dissecting__Credit_Memo__c());
        NewCreditMemoController newCreditMemoController = new NewCreditMemoController(sc);
        PageReference pageRef = ApexPages.currentPage();
        Test.setCurrentPageReference(pageRef);

        Test.startTest();

        PageReference newPageRef = newCreditMemoController.overrideRedirect();
        Test.setCurrentPageReference(newPageRef);
        String pageParam = ApexPages.currentPage().getParameters().get('nooverride');

        Test.stopTest();

        System.assertEquals('1', pageParam);
        System.assertNotEquals(pageRef, newPageRef);
    }
}