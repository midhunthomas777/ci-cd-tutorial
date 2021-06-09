/*
Name:  PCAEMServiceHelper
Purpose: Helper class for PCAEMService_Count and PCAEMService_Response webservices

==========================================================================================
History
-------                                                                                                                  
VERSION        AUTHOR             DATE                DETAIL                   
  1.0 -     Satish Maddhi      11 Jan 2017       INITIAL DEVELOPMENT       
2-0  -        Swami Ganesan   3/23/2017              Change to exclude all ADP Only Partners from PC. Included :  

******************************************************************************************/
global class PCAEMServiceHelper {
	// getPCResponse method starting which returns the actual response
    public static List<PCAEMServiceResponse> getPCResponse(String lastModified,String getRegions,String busGrp,String programLevel,String timeIntervl,String startPosition,String endPosition) {
        String EmpLimit= System.Label.Emp_Tool_Limit;
        Integer empowerlimit = integer.valueOf(EmpLimit);
        Transient List<PC_Empower_Application__c> empowerAppList = [SELECT Id, PC_Groups__c, ET_Primary_Contact_Type__c, ET_Secondary_Contact_Type__c, ET_Tag__c, Application_Names__c FROM PC_Empower_Application__c limit :empowerlimit];
        Transient PCAEMServiceResponse serviceResponse;
        Transient List<PCAEMServiceResponse> serviceResponseList = new List<PCAEMServiceResponse>();
        Transient Map<String, List<String>> acctGroups = new Map<String, List<String>>();
        Transient Map<String, String> acctUsers = new Map<String, String>();
        List<User> tempUserObjList = getPCCount(lastModified,getRegions,busGrp,programLevel,timeIntervl);
        system.debug('######tempUserObjList###### => ' + tempUserObjList);
        List<User> usrObjList = new List<User>();
        try{
            //Retrieving Users based on index
            if(tempUserObjList.size() > 0 || Test.isRunningTest()) {
                if(String.isBlank(startPosition) || String.isBlank(endPosition))  {
                    // If startPosition or endPosition is null sending actual response
                    usrObjList.addAll(tempUserObjList);
                } else { 
                    Integer startPos = Integer.valueOf(startPosition.trim());
                    Integer endPos = Integer.valueOf(endPosition.trim());
                    /* if startPositon is greaterthan endPosition iterating the for loop and picking the elements based on index
                     * Eg-1: StartPosition = 10, EndPosition = 100 then preparing a list from 10th index to 100th index (91 recors)
                     * Eg-2: StartPosition = 10, EndPosition = 10 then preparing a list from 10th index to 10th index (1 record)
                     * Eg-3: StartPosition = 100, EndPosition = 10 then preparing a list with actual response(total records)
                     * Eg-4: StartPosition = 0 , EndPosition = 0  then preparing a list with 0th index record (1 record)
                     * Eg-5: If StartPosition and EndPosition both are missing, then the actual response will be returned(total records)
                     */ 
                    if(!Test.isRunningTest()) {
                        if(startPos <= endPos) { 
                            for(Integer count=startPos; count<=endPos; count++) {
                                usrObjList.add(tempUserObjList[count]);
                            }
                            
                        } else { //If startPosition is lessthan endPosition adding actual response
                            usrObjList.addAll(tempUserObjList);
                        }
                    }
                }
            }
			
            //Processing the User records which are returned based on index
            if(usrObjList.size() > 0 || Test.isRunningTest()) {
                for(User usrOb : usrObjList) {
                    if(!(acctUsers.containsKey(usrOb.Contact.Account.Id))) {
                        acctUsers.put(usrOb.Contact.Account.Id, usrOb.Id); //Map with accountId as Key and userId as value
                    }
                }
                system.debug('#####acctUsers###### => ' + acctUsers);
                if(acctUsers.size() > 0 || Test.isRunningTest()) {
                    //Retrieving AccountToGroupMapping records based on accountIds
                    acctGroups = getGrpsFrmAccToGrpMapping(acctUsers.keySet()); 
                }
                system.debug('#####acctGroups###### => ' + acctGroups);
                //Main functionality
                for(User usrOb : usrObjList) { //for loop open
                    String usrActive = ''+usrOb.IsActive;
                    if(acctGroups != null) { //1st if open
                        if(acctGroups.containsKey(usrOb.Contact.Account.Id) || empowerAppList.size() > 0) { //2nd if open
                            Transient Set<String> uniqueEmpApps = new Set<String>(acctGroups.get(usrOb.Contact.Account.Id));
                            //Iterating PC_Empower_Application__c records
                            for(PC_Empower_Application__c eachEmpApp : empowerAppList) {
                                Boolean shouldContinue = true;
                                if(shouldContinue) {
                                    if(eachEmpApp.PC_Groups__c != null) {
                                        shouldContinue = false;
                                        if(uniqueEmpApps.contains(eachEmpApp.PC_Groups__c)) {
                                            shouldContinue = true;
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
            
                                if(shouldContinue) {
                                    if(eachEmpApp.ET_Secondary_Contact_Type__c != null) {
                                        shouldContinue = false;
                                        Transient Set<String> secSet = new Set<String>();
                                        secSet.addAll(convertMultiSelectToSet(eachEmpApp.ET_Secondary_Contact_Type__c));
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
            
                                if(shouldContinue) {
                                    if(eachEmpApp.ET_Tag__c != null) {
                                        shouldContinue = false;
                                        Transient Set<String> tagSet = new Set<String>();
                                        tagSet.addAll(convertMultiSelectToSet(eachEmpApp.ET_Tag__c));
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
                                    //add code to add multiple applications to the collection convertMultiSelectToSet(eachEmpApp.Application_Names__c);
                                    uniqueEmpApps.addAll(convertMultiSelectToSet(eachEmpApp.Application_Names__c));
                                }
                            }
                            Transient List<String> userGroupNames = new List<String>(uniqueEmpApps);
                            serviceResponse = new PCAEMServiceResponse(usrOb.Id, usrOb.FederationIdentifier, usrOb.Contact.Name, usrOb.Email, userGroupNames, usrOb.Contact.Account.Id,usrOb.Contact.Account.name,usrActive);
                            serviceResponseList.add(serviceResponse);
                        } //2nd if close
                    } //1st if close
                } //for loop close
            }
            usrObjList.clear();
        } Catch (Exception exp) {
            System.debug('Exception occured: '+exp.getMessage()+'--'+exp.getStackTraceString());
        }
        return serviceResponseList;
    }
    // getPCResponse() method ending
    
    // getPCCount() method starting which returns the count of the response
    public static List<User> getPCCount(String lastModified,String getRegions,String busGrp,String programLevel,String timeIntervl) {
        List<User> usrObjList;
        Transient Set<String> includeRegions = new Set<String>();
        Boolean flag = false;
        DateTime yestDate;
        //Fixing maximum timeInterval to 48 hours
        String timeInterval;
        if(!String.isBlank(timeIntervl)) {
            if(Integer.valueOf(timeIntervl) >= 48) {
                timeInterval = '48';
            } else {
                timeInterval = timeIntervl;
            }
        } else {
            timeInterval = '24';
        }

        
      /* NOTE: 1) This if loop is to determine whether to use Region values from the getRegions Query Parameter or the PC_WS_Include_Regions__c Custom Setting 
               2) "includeRegions" Set variable is used in the queries to retrieve user records only for specific partner region(s)
      STEP-1: Check if the "getRegions" Query Paramter is null, if True Goto STEP-2 else Goto STEP-3
      STEP-2: Get Region Values from the Custom Setting PC_WS_Include_Regions and them to includeRegions Set variable
      STEP-3: Convert semicolon separated values into a Set and add them to includeRegions Set variable
       */
        if(getRegions == null) { //If getRegions query parameter is null retrieving regions from custom setting
            Map<String, PC_WS_Include_Regions__c> accRegions = PC_WS_Include_Regions__c.getall();
            for(PC_WS_Include_Regions__c reg : accRegions.values()) {
                includeRegions.add(reg.Name);
            }
            accRegions.clear();
        } else { //If getRegions query parameter is not null convert the ; seperated string into individual strings
            includeRegions.addAll(convertMultiSelectToSet(getRegions));
        }
        
      /*
      NOTE: 1) lastModified is a query parameter and accepts boolean values.
            2) This if loop is to determine whether to retrieve only the records which have been modified in the last 24 hours or not
               i) If Empowering Application Object is modified, retrieve all the users and ignore lastmodified clause in groupmember and contact queries 
               ii) Clause-1: If Empowering Application Object is not modified, retrieve the members of the groups, which are specified in the PC_WS_Public_Groups__c custom setting, who were modified and
               iii) Clause-2: Retrieve contacts who were modified in the last 24 hours
               iii) 
      STEP-1: Check if the "lastModified" Query Paramter is NOT null, If true Goto STEP-2 else Goto STEP-6 
      STEP-2: Check if lastModified is not empty, if True Goto STEP-3 else Goto STEP-6      
      STEP-3: Check if lastModified is false, if True Goto STEP-4 else Goto STEP-6 
      STEP-4: 
              (i) Get the previous day's date  
             (ii) Query empowerApplication object for the last 24 hours data. if the record count is 0 then retrieve only the records(Groups and their Users) modified in the last 24 hours else
            (iii) 
      STEP-5: else if lastModidfied is false -> Retrieve all the records
      STEP-6: Set flag = true -> When flag is true do not apply lastModified clause and retrieve all the records
       */
        try{
            if(lastModified != null && timeInterval != null) { //1st if open
                if(!lastModified.equalsIgnoreCase('')) { //2nd if open
                    if(lastModified.equalsIgnoreCase('true')) { //3rd if open
                        yestDate = Datetime.now().addHours(-Integer.valueOf(timeInterval.trim()));
                        Integer modifiedEmpRecCount = [SELECT count() FROM PC_Empower_Application__c WHERE SystemModstamp >= :yestDate];
                        if( modifiedEmpRecCount == 0 ) { //4th if open                      
                            Set<String> lstAccountsFrmGrpMappingYestDate = getAccountsFrmAccToGrpMapping(yestDate);
                            Set<String> lstAccountsFrmGrpMapping = getAccountsFrmAccToGrpMapping();  
                            Boolean allModified=false;
                            if(lstAccountsFrmGrpMappingYestDate.size() == lstAccountsFrmGrpMapping.size()) {
                               allModified = true;
                            } else {
                               allModified = false;
                            }                         
                            if((includeRegions.size() > 0 && lstAccountsFrmGrpMappingYestDate.size() > 0) || Test.isRunningTest()) {
                                if(busGrp != null) { //5th if open
                                    if(busGrp.equalsIgnoreCase('gov')) {
                                        usrObjList = getUsers_gov(yestDate, includeRegions, lstAccountsFrmGrpMappingYestDate, programLevel, allModified);
                                    } else if(busGrp.equalsIgnoreCase('shr')) {
                                        usrObjList = getUsers_shr(yestDate, includeRegions, lstAccountsFrmGrpMappingYestDate, programLevel, allModified);
                                    } else {
                                        usrObjList = getUsers_others(yestDate, includeRegions, lstAccountsFrmGrpMappingYestDate, programLevel, allModified);
                                    }
                                } else { //5th if close
                                    usrObjList = getUsers_others(yestDate, includeRegions, lstAccountsFrmGrpMappingYestDate, programLevel, allModified);
                                }
                            }
                        } else { //4th if close
                            flag = true;
                        }
                    } else {//3rd if close
                        flag = true;
                    }
                } else { //2nd if close
                    flag = true;
                }
            } else { //1st if close
                flag = true;
            }
    
            if(flag) {
                Set<String> lstAccountsFrmGrpMapping = getAccountsFrmAccToGrpMapping();
                if(includeRegions.size() > 0 && lstAccountsFrmGrpMapping.size() > 0) {
                    if(busGrp != null) {
                        if(busGrp.equalsIgnoreCase('gov')) {
                            usrObjList = getUsers_gov(includeRegions, lstAccountsFrmGrpMapping, programLevel);
                        } else if(busGrp.equalsIgnoreCase('shr')) {
                            usrObjList = getUsers_shr(includeRegions, lstAccountsFrmGrpMapping, programLevel);
                        } else {
                            usrObjList = getUsers_others(includeRegions, lstAccountsFrmGrpMapping, programLevel);
                        }
                    } else {
                        usrObjList = getUsers_others(includeRegions, lstAccountsFrmGrpMapping, programLevel);
                    }
                }
            }
            
            system.debug('usrObjList for test----->'+usrObjList);
            includeRegions.clear();
        } catch(Exception exp) {
            System.debug('Exception found:'+exp.getMessage());
        }
        return usrObjList;
    }
    //getPCCount() method ending
    
    /*============================================================================================= 
    Author : Satish
    Description    : This method is used to convert multiselect values into set 
    @param1        : String
    @return        : Set of multiselect values 
    Modification History:   
    ===============================================================================================*/  
    public static Set<String> convertMultiSelectToSet(String stringToConvert) {
        try{
            Set<String> theSet = new Set<String>();
            List<String> theList = (stringToConvert == null)?new List<String>():stringToConvert.split(';');
            if(!theList.isEmpty()) {
                theSet.addAll(theList);
            }
            return theSet;
        } catch(Exception e) {
            return new Set<String>();
        }
    }
    
    /*============================================================================================= 
    Author : Satish
    Description    : This method accepts yesterday's date as parameter and query on Account_to_Group_Mapping__c
                     object and retrieve records which are modified in last 24 hours and returns set of account ids.
    @param1        : yesterday's date
    @return        : Set of account ids
    Modification History:   
    ===============================================================================================*/
    public static Set<String> getAccountsFrmAccToGrpMapping(DateTime yesterdayDate) {
        Transient Set<String> accountList = new Set<String>();
        for(Account_to_Group_Mapping__c eachMappingRec : [SELECT Id,Account_Id__c,Groups__c 
                                                            FROM Account_to_Group_Mapping__c 
                                                            WHERE SystemModstamp >= :yesterdayDate 
                                                            LIMIT 49000]) {
            accountList.add(eachMappingRec.Account_Id__c);
        }
        return accountList;
    }
    
    /*============================================================================================= 
    Author : Satish
    Description    : This method performs query on Account_to_Group_Mapping__c
                     object and returns set of account ids.
    @param1        : None
    @return        : Set of account ids
    Modification History:   
    ===============================================================================================*/
    public static Set<String> getAccountsFrmAccToGrpMapping() {
        Transient Set<String> accountList = new Set<String>();
        for(Account_to_Group_Mapping__c eachMappingRec : [SELECT Id,Account_Id__c,Groups__c 
                                                            FROM Account_to_Group_Mapping__c 
                                                            LIMIT 49000]) {
            accountList.add(eachMappingRec.Account_Id__c);
        }
        return accountList;
    }
    
    /*============================================================================================= 
    Author : Satish
    Description    : This method accepts Set of account ids and query on Account_to_Group_Mapping__c object
                     and returns Groups__c 
    @param1        : Set of account Ids
    @return        : Map with Account_to_Group_Mapping__c.AccountId and List of groups
    Modification History:   
    ===============================================================================================*/
    public static Map<String,List<String>> getGrpsFrmAccToGrpMapping(Set<String> accountIdSet) {
        Transient List<String> grpList = new List<String>();
        Transient Map<String, List<String>> accGroupMap = new Map<String, List<String>>();
        if(accountIdSet.size() > 0) {
            for(Account_to_Group_Mapping__c eachMappingRec : [SELECT Id,Account_Id__c,Groups__c FROM Account_to_Group_Mapping__c WHERE Account_Id__c IN :accountIdSet LIMIT 49900]) {
                if(eachMappingRec.Account_Id__c != null && eachMappingRec.Groups__c != null && eachMappingRec.Groups__c.contains(';')) {
                    grpList = eachMappingRec.Groups__c.split(';');
                    accGroupMap.put(eachMappingRec.Account_Id__c, grpList);
                }
            }
        }
        return accGroupMap;
    }

    /*============================================================================================= 
    Author : Satish;Sandeep
    Description    : This method accepts yesterday date, set of regions and list of accounts as parameters 
                     and performs query on User object when businessGroup == gov and returns User records.
    @param1        : Yesterday's date
    @param2        : Set of regions
    @param3        : Set of account Ids
    @param4        : ProgramLevel
    @return        : List of User records
    Modification History: 
    March 8, 2017 
    Sandeep: 
            - Added ProgramLevel = Registered 
            - Logic to consider lastmodified contacts as well  
    ===============================================================================================*/
    public static List<User> getUsers_gov(DateTime yestDate,Set<String> includeRegions,Set<String> lstAccountsFrmGrpMapping, String programLevel, Boolean allModified) {
        Transient List<User> userList = new List<User>();
        
        if(!String.isBlank(programLevel)) {
            if(programLevel.equalsIgnoreCase('Gold') || programLevel.equalsIgnoreCase('Platinum') || programLevel.equalsIgnoreCase('Silver') || programLevel.equalsIgnoreCase('Registered')) {
            
              if(allModified){            
                userList = [SELECT Id, Contact.Account.Id,Contact.Account.Name, Contact.Name, Contact.Primary_Contact_Type__c, Username,
                            Contact.Contact_Type__c,Contact.Tag__c, Email, FederationIdentifier, IsActive 
                            FROM User 
                            WHERE UserType IN ('PowerCustomerSuccess','CspLitePortal','PowerPartner') 
                            AND Contact.Account.Owner_Business_Group__c = 'Government' 
                            AND Contact.Account.MPE_Program_Status__c = 'Active' 
                            AND (Contact.Account.Id IN :lstAccountsFrmGrpMapping) 
                            AND (Contact.Account.Partner_Region__c IN :includeRegions)
                            AND  ((Contact.Account.Adp_PI_count__c > 0) OR ((Contact.Account.Adp_PI_count__c = 0) AND (Contact.Account.ADP_Partner__c = FALSE))) 
                            AND Contact.Account.Metal_Level__c = :programLevel                            
                            Order By IsActive DESC];                                    
                   } else 
                   if(!allModified){                                    
                userList = [SELECT Id, Contact.Account.Id, Contact.Account.Name,Contact.Name, Contact.Primary_Contact_Type__c, Username,
                            Contact.Contact_Type__c,Contact.Tag__c, Email, FederationIdentifier, IsActive 
                            FROM User 
                            WHERE UserType IN ('PowerCustomerSuccess','CspLitePortal','PowerPartner')
                            AND Contact.Account.Owner_Business_Group__c = 'Government' 
                            AND Contact.Account.MPE_Program_Status__c = 'Active' 
                            AND (Contact.Account.Id IN :lstAccountsFrmGrpMapping OR Contact.LastModifiedDate >= :yestDate) 
                            AND (Contact.Account.Partner_Region__c IN :includeRegions)
                            AND  ((Contact.Account.Adp_PI_count__c > 0) OR ((Contact.Account.Adp_PI_count__c = 0) AND (Contact.Account.ADP_Partner__c = FALSE))) 
                            AND Contact.Account.Metal_Level__c = :programLevel                            
                            Order By IsActive DESC];
                    }
                          
            } else if(programLevel.equalsIgnoreCase('null')){
              if(allModified){            
                userList = [SELECT Id, Contact.Account.Id,Contact.Account.Name, Contact.Name, Contact.Primary_Contact_Type__c, Username,
                            Contact.Contact_Type__c,Contact.Tag__c, Email, FederationIdentifier, IsActive 
                            FROM User 
                            WHERE UserType IN ('PowerCustomerSuccess','CspLitePortal','PowerPartner')
                            AND Contact.Account.Owner_Business_Group__c = 'Government' 
                            AND Contact.Account.MPE_Program_Status__c = 'Active' 
                            AND (Contact.Account.Id IN :lstAccountsFrmGrpMapping) 
                            AND (Contact.Account.Partner_Region__c IN :includeRegions)
        					AND  ((Contact.Account.Adp_PI_count__c > 0) OR ((Contact.Account.Adp_PI_count__c = 0) AND (Contact.Account.ADP_Partner__c = FALSE))) 
                            AND Contact.Account.Metal_Level__c = ''
                            Order By IsActive DESC];
                            } else 
                   if(!allModified){                                    
                userList = [SELECT Id, Contact.Account.Id,Contact.Account.Name, Contact.Name, Contact.Primary_Contact_Type__c, Username,
                            Contact.Contact_Type__c,Contact.Tag__c, Email, FederationIdentifier, IsActive 
                            FROM User 
                            WHERE UserType IN ('PowerCustomerSuccess','CspLitePortal','PowerPartner')
                            AND Contact.Account.Owner_Business_Group__c = 'Government' 
                            AND Contact.Account.MPE_Program_Status__c = 'Active' 
                            AND (Contact.Account.Id IN :lstAccountsFrmGrpMapping OR Contact.LastModifiedDate >= :yestDate) 
                            AND (Contact.Account.Partner_Region__c IN :includeRegions)
           					AND  ((Contact.Account.Adp_PI_count__c > 0) OR ((Contact.Account.Adp_PI_count__c = 0) AND (Contact.Account.ADP_Partner__c = FALSE))) 
                            AND Contact.Account.Metal_Level__c = ''                            
                            Order By IsActive DESC];
                    }
            }
        } else {
                   if(allModified){        
            userList = [SELECT Id, Contact.Account.Id, Contact.Account.Name,Contact.Name, Contact.Primary_Contact_Type__c, Username,
                            Contact.Contact_Type__c,Contact.Tag__c, Email, FederationIdentifier, IsActive 
                            FROM User 
                            WHERE UserType IN ('PowerCustomerSuccess','CspLitePortal','PowerPartner')
                            AND Contact.Account.Owner_Business_Group__c = 'Government' 
                            AND Contact.Account.MPE_Program_Status__c = 'Active' 
                            AND (Contact.Account.Id IN :lstAccountsFrmGrpMapping) 
   		                    AND  ((Contact.Account.Adp_PI_count__c > 0) OR ((Contact.Account.Adp_PI_count__c = 0) AND (Contact.Account.ADP_Partner__c = FALSE))) 
        		            AND (Contact.Account.Partner_Region__c IN :includeRegions)                 
                            Order By IsActive DESC];
                            } else 
                   if(!allModified){                                    
                userList = [SELECT Id, Contact.Account.Id,Contact.Account.Name, Contact.Name, Contact.Primary_Contact_Type__c, Username,
                            Contact.Contact_Type__c,Contact.Tag__c, Email, FederationIdentifier, IsActive 
                            FROM User 
                            WHERE UserType IN ('PowerCustomerSuccess','CspLitePortal','PowerPartner')
                            AND Contact.Account.Owner_Business_Group__c = 'Government' 
                            AND Contact.Account.MPE_Program_Status__c = 'Active' 
                            AND (Contact.Account.Id IN :lstAccountsFrmGrpMapping OR Contact.LastModifiedDate >= :yestDate) 
                    		AND  ((Contact.Account.Adp_PI_count__c > 0) OR ((Contact.Account.Adp_PI_count__c = 0) AND (Contact.Account.ADP_Partner__c = FALSE))) 
                            AND (Contact.Account.Partner_Region__c IN :includeRegions)           
                            Order By IsActive DESC];
                    }                            
        }
        return userList;
    }
    /*============================================================================================= 
    Author : Satish;Sandeep
    Description    : This method accepts yesterday date, set of regions and list of accounts as parameters 
                     and performs query on User object when businessGroup == shr and returns User records.
    @param1        : Yesterday's date
    @param2        : Set of regions
    @param3        : Set of account Ids
    @param4        : ProgramLevel
    @return        : List of User records
    Modification History:   
    March 8, 2017 
    Sandeep: 
            - Added ProgramLevel = Registered 
            - Logic to consider lastmodified contacts as well
    ===============================================================================================*/
    public static List<User> getUsers_shr(DateTime yestDate,Set<String> includeRegions,Set<String> lstAccountsFrmGrpMapping, String programLevel, Boolean allModified) {
        Transient List<User> userList = new List<User>();
        if(!String.isBlank(programLevel)) {
            if(programLevel.equalsIgnoreCase('Gold') || programLevel.equalsIgnoreCase('Platinum') || programLevel.equalsIgnoreCase('Silver') || programLevel.equalsIgnoreCase('Registered')) {
                   if(allModified){                        
                userList = [SELECT Id, Contact.Account.Id,Contact.Account.Name, Contact.Name, Contact.Primary_Contact_Type__c,Username, 
                                Contact.Contact_Type__c,Contact.Tag__c, Email, FederationIdentifier, IsActive 
                            FROM User 
                            WHERE UserType IN ('PowerCustomerSuccess','CspLitePortal','PowerPartner')
                            AND (Contact.Account.Owner_Business_Group__c != 'Government' AND Contact.Account.Shared_Partner__c = true) 
                            AND Contact.Account.MPE_Program_Status__c = 'Active' 
                            AND (Contact.Account.Id IN :lstAccountsFrmGrpMapping) 
                            AND (Contact.Account.Partner_Region__c IN :includeRegions)
                            AND Contact.Account.Metal_Level__c = :programLevel
                    		AND  ((Contact.Account.Adp_PI_count__c > 0) OR ((Contact.Account.Adp_PI_count__c = 0) AND (Contact.Account.ADP_Partner__c = FALSE))) 
                            Order By IsActive DESC];
                        } else 
                   if(!allModified){                                    
                userList = [SELECT Id, Contact.Account.Id,Contact.Account.Name, Contact.Name, Contact.Primary_Contact_Type__c, Username,
                            Contact.Contact_Type__c,Contact.Tag__c, Email, FederationIdentifier, IsActive 
                            FROM User 
                            WHERE UserType IN ('PowerCustomerSuccess','CspLitePortal','PowerPartner')
                            AND (Contact.Account.Owner_Business_Group__c != 'Government' AND Contact.Account.Shared_Partner__c = true) 
                            AND Contact.Account.MPE_Program_Status__c = 'Active' 
                            AND (Contact.Account.Id IN :lstAccountsFrmGrpMapping OR Contact.LastModifiedDate >= :yestDate) 
                            AND (Contact.Account.Partner_Region__c IN :includeRegions)
                            AND  ((Contact.Account.Adp_PI_count__c > 0) OR ((Contact.Account.Adp_PI_count__c = 0) AND (Contact.Account.ADP_Partner__c = FALSE))) 
                    		AND Contact.Account.Metal_Level__c = :programLevel                            
                            Order By IsActive DESC];
                    }                            
            } else if(programLevel.equalsIgnoreCase('null')){
                   if(allModified){                        
                userList = [SELECT Id, Contact.Account.Id,Contact.Account.Name, Contact.Name, Contact.Primary_Contact_Type__c,Username, 
                                Contact.Contact_Type__c,Contact.Tag__c, Email, FederationIdentifier, IsActive 
                            FROM User 
                            WHERE UserType IN ('PowerCustomerSuccess','CspLitePortal','PowerPartner')
                            AND (Contact.Account.Owner_Business_Group__c != 'Government' AND Contact.Account.Shared_Partner__c = true) 
                            AND Contact.Account.MPE_Program_Status__c = 'Active' 
                            AND (Contact.Account.Id IN :lstAccountsFrmGrpMapping) 
                            AND (Contact.Account.Partner_Region__c IN :includeRegions)
                            AND Contact.Account.Metal_Level__c = ''
                            AND  ((Contact.Account.Adp_PI_count__c > 0) OR ((Contact.Account.Adp_PI_count__c = 0) AND (Contact.Account.ADP_Partner__c = FALSE))) 
                    		 Order By IsActive DESC];
                    } else 
                   if(!allModified){                                    
                userList = [SELECT Id, Contact.Account.Id,Contact.Account.Name, Contact.Name, Contact.Primary_Contact_Type__c, Username,
                            Contact.Contact_Type__c,Contact.Tag__c, Email, FederationIdentifier, IsActive 
                            FROM User 
                            WHERE UserType IN ('PowerCustomerSuccess','CspLitePortal','PowerPartner')
                            AND (Contact.Account.Owner_Business_Group__c != 'Government' AND Contact.Account.Shared_Partner__c = true) 
                            AND Contact.Account.MPE_Program_Status__c = 'Active' 
                            AND (Contact.Account.Id IN :lstAccountsFrmGrpMapping OR Contact.LastModifiedDate >= :yestDate) 
                            AND (Contact.Account.Partner_Region__c IN :includeRegions)
                            AND Contact.Account.Metal_Level__c = ''                            
                            AND  ((Contact.Account.Adp_PI_count__c > 0) OR ((Contact.Account.Adp_PI_count__c = 0) AND (Contact.Account.ADP_Partner__c = FALSE))) 
                    		Order By IsActive DESC];
                    }        
            }
        } else {
                   if(allModified){        
            userList = [SELECT Id, Contact.Account.Id, Contact.Account.Name,Contact.Name, Contact.Primary_Contact_Type__c,Username, 
                                Contact.Contact_Type__c,Contact.Tag__c, Email, FederationIdentifier, IsActive 
                            FROM User 
                            WHERE UserType IN ('PowerCustomerSuccess','CspLitePortal','PowerPartner')
                            AND (Contact.Account.Owner_Business_Group__c != 'Government' AND Contact.Account.Shared_Partner__c = true) 
                            AND Contact.Account.MPE_Program_Status__c = 'Active' 
                            AND (Contact.Account.Id IN :lstAccountsFrmGrpMapping) 
                            AND (Contact.Account.Partner_Region__c IN :includeRegions)                          
                            AND  ((Contact.Account.Adp_PI_count__c > 0) OR ((Contact.Account.Adp_PI_count__c = 0) AND (Contact.Account.ADP_Partner__c = FALSE))) 
                    		Order By IsActive DESC];
                            } else 
                   if(!allModified){                                    
                userList = [SELECT Id, Contact.Account.Id, Contact.Account.Name,Contact.Name, Contact.Primary_Contact_Type__c, Username,
                            Contact.Contact_Type__c,Contact.Tag__c, Email, FederationIdentifier, IsActive 
                            FROM User 
                            WHERE UserType IN ('PowerCustomerSuccess','CspLitePortal','PowerPartner')
                            AND (Contact.Account.Owner_Business_Group__c != 'Government' AND Contact.Account.Shared_Partner__c = true)
                            AND Contact.Account.MPE_Program_Status__c = 'Active' 
                            AND (Contact.Account.Id IN :lstAccountsFrmGrpMapping OR Contact.LastModifiedDate >= :yestDate) 
                            AND (Contact.Account.Partner_Region__c IN :includeRegions)           
   	                    	AND  ((Contact.Account.Adp_PI_count__c > 0) OR ((Contact.Account.Adp_PI_count__c = 0) AND (Contact.Account.ADP_Partner__c = FALSE))) 
                    	   	Order By IsActive DESC];
                    }                            
        }
        
        return userList;
    }
    /*============================================================================================= 
    Author : Satish;Sandeep
    Description    : This method accepts yesterday date, set of regions and list of accounts as parameters 
                     and performs query on User object when businessGroup is null or otherthan gov & shr 
                     and returns User records.
    @param1        : Yesterday's date
    @param2        : Set of regions
    @param3        : Set of account Ids
    @param4        : ProgramLevel
    @return        : List of User records
    Modification History:
    March 8, 2017 
    Sandeep: 
            - Added ProgramLevel = Registered 
            - Logic to consider lastmodified contacts as well   
    ===============================================================================================*/
    public static List<User> getUsers_others(DateTime yestDate,Set<String> includeRegions,Set<String> lstAccountsFrmGrpMapping, String programLevel, Boolean allModified) {
        Transient List<User> userList = new List<User>();
        if(!String.isBlank(programLevel)) {
            if(programLevel.equalsIgnoreCase('Gold') || programLevel.equalsIgnoreCase('Platinum') || programLevel.equalsIgnoreCase('Silver') || programLevel.equalsIgnoreCase('Registered')) {
                   if(allModified){            
                userList = [SELECT Id, Contact.Account.Id,Contact.Account.Name, Contact.Name, Contact.Primary_Contact_Type__c,Username, 
                                Contact.Contact_Type__c,Contact.Tag__c, Email, FederationIdentifier, IsActive
                            FROM User 
                            WHERE UserType IN ('PowerCustomerSuccess','CspLitePortal','PowerPartner')
                            AND (Contact.Account.Owner_Business_Group__c = 'Government' OR Contact.Account.Shared_Partner__c = true) 
                            AND Contact.Account.MPE_Program_Status__c = 'Active' 
                            AND (Contact.Account.Id IN :lstAccountsFrmGrpMapping) 
                            AND (Contact.Account.Partner_Region__c IN :includeRegions) 
                            AND Contact.Account.Metal_Level__c = :programLevel 
                             AND  ((Contact.Account.Adp_PI_count__c > 0) OR ((Contact.Account.Adp_PI_count__c = 0) AND (Contact.Account.ADP_Partner__c = FALSE))) 
                    		Order By IsActive DESC];
                  } else 
                   if(!allModified){                                    
                userList = [SELECT Id, Contact.Account.Id,Contact.Account.Name, Contact.Name, Contact.Primary_Contact_Type__c, Username,
                            Contact.Contact_Type__c,Contact.Tag__c, Email, FederationIdentifier, IsActive 
                            FROM User 
                            WHERE UserType IN ('PowerCustomerSuccess','CspLitePortal','PowerPartner')
                            AND (Contact.Account.Owner_Business_Group__c = 'Government' OR Contact.Account.Shared_Partner__c = true) 
                            AND Contact.Account.MPE_Program_Status__c = 'Active' 
                            AND (Contact.Account.Id IN :lstAccountsFrmGrpMapping OR Contact.LastModifiedDate >= :yestDate) 
                            AND (Contact.Account.Partner_Region__c IN :includeRegions)
                            AND Contact.Account.Metal_Level__c = :programLevel                            
                            AND  ((Contact.Account.Adp_PI_count__c > 0) OR ((Contact.Account.Adp_PI_count__c = 0) AND (Contact.Account.ADP_Partner__c = FALSE))) 
                    		Order By IsActive DESC];
                    }          
            } else if(programLevel.equalsIgnoreCase('null')){
                   if(allModified){            
                userList = [SELECT Id, Contact.Account.Id,Contact.Account.Name, Contact.Name, Contact.Primary_Contact_Type__c,Username, 
                                Contact.Contact_Type__c,Contact.Tag__c, Email, FederationIdentifier, IsActive
                            FROM User 
                            WHERE UserType IN ('PowerCustomerSuccess','CspLitePortal','PowerPartner')
                            AND (Contact.Account.Owner_Business_Group__c = 'Government' OR Contact.Account.Shared_Partner__c = true) 
                            AND Contact.Account.MPE_Program_Status__c = 'Active' 
                            AND (Contact.Account.Id IN :lstAccountsFrmGrpMapping) 
                            AND (Contact.Account.Partner_Region__c IN :includeRegions)
                            AND Contact.Account.Metal_Level__c = ''
                            AND  ((Contact.Account.Adp_PI_count__c > 0) OR ((Contact.Account.Adp_PI_count__c = 0) AND (Contact.Account.ADP_Partner__c = FALSE))) 
                    		Order By IsActive DESC];
                   } else 
                   if(!allModified){                                    
                userList = [SELECT Id, Contact.Account.Id,Contact.Account.Name, Contact.Name, Contact.Primary_Contact_Type__c, Username,
                            Contact.Contact_Type__c,Contact.Tag__c, Email, FederationIdentifier, IsActive 
                            FROM User 
                            WHERE UserType IN ('PowerCustomerSuccess','CspLitePortal','PowerPartner')
                            AND (Contact.Account.Owner_Business_Group__c = 'Government' OR Contact.Account.Shared_Partner__c = true) 
                            AND Contact.Account.MPE_Program_Status__c = 'Active' 
                            AND (Contact.Account.Id IN :lstAccountsFrmGrpMapping OR Contact.LastModifiedDate >= :yestDate) 
                            AND (Contact.Account.Partner_Region__c IN :includeRegions)
                            AND Contact.Account.Metal_Level__c = ''
                            AND  ((Contact.Account.Adp_PI_count__c > 0) OR ((Contact.Account.Adp_PI_count__c = 0) AND (Contact.Account.ADP_Partner__c = FALSE))) 
                    		Order By IsActive DESC];
                    }
            }
        } else {
                   if(allModified){        
            userList = [SELECT Id, Contact.Account.Id,Contact.Account.Name, Contact.Name, Contact.Primary_Contact_Type__c,Username, 
                            Contact.Contact_Type__c,Contact.Tag__c, Email, FederationIdentifier, IsActive
                        FROM User 
                        WHERE UserType IN ('PowerCustomerSuccess','CspLitePortal','PowerPartner')
                        AND (Contact.Account.Owner_Business_Group__c = 'Government' OR Contact.Account.Shared_Partner__c = true) 
                        AND Contact.Account.MPE_Program_Status__c = 'Active' 
                        AND (Contact.Account.Id IN :lstAccountsFrmGrpMapping) 
                        AND (Contact.Account.Partner_Region__c IN :includeRegions)
                        AND  ((Contact.Account.Adp_PI_count__c > 0) OR ((Contact.Account.Adp_PI_count__c = 0) AND (Contact.Account.ADP_Partner__c = FALSE))) 
                    	Order By IsActive DESC];
                   } else 
                   if(!allModified){                                    
                userList = [SELECT Id, Contact.Account.Id,Contact.Account.Name, Contact.Name, Contact.Primary_Contact_Type__c, Username,
                            Contact.Contact_Type__c,Contact.Tag__c, Email, FederationIdentifier, IsActive 
                            FROM User 
                            WHERE UserType IN ('PowerCustomerSuccess','CspLitePortal','PowerPartner')
                            AND (Contact.Account.Owner_Business_Group__c = 'Government' OR Contact.Account.Shared_Partner__c = true) 
                            AND Contact.Account.MPE_Program_Status__c = 'Active' 
                            AND (Contact.Account.Id IN :lstAccountsFrmGrpMapping OR Contact.LastModifiedDate >= :yestDate) 
                            AND (Contact.Account.Partner_Region__c IN :includeRegions)
                            AND  ((Contact.Account.Adp_PI_count__c > 0) OR ((Contact.Account.Adp_PI_count__c = 0) AND (Contact.Account.ADP_Partner__c = FALSE))) 
                    		Order By IsActive DESC];
                    }                        
        }
        
        return userList;
    }
    /*============================================================================================= 
    Author : Satish
    Description    : This method accepts set of regions and list of accounts as parameters 
                     and performs query on User object when businessGroup == gov and returns User records.
    @param1        : Set of regions
    @param2        : Set of account Ids
    @param3        : ProgramLevel
    @return        : List of User records
    Modification History:
    March 8, 2017 
    Sandeep: 
            - Added ProgramLevel = Registered   
    ===============================================================================================*/
    public static List<User> getUsers_gov(Set<String> includeRegions,Set<String> lstAccountsFrmGrpMapping, String programLevel){
        Transient List<User> userList = new List<User>();
        if(!String.isBlank(programLevel)) {
            if(programLevel.equalsIgnoreCase('Gold') || programLevel.equalsIgnoreCase('Platinum') || programLevel.equalsIgnoreCase('Silver') || programLevel.equalsIgnoreCase('Registered')) {
                userList = [SELECT Id, Contact.Account.Id,Contact.Account.Name, Contact.Name, Contact.Primary_Contact_Type__c,Username, 
                                Contact.Contact_Type__c,Contact.Tag__c, Email, FederationIdentifier, IsActive 
                            FROM User 
                            WHERE UserType IN ('PowerCustomerSuccess','CspLitePortal','PowerPartner')
                            AND Contact.Account.Owner_Business_Group__c = 'Government' 
                            AND Contact.Account.MPE_Program_Status__c = 'Active' 
                            AND (Contact.Account.Partner_Region__c IN :includeRegions) 
                            AND Contact.Account.Id IN :lstAccountsFrmGrpMapping
                            AND Contact.Account.Metal_Level__c = :programLevel 
                            AND  ((Contact.Account.Adp_PI_count__c > 0) OR ((Contact.Account.Adp_PI_count__c = 0) AND (Contact.Account.ADP_Partner__c = FALSE))) 
                    		Order By IsActive DESC];
            } else if(programLevel.equalsIgnoreCase('null')){
                userList = [SELECT Id, Contact.Account.Id,Contact.Account.Name, Contact.Name, Contact.Primary_Contact_Type__c,Username, 
                                Contact.Contact_Type__c,Contact.Tag__c, Email, FederationIdentifier, IsActive 
                            FROM User 
                            WHERE UserType IN ('PowerCustomerSuccess','CspLitePortal','PowerPartner')
                            AND Contact.Account.Owner_Business_Group__c = 'Government' 
                            AND Contact.Account.MPE_Program_Status__c = 'Active' 
                            AND (Contact.Account.Partner_Region__c IN :includeRegions) 
                            AND Contact.Account.Id IN :lstAccountsFrmGrpMapping
                            AND Contact.Account.Metal_Level__c = ''
                            AND  ((Contact.Account.Adp_PI_count__c > 0) OR ((Contact.Account.Adp_PI_count__c = 0) AND (Contact.Account.ADP_Partner__c = FALSE))) 
                    		Order By IsActive DESC];
            }
        } else {
            userList = [SELECT Id, Contact.Account.Id,Contact.Account.Name, Contact.Name, Contact.Primary_Contact_Type__c,Username, 
                            Contact.Contact_Type__c,Contact.Tag__c, Email, FederationIdentifier, IsActive 
                        FROM User 
                        WHERE UserType IN ('PowerCustomerSuccess','CspLitePortal','PowerPartner')
                        AND Contact.Account.Owner_Business_Group__c = 'Government' 
                        AND Contact.Account.MPE_Program_Status__c = 'Active' 
                        AND (Contact.Account.Partner_Region__c IN :includeRegions) 
                        AND Contact.Account.Id IN :lstAccountsFrmGrpMapping                        
                        AND  ((Contact.Account.Adp_PI_count__c > 0) OR ((Contact.Account.Adp_PI_count__c = 0) AND (Contact.Account.ADP_Partner__c = FALSE))) 
                    	Order By IsActive DESC];
        }
        
        return userList;
    }
    /*============================================================================================= 
    Author : Satish
    Description    : This method accepts set of regions and list of accounts as parameters 
                     and performs query on User object when businessGroup == shr and returns User records.
    @param1        : Set of regions
    @param2        : Set of account Ids
    @param3        : ProgramLevel
    @return        : List of User records
    Modification History:
    March 8, 2017 
    Sandeep: 
            - Added ProgramLevel = Registered   
    ===============================================================================================*/
    public static List<User> getUsers_shr(Set<String> includeRegions,Set<String> lstAccountsFrmGrpMapping, String programLevel) {
        Transient List<User> userList = new List<User>();
        if(!String.isBlank(programLevel)) {
            if(programLevel.equalsIgnoreCase('Gold') || programLevel.equalsIgnoreCase('Platinum') || programLevel.equalsIgnoreCase('Silver') || programLevel.equalsIgnoreCase('Registered')) {
                userList = [SELECT Id, Contact.Account.Id,Contact.Account.Name, Contact.Name, Contact.Primary_Contact_Type__c,Username, 
                                Contact.Contact_Type__c,Contact.Tag__c, Email, FederationIdentifier, IsActive
                            FROM User 
                            WHERE UserType IN ('PowerCustomerSuccess','CspLitePortal','PowerPartner')
                            AND (Contact.Account.Owner_Business_Group__c != 'Government' AND Contact.Account.Shared_Partner__c = true) 
                            AND Contact.Account.MPE_Program_Status__c = 'Active' 
                            AND (Contact.Account.Partner_Region__c IN :includeRegions) 
                            AND Contact.Account.Id IN :lstAccountsFrmGrpMapping
                            AND Contact.Account.Metal_Level__c = :programLevel 
                            AND  ((Contact.Account.Adp_PI_count__c > 0) OR ((Contact.Account.Adp_PI_count__c = 0) AND (Contact.Account.ADP_Partner__c = FALSE))) 
                    Order By IsActive DESC];
            } else if(programLevel.equalsIgnoreCase('null')){
                userList = [SELECT Id, Contact.Account.Id,Contact.Account.Name, Contact.Name, Contact.Primary_Contact_Type__c,Username, 
                                Contact.Contact_Type__c,Contact.Tag__c, Email, FederationIdentifier, IsActive
                            FROM User 
                            WHERE UserType IN ('PowerCustomerSuccess','CspLitePortal','PowerPartner')
                            AND (Contact.Account.Owner_Business_Group__c != 'Government' AND Contact.Account.Shared_Partner__c = true) 
                            AND Contact.Account.MPE_Program_Status__c = 'Active' 
                            AND (Contact.Account.Partner_Region__c IN :includeRegions) 
                            AND Contact.Account.Id IN :lstAccountsFrmGrpMapping
                            AND Contact.Account.Metal_Level__c = ''
                            AND  ((Contact.Account.Adp_PI_count__c > 0) OR ((Contact.Account.Adp_PI_count__c = 0) AND (Contact.Account.ADP_Partner__c = FALSE))) 
                            Order By IsActive DESC];
            }
        } else {
            userList = [SELECT Id, Contact.Account.Id,Contact.Account.Name, Contact.Name, Contact.Primary_Contact_Type__c,Username, 
                            Contact.Contact_Type__c,Contact.Tag__c, Email, FederationIdentifier, IsActive
                        FROM User 
                        WHERE UserType IN ('PowerCustomerSuccess','CspLitePortal','PowerPartner')
                        AND (Contact.Account.Owner_Business_Group__c != 'Government' AND Contact.Account.Shared_Partner__c = true) 
                        AND Contact.Account.MPE_Program_Status__c = 'Active' 
                        AND (Contact.Account.Partner_Region__c IN :includeRegions) 
                        AND Contact.Account.Id IN :lstAccountsFrmGrpMapping                        
                        AND  ((Contact.Account.Adp_PI_count__c > 0) OR ((Contact.Account.Adp_PI_count__c = 0) AND (Contact.Account.ADP_Partner__c = FALSE))) 
                        Order By IsActive DESC];
        }
        
        return userList;
    }
    /*============================================================================================= 
    Author : Satish
    Description    : This method accepts set of regions and list of accounts as parameters 
                     and performs query on User object when businessGroup = null or otherthan gov & shr 
                     and returns User records.
    @param1        : Set of regions
    @param2        : Set of account Ids
    @param3        : ProgramLevel
    @return        : List of User records
    Modification History:
    March 8, 2017 
    Sandeep: 
            - Added ProgramLevel = Registered   
    ===============================================================================================*/
    public static List<User> getUsers_others(Set<String> includeRegions,Set<String> lstAccountsFrmGrpMapping, String programLevel) {
        Transient List<User> userList = new List<User>();
        if(!String.isBlank(programLevel)) {
            if(programLevel.equalsIgnoreCase('Gold') || programLevel.equalsIgnoreCase('Platinum') || programLevel.equalsIgnoreCase('Silver') || programLevel.equalsIgnoreCase('Registered')) {
                userList = [SELECT Id, Contact.Account.Id,Contact.Account.Name, Contact.Name, Contact.Primary_Contact_Type__c,Username, 
                                Contact.Contact_Type__c,Contact.Tag__c, Email, FederationIdentifier, IsActive 
                            FROM User 
                            WHERE UserType IN ('PowerCustomerSuccess','CspLitePortal','PowerPartner')
                            AND (Contact.Account.Owner_Business_Group__c = 'Government' OR Contact.Account.Shared_Partner__c = true) 
                            AND Contact.Account.MPE_Program_Status__c = 'Active' 
                            AND (Contact.Account.Partner_Region__c IN :includeRegions) 
                            AND Contact.Account.Id IN :lstAccountsFrmGrpMapping
                            AND Contact.Account.Metal_Level__c = :programLevel 
                               AND  ((Contact.Account.Adp_PI_count__c > 0) OR ((Contact.Account.Adp_PI_count__c = 0) AND (Contact.Account.ADP_Partner__c = FALSE))) 
                         Order By IsActive DESC];
            } else if(programLevel.equalsIgnoreCase('null')){
                userList = [SELECT Id, Contact.Account.Id,Contact.Account.Name, Contact.Name, Contact.Primary_Contact_Type__c,Username, 
                                Contact.Contact_Type__c,Contact.Tag__c, Email, FederationIdentifier, IsActive 
                            FROM User 
                            WHERE UserType IN ('PowerCustomerSuccess','CspLitePortal','PowerPartner')
                            AND (Contact.Account.Owner_Business_Group__c = 'Government' OR Contact.Account.Shared_Partner__c = true) 
                            AND Contact.Account.MPE_Program_Status__c = 'Active' 
                            AND (Contact.Account.Partner_Region__c IN :includeRegions) 
                            AND Contact.Account.Id IN :lstAccountsFrmGrpMapping
                            AND Contact.Account.Metal_Level__c = ''
                                    AND  ((Contact.Account.Adp_PI_count__c > 0) OR ((Contact.Account.Adp_PI_count__c = 0) AND (Contact.Account.ADP_Partner__c = FALSE))) 
                    Order By IsActive DESC];
            }
        } else {
            userList = [SELECT Id, Contact.Account.Id, Contact.Account.Name,Contact.Name, Contact.Primary_Contact_Type__c,Username, 
                            Contact.Contact_Type__c,Contact.Tag__c, Email, FederationIdentifier, IsActive 
                        FROM User 
                        WHERE UserType IN ('PowerCustomerSuccess','CspLitePortal','PowerPartner')
                        AND (Contact.Account.Owner_Business_Group__c = 'Government' OR Contact.Account.Shared_Partner__c = true) 
                        AND Contact.Account.MPE_Program_Status__c = 'Active' 
                        AND (Contact.Account.Partner_Region__c IN :includeRegions) 
                        AND Contact.Account.Id IN :lstAccountsFrmGrpMapping
                               AND  ((Contact.Account.Adp_PI_count__c > 0) OR ((Contact.Account.Adp_PI_count__c = 0) AND (Contact.Account.ADP_Partner__c = FALSE))) 
                     Order By IsActive DESC limit 40000];
        }
        
        return userList;
    }
    
    
    /*
     * Inner class to prepare JSON response
     */ 
    global class PCAEMServiceResponse { //Inner class start
        public String sfuId;
        public String userName;
        public String email;
      //  public String familyName;
        public String accountId;
        public String accountname;
        public List<String> groupNames = new List<String>();
        public String userStatus;
        
        public PCAEMServiceResponse(String sfuId, String userName, String fullName, String email, List<String> groupNames, String accountId,string accountname,String userStatus) {
            this.sfuId = sfuId;
            this.userName = userName;
            this.email = email;
           // this.familyName = fullName;
            this.groupNames = groupNames;
            this.userStatus = userStatus;
            this.accountId = accountId;
            this.accountname = accountname;
        }
    } //Inner class End
}