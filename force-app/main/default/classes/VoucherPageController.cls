public with sharing class VoucherPageController {
    public String documentUrl { get; set; }
    public Credit_Memo__c creditMemo { get; set; }
    private static final String URL_DOCUMENT = '/sfc/servlet.shepherd/version/download/';
    private static Credit_Memo__c credit_Memo;

    public VoucherPageController(ApexPages.StandardController controller) {
        VoucherPageController.getCreditMemo();
        creditMemo = credit_Memo;
        documentUrl = VoucherPageController.getDocumentUrl();
    }

    private static void getCreditMemo() {
        VoucherPageController.credit_Memo = [
            SELECT Image_Name__c, Credit_Expiry_Date__c, Exclusively_For__c, Account__r.Name,
                Amount__c, Currency_ISO__c, Name, Note__c
            FROM Credit_Memo__c
            WHERE Id = :ApexPages.currentPage().getParameters().get('id')
        ];
    }

    public static String getDocumentUrl() {
        Id docId;
        String docUrl;
        List<Image_Storage__c> imageSorageList = VoucherPageController.getImageStorage();

        if (!imageSorageList.isEmpty()) {
            docId = VoucherPageController.getDocumentId(imageSorageList[0].Image_Name__c);
        }
        docUrl = URL_DOCUMENT + docId;

        return docUrl;
    }

    private static List<Image_Storage__c> getImageStorage() {
        List<Image_Storage__c> imgSorageList = [
            SELECT Image_Name__c, Expiry_From_Date__c, Expiry_To_Date__c, CreatedDate
            FROM Image_Storage__c
            WHERE Image_Name__c = :credit_Memo.Image_Name__c
                AND Expiry_From_Date__c <= :credit_Memo.Credit_Expiry_Date__c
                AND Expiry_To_Date__c >= :credit_Memo.Credit_Expiry_Date__c
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        return imgSorageList;
    }

    private static Id getDocumentId(String imageName) {
        Id documentId;
        Set<String> typeSet = new Set<String> {'jpg', 'jpeg', 'png'};
        List<ContentVersion> documentList = [
            SELECT FileExtension, Title
            FROM ContentVersion
            WHERE FileExtension IN :typeSet
                AND Title = :imageName
            LIMIT 1
        ];

        if (!documentList.isEmpty()) {
            documentId = documentList[0].Id;
        }

        return documentId;
    }
}