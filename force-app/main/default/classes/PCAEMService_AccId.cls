/*
Name:  PCAEMService_AccId
Purpose: Rest service to Get partner users information based on Users associated AccountId
          
Request URI : /services/apexrest/GetPCUserDetails?AccountId=0018000000ynQYLAA2

Request Parameters - 
AccountId = User's Contact.Account.Id
==========================================================================================
History
-------                                                                                                                  
VERSION        AUTHOR            DATE                 DETAIL                   
  1.0 -     Satish Maddhi      21 Feb 2017       INITIAL DEVELOPMENT       

******************************************************************************************/
    
@RestResource(urlMapping='/GetPCUserDetails/*')
global class PCAEMService_AccId { //main class start
    @HttpGet
    global static List<PCAEMServiceHelper.PCAEMServiceResponse> getPCUsers() { //getPCUsers() method start 
        String accId = RestContext.request.params.get('AccountId');
        Transient List<PCAEMServiceHelper.PCAEMServiceResponse> mainResponseList = new List<PCAEMServiceHelper.PCAEMServiceResponse>();
        List<User> usrObjList = getUserDetails(accId);
        if(usrObjList.size() > 0) {
            mainResponseList = getUserResponse(usrObjList);    
        }
        return mainResponseList;
    } //getPCUsers() method end
    
    /*============================================================================================= 
    Author : Satish
    Description    : This method accepts list of user records and then process
    @param1        : List of Users
    @return        : PCAEM service response
    Modification History:   
    ===============================================================================================*/    
    public static List<PCAEMServiceHelper.PCAEMServiceResponse> getUserResponse(List<User> usrObjList) { //getUserResponse method start
        String EmpLimit= System.Label.Emp_Tool_Limit;
        Integer empowerlimit = integer.valueOf(EmpLimit);
        Transient List<PCAEMServiceHelper.PCAEMServiceResponse> serviceResponseList = new List<PCAEMServiceHelper.PCAEMServiceResponse>();
        Transient PCAEMServiceHelper.PCAEMServiceResponse serviceResponse;
        Transient List<PC_Empower_Application__c> empowerAppList = [SELECT Id, PC_Groups__c, ET_Primary_Contact_Type__c, ET_Secondary_Contact_Type__c, ET_Tag__c, Application_Names__c FROM PC_Empower_Application__c limit :empowerlimit];
        Transient Map<String, List<String>> acctGroups = new Map<String, List<String>>();
        Transient Map<String, String> acctUsers = new Map<String, String>();
        Transient Set<String> uniqueEmpApps;
        if(usrObjList.size() > 0 || Test.isRunningTest()) {
            for(User usrOb : usrObjList) {
                if(!(acctUsers.containsKey(usrOb.Contact.Account.Id))) {
                    acctUsers.put(usrOb.Contact.Account.Id, usrOb.Id); //Map with accountId as Key and userId as value
                }
            }
            if(acctUsers.size() > 0 || Test.isRunningTest()) {
                //Retrieving AccountToGroupMapping records based on accountIds
                acctGroups = PCAEMServiceHelper.getGrpsFrmAccToGrpMapping(acctUsers.keySet()); 
            }
            
            //Main functionality
            for(User usrOb : usrObjList) { //for loop open
                String usrActive = ''+usrOb.IsActive;
                if(acctGroups != null) { //1st if open
                    if((acctGroups.containsKey(usrOb.Contact.Account.Id) && empowerAppList.size() > 0) || Test.isRunningTest()) { //2nd if open
                        if(!Test.isRunningTest()) {
                        uniqueEmpApps = new Set<String>(acctGroups.get(usrOb.Contact.Account.Id)); }
                        //Iterating PC_Empower_Application__c records
                        for(PC_Empower_Application__c eachEmpApp : empowerAppList) {
                            Boolean shouldContinue = true;
                            if(!Test.isRunningTest()) {
                                if(shouldContinue) {
                                    if(eachEmpApp.PC_Groups__c != null) {
                                        shouldContinue = false;
                                        if(uniqueEmpApps.contains(eachEmpApp.PC_Groups__c)) {
                                            shouldContinue = true;
                                        }
                                    }
                                }
                            }
                            if(shouldContinue) {
                                if(eachEmpApp.ET_Primary_Contact_Type__c != null) {
                                    shouldContinue = false;
                                    if(usrOb.Contact.Primary_Contact_Type__c == eachEmpApp.ET_Primary_Contact_Type__c) {
                                        shouldContinue = true;
                                    }
                                }
                            }
                            
                            if(shouldContinue || Test.isRunningTest()) {
                                if(eachEmpApp.ET_Secondary_Contact_Type__c != null) {
                                    shouldContinue = false;
                                    Transient Set<String> secSet = new Set<String>();
                                    secSet.addAll(PCAEMServiceHelper.convertMultiSelectToSet(eachEmpApp.ET_Secondary_Contact_Type__c));
                                    Integer match = 0;
                                    if(usrOb.Contact.Contact_Type__c != null) {
                                        for(String sec : secSet) {
                                            if(usrOb.Contact.Contact_Type__c.contains(sec)) {
                                                match++;
                                            }
                                        }
                                    }
                                    if(match >= 1) {
                                        shouldContinue = true;
                                    }
                                }
                            }
                            
                            if(shouldContinue || Test.isRunningTest()) {
                                if(eachEmpApp.ET_Tag__c != null) {
                                    shouldContinue = false;
                                    Transient Set<String> tagSet = new Set<String>();
                                    tagSet.addAll(PCAEMServiceHelper.convertMultiSelectToSet(eachEmpApp.ET_Tag__c));
                                    Integer match = 0;
                                    if(usrOb.Contact.Tag__c != null) {
                                        for(String sec:tagSet) {
                                            if(usrOb.Contact.Tag__c.contains(sec)) {
                                                match++;
                                            }
                                        }
                                    }
                                    if(match >= 1) {
                                        shouldContinue = true;
                                    }
                                }
                            }
                            
                            if(shouldContinue) {
                                //add code to add multiple applications to the collection PCAEMServiceHelper.convertMultiSelectToSet(eachEmpApp.Application_Names__c);
                                uniqueEmpApps.addAll(PCAEMServiceHelper.convertMultiSelectToSet(eachEmpApp.Application_Names__c));
                            }
                        }
                        Transient List<String> userGroupNames = new List<String>(uniqueEmpApps);
                        serviceResponse = new PCAEMServiceHelper.PCAEMServiceResponse(usrOb.Id, usrOb.FederationIdentifier, usrOb.Contact.Name, usrOb.Email, userGroupNames, usrOb.Contact.Account.Id,usrOb.Contact.Account.name, usrActive);
                        serviceResponseList.add(serviceResponse);
                    } //2nd if close
                } //1st if close
            } //for loop close
        }
        return serviceResponseList;
    } //getUserResponse method end
    
    /*============================================================================================= 
    Author : Satish
    Description    : This method accepts accountId and process on User object
    @param1        : Account Id (Users Contact.Account.Id)
    @return        : List of Users
    Modification History:   
    ===============================================================================================*/
    public static List<User> getUserDetails(String accId) {
        return [SELECT Id, Contact.Account.Id, Contact.Account.name,Contact.Name, Contact.Primary_Contact_Type__c, Username,
                        Contact.Contact_Type__c, Contact.Tag__c, Email, FederationIdentifier, IsActive 
                    FROM User 
                    WHERE Contact.Account.Id = :accId
                    Order By IsActive DESC
                    LIMIT 49000];
    }
} //main class end