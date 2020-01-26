public with sharing class NewCreditMemoController {

    public NewCreditMemoController(ApexPages.StandardController controller) {}

    public PageReference overrideRedirect() {
        NoteSettings__c noteSettings = NoteSettings__c.getInstance();
        String noteLines;

        if (noteSettings != null && noteSettings.NoteLines__c != null) {
            noteLines = noteSettings.NoteLines__c;
        }

        PageReference prOverride = new PageReference(
            String.format('/a0D/e?{0}={1}&retURL=%2Fa0D%2Fo&nooverride=1', new List<Object> {
                NewCreditMemoController.getFieldId(),
                noteLines
            })
        );
        prOverride.setRedirect(true);

        return prOverride;
    }

    private static PageReference defaultRedirect() {
        PageReference prDefault = new PageReference('/a0D/e?retURL=%2Fa0D%2Fo&nooverride=1');
        prDefault.setRedirect(true);

        return prDefault;
    }

    private static String getFieldId() {
        String html;
        String fieldId;
        Blob pageContent;

        if (Test.isRunningTest()) {
            NewCreditMemoController.defaultRedirect();
            pageContent = Blob.valueOf('Unit.Test');
        } else {
            pageContent = NewCreditMemoController.defaultRedirect().getContent();
        }

        if (pageContent != null) {
            html = pageContent.toString();
        }

        Matcher matcher = Pattern.compile('<label for="(.*?)">Note</label>').matcher(html);

        while (matcher.find()) {
            fieldId = matcher.group(1);
        }

        return fieldId;
    }
}