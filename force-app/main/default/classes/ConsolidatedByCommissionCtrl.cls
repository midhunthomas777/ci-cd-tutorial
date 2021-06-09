public class ConsolidatedByCommissionCtrl {
    
    public String createdByName { get; set; }
    public string accName { get; set; }
    public String mcnNum { get; set; }
    public String mcnRTM { get; set; }
    public String TOA { get; set; }
    public String OTCD { get; set; }
    public String TComPer { get; set; }
    public String TComDolr { get; set; }
    public String cmts { get; set; }
    
    public List<ConsolidatedBy_Partner_Information__mdt> lstPartners { get; set; }
    
    public ConsolidatedByCommissionCtrl() {
        string JsonString = apexpages.currentpage().getparameters().get('rs');
        accName = apexpages.currentpage().getparameters().get('accName');
        mcnNum = apexpages.currentpage().getparameters().get('mcnNum');
        mcnRTM = apexpages.currentpage().getparameters().get('mcnRTM');
        TOA = apexpages.currentpage().getparameters().get('TOA');
        OTCD = apexpages.currentpage().getparameters().get('OTCD');
        TComPer = apexpages.currentpage().getparameters().get('TComPer');
        TComDolr = apexpages.currentpage().getparameters().get('TComDolr');
        cmts = apexpages.currentpage().getparameters().get('cmts');
        
        lstPartners = (List<ConsolidatedBy_Partner_Information__mdt>) JSON.deserialize(JsonString,List<ConsolidatedBy_Partner_Information__mdt>.class);
        //system.debug('lstPartners is'+lstPartners);
        createdByName = UserInfo.getName(); 
        Integer mon = Date.TODAY().Month();
        Integer day = Date.TODAY().Day();
        Integer year = Date.TODAY().year();
        String PdfDate= mon+'-'+day+'-'+year;
      //  string fileName= EncodingUtil.base64Encode(accName);
        PdfDate= EncodingUtil.urlEncode(PdfDate, 'ASCII');
      //  String fileName = EncodingUtil.urlEncode(accName, 'ASCII');
        String fileName = accName.replaceAll(' ','_' );
        fileName=fileName.replaceAll(',','_' );
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename='+fileName+'_'+PdfDate+'.pdf'); 
    }
}