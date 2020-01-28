public with sharing class VoucherPageController {
    public String documentUrl { get; set; }
    public Boolean imageIsFound { get; set; }
    private static final String URL_DOCUMENT = '/sfc/servlet.shepherd/version/download/';
    private static dissecting__Credit_Memo__c creditMemo;

    public VoucherPageController(ApexPages.StandardController controller) {
        List<String> fieldNameList = new List<String> {
            'dissecting__Image_Name__c',
            'Credit_Expiry_Date__c'
        };

        controller.addFields(fieldNameList);
        creditMemo = (dissecting__Credit_Memo__c) controller.getRecord();
        this.getDocumentId();
        imageIsFound = !URL_DOCUMENT.contains('null');
    }

    private void getDocumentId() {
        Id documentId;
        Set<String> typeSet = new Set<String> {'jpg', 'jpeg', 'png'};
        List<ContentVersion> contentVersionList = [
            SELECT FileExtension, Title, dissecting__Expiry_From_Date__c, dissecting__Expiry_To_Date__c, CreatedDate
            FROM ContentVersion
            WHERE FileExtension IN :typeSet
                AND Title = :creditMemo.Image_Name__c
                AND dissecting__Expiry_From_Date__c <= :creditMemo.Credit_Expiry_Date__c
                AND dissecting__Expiry_To_Date__c >= :creditMemo.Credit_Expiry_Date__c
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        if (!contentVersionList.isEmpty()) {
            documentId = contentVersionList[0].Id;
        }

        documentUrl = URL_DOCUMENT + documentId;
    }
}