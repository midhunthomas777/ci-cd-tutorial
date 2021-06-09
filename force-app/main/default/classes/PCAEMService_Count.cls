/*
Name:  PCAEMService_Count
Purpose: Rest service to Get count of partner users
          
Request URI : https://motorolasolutions.my.salesforce.com/services/apexrest/GetPCCount?lastMod=false&bGrp=shr&getReg=NAMR&pgmLevel=gold
Request URI : https://motorolasolutions.my.salesforce.com/services/apexrest/GetPCCount?lastMod=false&bGrp=shr&getReg=NAMR&hours=24&pgmLevel=gold
/services/apexrest/GetPCCount?lastMod=false&bGrp=shr&getReg=NAMR&hours=24&pgmLevel=gold

Request Parameters - 
* lastMod 	- It takes values true or false
* getReg 	- It takes semicolon separated region values. for example getReg=NAMR;EMEA
* bGrp 		- It takes business group either gov or shr
* pgmLevel 	- It takes programLevel (Gold, Silver, Platinum)
* hours 	- It takes last modified hours

==========================================================================================
History
-------                                                                                                                  
VERSION        AUTHOR            DATE                 DETAIL                   
  1.0 -     Satish Maddhi      04 Jan 2017       INITIAL DEVELOPMENT       

******************************************************************************************/
    
@RestResource(urlMapping='/GetPCCount/*')
global class PCAEMService_Count { //main class start
    @HttpGet
    global static Integer getPartnerUserCount() { //getPartnerUserCount() method start 
        String lastModified = RestContext.request.params.get('lastMod');
        String getRegions = RestContext.request.params.get('getReg');
        String busGrp = RestContext.request.params.get('bGrp');
        String programLevel = RestContext.request.params.get('pgmLevel');
        String timeInterval = RestContext.request.params.get('hours');
        List<User> userObjList = new List<User>();
        userObjList = PCAEMServiceHelper.getPCCount(lastModified,getRegions,busGrp,programLevel,timeInterval);
        return userObjList.size();
    } //getPartnerUserCount() method end
} //main class end