public with sharing class VoucherPageController {
    public String documentUrl { get; set; }
    public Boolean imageIsFound { get; set; }
    private static final String URL_DOCUMENT = '/sfc/servlet.shepherd/version/download/';
    private static dissecting__Credit_Memo__c creditMemo;

    public VoucherPageController(ApexPages.StandardController controller) {
        List<String> fieldNameList = new List<String> {
            'dissecting__Image_Name__c',
            'dissecting__Credit_Expiry_Date__c'
        };

        if (!Test.isRunningTest()) {
            controller.addFields(fieldNameList);
        }

        creditMemo = (dissecting__Credit_Memo__c) controller.getRecord();
        this.getDocumentId();
        imageIsFound = !documentUrl.contains('null');
    }

    private void getDocumentId() {
        Id documentId;
        Set<String> typeSet = new Set<String> {'jpg', 'jpeg', 'png'};
        String imageName = creditMemo.dissecting__Image_Name__c;
        Date expiryDate = creditMemo.dissecting__Credit_Expiry_Date__c;
        String titleValue = String.isBlank(imageName) ?
            '' : 'AND Title = :imageName';
        String queryValue =
            'SELECT FileExtension, Title, dissecting__Expiry_From_Date__c, dissecting__Expiry_To_Date__c, CreatedDate ' +
            'FROM ContentVersion ' +
            'WHERE FileExtension IN :typeSet ' +
            titleValue +
            ' AND dissecting__Expiry_From_Date__c <= :expiryDate' +
            ' AND dissecting__Expiry_To_Date__c >= :expiryDate' +
            ' ORDER BY CreatedDate DESC' +
            ' LIMIT 1';

        List<ContentVersion> contentVersionList = Database.query(queryValue);

        if (!contentVersionList.isEmpty()) {
            documentId = contentVersionList[0].Id;
        }

        documentUrl = URL_DOCUMENT + documentId;
    }
}