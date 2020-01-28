public with sharing class NewCreditMemoController {

    public NewCreditMemoController(ApexPages.StandardController controller) {}

    public PageReference overrideRedirect() {
        dissecting__NoteSettings__c noteSettings = dissecting__NoteSettings__c.getInstance();
        Schema.DescribeSObjectResult result = dissecting__Credit_Memo__c.sObjectType.getDescribe();
        String noteLines;
        String keyPrefix = result.getKeyPrefix();

        if (noteSettings != null && noteSettings.dissecting__NoteLines__c != null) {
            noteLines = noteSettings.dissecting__NoteLines__c;
        }

        PageReference prOverride = new PageReference(
            String.format('/{0}/e?{1}={2}&retURL=%2Fa0D%2Fo&nooverride=1', new List<Object> {
                keyPrefix,
                this.getFieldId(keyPrefix),
                noteLines
            })
        );
        prOverride.setRedirect(true);

        return prOverride;
    }

    private PageReference defaultRedirect(String objectPrefix) {
        PageReference prDefault = new PageReference(
            String.format('/{0}/e?&retURL=%2Fa0D%2Fo&nooverride=1', new List<Object> {objectPrefix})
        );
        prDefault.setRedirect(true);

        return prDefault;
    }

    private String getFieldId(String objPrefix) {
        String html;
        String fieldId;
        Blob pageContent;

        if (Test.isRunningTest()) {
            this.defaultRedirect(objPrefix);
            pageContent = Blob.valueOf('Unit.Test');
        } else {
            pageContent = this.defaultRedirect(objPrefix).getContent();
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