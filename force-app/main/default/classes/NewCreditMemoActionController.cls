public with sharing class NewCreditMemoActionController {

    @AuraEnabled
    public static String getNoteSettings() {
        dissecting__NoteSettings__c noteSettings = dissecting__NoteSettings__c.getInstance();
        String noteLines;

        if (noteSettings != null && noteSettings.dissecting__NoteLines__c != null) {
            noteLines = noteSettings.dissecting__NoteLines__c;
        }

        return noteLines;
    }
}