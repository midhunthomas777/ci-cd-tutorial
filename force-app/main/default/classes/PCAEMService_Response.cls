/*
Name:  PCAEMService_Response
Purpose: Rest service to Get partner users information based on provided offset(index)
          
Request URI : https://motorolasolutions.my.salesforce.com/services/apexrest/GetPCResponse?lastMod=false&bGrp=shr&getReg=NAMR
Request URI : https://motorolasolutions.my.salesforce.com/services/apexrest/GetPCResponse?lastMod=false&bGrp=shr&getReg=NAMR&hours=24

/services/apexrest/GetPCResponse?lastMod=false&bGrp=shr&getReg=NAMR&hours=24&pgmLevel=gold&offsetFrm=10&offsetTo=100

Request Parameters - 
* lastMod   - It takes values true or false
* getReg    - It takes semicolon separated region values. for example getReg=NAMR;EMEA
* bGrp      - It takes business group either gov or shr
* pgmLevel  - It takes programLevel (Gold, Silver, Platinum)
* hours     - It takes last modified hours
* offsetFrm - It takes offset value(index from) like start position
* offsetTo  - It takes offset value(index to) like end position 

==========================================================================================
History
-------                                                                                                                  
VERSION        AUTHOR            DATE              DETAIL                   
  1.0 -     Satish Maddhi      04 Jan 2017       INITIAL DEVELOPMENT       

******************************************************************************************/
    
@RestResource(urlMapping='/GetPCResponse/*')
global class PCAEMService_Response { //main class start
    @HttpGet
    global static List<PCAEMServiceHelper.PCAEMServiceResponse> getPartnerUserInfo() { //getPartnerUserInfo() method start 
        String lastModified = RestContext.request.params.get('lastMod');
        String getRegions = RestContext.request.params.get('getReg');
        String busGrp = RestContext.request.params.get('bGrp');
        String programLevel = RestContext.request.params.get('pgmLevel');
        String timeInterval = RestContext.request.params.get('hours');
        String startPosition = RestContext.request.params.get('offsetFrm');
        String endPosition = RestContext.request.params.get('offsetTo');
        List<PCAEMServiceHelper.PCAEMServiceResponse> partnerResponseList = new List<PCAEMServiceHelper.PCAEMServiceResponse>();
        partnerResponseList = PCAEMServiceHelper.getPCResponse(lastModified,getRegions,busGrp,programLevel,timeInterval,startPosition,endPosition);
        return partnerResponseList;
    } //getPartnerUserInfo() method end
} //main class end