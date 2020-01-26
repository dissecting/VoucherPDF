@isTest
private class NewCreditMemoActionControllerTest {

    @testSetup
    private static void setupTestData() {
        String noteLines = '<ul><li>Valid for these countries</li><li>Valid for</li><li>Valid for</li></ul>';
        NoteSettings__c noteSettings = new NoteSettings__c (
            NoteLines__c = noteLines
        );

        insert noteSettings;
    }

    @isTest
    private static void testGetNoteSettings() {
        NoteSettings__c noteSettings = NoteSettings__c.getInstance();
        String preparedNoteLines = noteSettings.NoteLines__c;
        String actualNoteLines;

        Test.startTest();

        actualNoteLines = NewCreditMemoActionController.getNoteSettings();

        Test.stopTest();

        System.assertEquals(preparedNoteLines, actualNoteLines);
    }
}