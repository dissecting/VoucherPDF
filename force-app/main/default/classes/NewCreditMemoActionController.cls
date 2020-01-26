public with sharing class NewCreditMemoActionController {

    @AuraEnabled
    public static String getNoteSettings() {
        NoteSettings__c noteSettings = NoteSettings__c.getInstance();
        String noteLines;

        if (noteSettings != null && noteSettings.NoteLines__c != null) {
            noteLines = noteSettings.NoteLines__c;
        }

        return noteLines;
    }
}