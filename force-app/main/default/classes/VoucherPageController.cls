public with sharing class VoucherPageController {
    public String documentUrl { get; set; }
    public Credit_Memo__c creditMemo { get; set; }
    public Boolean imageIsFound { get; set; }
    private static final String URL_DOCUMENT = '/sfc/servlet.shepherd/version/download/';
    private static Credit_Memo__c credit_Memo;

    public VoucherPageController(ApexPages.StandardController controller) {
        VoucherPageController.getCreditMemo();
        creditMemo = credit_Memo;
        documentUrl = VoucherPageController.getDocumentUrl();
        imageIsFound = !documentUrl.contains('null');
    }

    private static void getCreditMemo() {
        VoucherPageController.credit_Memo = [
            SELECT dissecting__Image_Name__c, dissecting__Credit_Expiry_Date__c, dissecting__Exclusively_For__c, dissecting__Account__r.Name,
                dissecting__Amount__c, dissecting__Currency_ISO__c, Name, dissecting__Note__c, dissecting__Text_Color__c
            FROM dissecting__Credit_Memo__c
            WHERE Id = :ApexPages.currentPage().getParameters().get('id')
        ];
    }

    private static String getDocumentUrl() {
        String docUrl = URL_DOCUMENT + VoucherPageController.getDocumentId();

        return docUrl;
    }

    private static Id getDocumentId() {
        Id documentId;
        Set<String> typeSet = new Set<String> {'jpg', 'jpeg', 'png'};
        List<ContentVersion> contentVersionList = [
            SELECT FileExtension, Title, Expiry_From_Date__c, Expiry_To_Date__c, CreatedDate
            FROM ContentVersion
            WHERE FileExtension IN :typeSet
                AND Title = :credit_Memo.Image_Name__c
                AND Expiry_From_Date__c <= :credit_Memo.Credit_Expiry_Date__c
                AND Expiry_To_Date__c >= :credit_Memo.Credit_Expiry_Date__c
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        if (!contentVersionList.isEmpty()) {
            documentId = contentVersionList[0].Id;
        }

        return documentId;
    }
}