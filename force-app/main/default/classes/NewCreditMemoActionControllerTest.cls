@isTest
private class NewCreditMemoActionControllerTest {

    @testSetup
    private static void setupTestData() {
        String noteLines = '<ul><li>Valid for these countries</li><li>Valid for</li><li>Valid for</li></ul>';
        dissecting__NoteSettings__c noteSettings = new dissecting__NoteSettings__c (
            dissecting__NoteLines__c = noteLines
        );

        insert noteSettings;
    }

    @isTest
    private static void testGetNoteSettings() {
        dissecting__NoteSettings__c noteSettings = dissecting__NoteSettings__c.getInstance();
        String preparedNoteLines = noteSettings.dissecting__NoteLines__c;
        String actualNoteLines;

        Test.startTest();

        actualNoteLines = NewCreditMemoActionController.getNoteSettings();

        Test.stopTest();

        System.assertEquals(preparedNoteLines, actualNoteLines);
    }
}