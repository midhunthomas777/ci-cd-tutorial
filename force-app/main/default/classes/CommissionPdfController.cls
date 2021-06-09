public with sharing class CommissionPdfController {
    
    public MR_Commission_Calculator__c mrCalc{get;set;}
    public CPQUtility.AccountDetailsWrapper detailWrap{get;set;}
    public String createdByName{get;set;}
     public String isccmr{get;set;} 
    
    public CommissionPdfController(ApexPages.StandardController controller) {
        system.debug('in std controller***************************');
        String usertheme = UserInfo.getUiTheme();
        system.debug('usertheme in'+usertheme);
        system.debug('in custom controller***************************');
        Id mrCalcId= apexpages.currentpage().getparameters().get('id');
        isccmr= apexpages.currentpage().getparameters().get('isccmr');
        String motoNum= apexpages.currentpage().getparameters().get('motoNum');
        String accountId= apexpages.currentpage().getparameters().get('accountId');
        String partnerId= apexpages.currentpage().getparameters().get('partnerId');
        createdByName = UserInfo.getName();
        detailWrap=  CPQUtility.fetchAccountDetails( motoNum, partnerId , accountId);
        String fileName=detailWrap.partnerAccount.Name;
        //MONTH(TODAY())+'-'+DAY(TODAY())+'-'+YEAR(TODAY());
        Integer mon = Date.TODAY().Month();
        Integer day = Date.TODAY().Day();
        Integer year = Date.TODAY().year();
        String PdfDate= mon+'-'+day+'-'+year;
        ///+'-'Date.TODAY().Day()+'-'+Date.TODAY().year()
        fileName = fileName.replaceAll(' ','_' );
        fileName=fileName.replaceAll(',','_' );
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename='+fileName+'_'+PdfDate+'.pdf'); 
        system.debug('detailWrap is**********'+detailWrap);
    }
    
 
    
}