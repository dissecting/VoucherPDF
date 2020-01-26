@isTest
private class NewCreditMemoControllerTest {

    @testSetup
    private static void setupTestData() {
        String noteLines = '<ul><li>Valid for these countries</li><li>Valid for</li><li>Valid for</li></ul>';
        NoteSettings__c noteSettings = new NoteSettings__c (
            NoteLines__c = noteLines
        );

        insert noteSettings;
    }

    @isTest
    private static void testOverrideRedirect() {
        ApexPages.StandardController sc = new ApexPages.StandardController(new Credit_Memo__c());
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