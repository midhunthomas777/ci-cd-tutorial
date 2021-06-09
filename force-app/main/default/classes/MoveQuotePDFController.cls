public with sharing class MoveQuotePDFController {

    public MoveQuotePDFController(ApexPages.StandardController controller) {

    }
    
    public static pagereference moveToDrive(){
    Id quoteId = ApexPages.currentPage().getParameters().get('id');
    GoogleCreateDriveforError.checkQuote(quoteId);
    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Quote Moved to Drive'));
    return null;
    }
 
}