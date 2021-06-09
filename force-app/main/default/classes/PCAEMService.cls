@RestResource(urlMapping='/GetPCInfo/*')
global class PCAEMService {
    global class MyClass {
        public String sfuId;
        public String userName;
        public String email;
        public String familyName;
        //public String givenName;    --delete 
        public String accountId;        
        public List<String> groupNames = new List<String>();
        //public List<String> empoweringTools = new List<String>(); --delete
        public String userStatus;
        

        public MyClass(String sfuId, String userName, String fullName, String email, List<String> groupNames, String accountId, String userStatus) {
            this.sfuId = sfuId;
            this.userName = userName;
            this.email = email;
            this.familyName = fullName;
            this.groupNames = groupNames;
            this.userStatus = userStatus;
            this.accountId = accountId;
        }
    }
    
    
     public static Set<String> convertMultiSelectToSet(String s){
        try{
            Set<String> theSet = new Set<String>();
            List<String> theList = (s == null)?new List<String>():s.split(';');
            if(!theList.isEmpty()){
                theSet.addAll(theList);
            }
            return theSet;
        }catch(Exception e){
            return new Set<String>();
        }
    }
    
    @HttpGet
    global static List<MyClass> serviceTst() { 

        //List<User> usrTempObj = [Select Id from User Where User_License__c = 'Gold Partner' and Contact.Account.Owner_Business_Group__c = 'Government' and Contact.Account.MPE_Program_Status__c='Active' and (Contact.Account.Partner_Region__c ='NAMR' or Contact.Account.Partner_Region__c ='EMEA') Order By IsActive DESC];                
        //List<User> usrObj = [Select Id, Contact.Account.Id, Contact.Name, Contact.Primary_Contact_Type__c, Contact.Contact_Type__c, Contact.Tag__c, Username, Email, Contact.LDAP_Login__c, FederationIdentifier, UserType, User_License__c, IsActive, Partner_User__c from User Where User_License__c = 'Gold Partner' and Contact.Account.Owner_Business_Group__c = 'Government' and Contact.Account.MPE_Program_Status__c='Active' and (Contact.Account.Partner_Region__c ='NAMR' or Contact.Account.Partner_Region__c ='EMEA') Order By IsActive DESC];        

        //List<User> usrTempObj;
        //List<User> usrObj = [Select Id, Contact.Account.Id, Contact.Name, Username, Email, UserType, User_License__c, IsActive, Partner_User__c from User Where User_License__c = 'Gold Partner' and Contact.Account.Owner_Business_Group__c = 'Government' and Contact.Account.MPE_Program_Status__c='Active' Order By IsActive DESC LIMIT 300];
        //List<User> usrTempObj = [Select Id from User Where User_License__c = 'Gold Partner' and Contact.Account.Owner_Business_Group__c = 'Government' and Contact.Account.MPE_Program_Status__c='Active' Order By IsActive DESC LIMIT 300];        
        
                
          /*Get QueryParameters - lastMod-it takes values true or false, getReg - it takes semicolon separated region values. for example getReg=NAMR;EMEA*/          
        String lastModified = RestContext.request.params.get('lastMod');
        String getRegions = RestContext.request.params.get('getReg');
        String busGrp = RestContext.request.params.get('bGrp');
        List<User> usrObj;                
                
          
        transient List<PC_Empower_Application__c> empApps = [Select Id, PC_Groups__c, ET_Primary_Contact_Type__c, ET_Secondary_Contact_Type__c, ET_Tag__c, Application_Names__c from PC_Empower_Application__c];
        
        transient MyClass objtest;
        transient List<MyClass> obj = new List<MyClass>();
        
        transient Map<String, List<String>> acctGroups = new Map<String, List<String>>();
        transient Map<String, String> acctUsers = new Map<String, String>();
        //Map<String, List<String>> userGroups = new Map<String, List<String>>(); //not in use
        transient Set<Id> userIds = new Set<Id>();
        
        transient Map<Id, List<String>> usrGrpIds = new Map<Id, List<String>>();
        transient Map<Id, String> grpIdGrpNames = new Map<Id, String>();
        //Set<Id> grpIds = new Set<Id>(); // not in use
        
        transient Map<String, PC_WS_Public_Groups__c> allgroups = PC_WS_Public_Groups__c.getAll();
                
        transient Set<String> groupNms = new Set<String>();
        transient Set<Id> modifiedUserIds = new Set<Id>();
        transient Set<String> includeRegions = new Set<String>();
        
        Boolean flag = false;
        
        for(PC_WS_Public_Groups__c grp : allgroups.values()){        
            groupNms.add(grp.Name);
        }
        
        allgroups.clear();

      /* NOTE: 1) This if loop is to determine whether to use Region values from the getRegions Query Parameter or the PC_WS_Include_Regions__c Custom Setting 
               2) "includeRegions" Set variable is used in the queries to retrieve user records only for specific partner region(s)
      STEP-1: Check if the "getRegions" Query Paramter is null, if True Goto STEP-2 else Goto STEP-3
      STEP-2: Get Region Values from the Custom Setting PC_WS_Include_Regions and them to includeRegions Set variable
      STEP-3: Convert semicolon separated values into a Set and add them to includeRegions Set variable
       */
            if(getRegions == null) {
                    
                    Map<String, PC_WS_Include_Regions__c> accRegions = PC_WS_Include_Regions__c.getall();
                    
                        for(PC_WS_Include_Regions__c reg : accRegions.values()){        
                                includeRegions.add(reg.Name);
                            }                   
                  accRegions.clear();
            } else {
                    includeRegions.addAll(convertMultiSelectToSet(getRegions));
            }
        
      /*NOTE: 1) lastModified is a query parameter and accepts boolean values.
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
       if(lastModified != null) {
       
            if(!lastModified.equalsIgnoreCase('')){
            
                    if (lastModified.equalsIgnoreCase('true')){
                    
                    Date yestDate = date.today() - 1;                                    
                      Integer empRecordsModified = [Select count() from PC_Empower_Application__c Where LastModifiedDate >= :yestDate];
                      
                     if( empRecordsModified == 0 ){                       
        
                      for(Group modgroups : [Select Id From Group WHERE Name in :groupNms]){
                              for(GroupMember gm : [Select UserOrGroupId FROM GroupMember Where GroupId = :modgroups.Id and SystemModstamp >= :yestDate]){
                                  modifiedUserIds.add(gm.UserOrGroupId);
                              }
                          }
                     if(busGrp != null) {
                              if(busGrp.equalsIgnoreCase('gov')) {
                               usrObj = [Select Id, Contact.Account.Id, Contact.Name, Contact.Primary_Contact_Type__c, Contact.Contact_Type__c, Contact.Tag__c, Username, Email, Contact.LDAP_Login__c, FederationIdentifier, UserType, User_License__c, IsActive, Partner_User__c from User Where User_License__c = 'Gold Partner' and Contact.Account.Owner_Business_Group__c = 'Government' and Contact.Account.MPE_Program_Status__c='Active' and (Id IN :modifiedUserIds or Contact.LastModifiedDate >= :yestDate) and (Contact.Account.Partner_Region__c  IN :includeRegions) Order By IsActive DESC];                        
                              } else 
                              if(busGrp.equalsIgnoreCase('shr')){
                              usrObj = [Select Id, Contact.Account.Id, Contact.Name, Contact.Primary_Contact_Type__c, Contact.Contact_Type__c, Contact.Tag__c, Username, Email, Contact.LDAP_Login__c, FederationIdentifier, UserType, User_License__c, IsActive, Partner_User__c from User Where User_License__c = 'Gold Partner' and (Contact.Account.Owner_Business_Group__c != 'Government' and Contact.Account.Shared_Partner__c=true) and Contact.Account.MPE_Program_Status__c='Active' and (Id IN :modifiedUserIds or Contact.LastModifiedDate >= :yestDate) and (Contact.Account.Partner_Region__c  IN :includeRegions) Order By IsActive DESC];                                                          
                              } else {
                              usrObj = [Select Id, Contact.Account.Id, Contact.Name, Contact.Primary_Contact_Type__c, Contact.Contact_Type__c, Contact.Tag__c, Username, Email, Contact.LDAP_Login__c, FederationIdentifier, UserType, User_License__c, IsActive, Partner_User__c from User Where User_License__c = 'Gold Partner' and (Contact.Account.Owner_Business_Group__c = 'Government' or Contact.Account.Shared_Partner__c=true) and Contact.Account.MPE_Program_Status__c='Active' and (Id IN :modifiedUserIds or Contact.LastModifiedDate >= :yestDate) and (Contact.Account.Partner_Region__c  IN :includeRegions) Order By IsActive DESC];                        
                              }
                         
                          } else {                               
                  //usrTempObj = [Select Id from User Where User_License__c = 'Gold Partner' and Contact.Account.Owner_Business_Group__c = 'Government' and Contact.Account.MPE_Program_Status__c='Active' and (Id IN :modifiedUserIds or Contact.LastModifiedDate >= :yestDate) and (Contact.Account.Partner_Region__c IN :includeRegions) Order By IsActive DESC];                
                  usrObj = [Select Id, Contact.Account.Id, Contact.Name, Contact.Primary_Contact_Type__c, Contact.Contact_Type__c, Contact.Tag__c, Username, Email, Contact.LDAP_Login__c, FederationIdentifier, UserType, User_License__c, IsActive, Partner_User__c from User Where User_License__c = 'Gold Partner' and (Contact.Account.Owner_Business_Group__c = 'Government' or Contact.Account.Shared_Partner__c=true) and Contact.Account.MPE_Program_Status__c='Active' and (Id IN :modifiedUserIds or Contact.LastModifiedDate >= :yestDate) and (Contact.Account.Partner_Region__c  IN :includeRegions) Order By IsActive DESC];                        
                          }
                     } else {
                         flag = true;
                     }  
                     
                      
                    } else {          
                         flag = true;
                        }
               } else {          
                         flag = true;
                       }
        
            } else {            
                flag = true;
            }
                    
        modifiedUserIds.clear();
        if(flag) {
            if(busGrp != null) {
                              if(busGrp.equalsIgnoreCase('gov')){
                               usrObj = [Select Id, Contact.Account.Id, Contact.Name, Contact.Primary_Contact_Type__c, Contact.Contact_Type__c, Contact.Tag__c, Username, Email, Contact.LDAP_Login__c, FederationIdentifier, UserType, User_License__c, IsActive, Partner_User__c from User Where User_License__c = 'Gold Partner' and Contact.Account.Owner_Business_Group__c = 'Government' and Contact.Account.MPE_Program_Status__c='Active' and (Contact.Account.Partner_Region__c IN :includeRegions) Order By IsActive DESC];         
                              } else if(busGrp.equalsIgnoreCase('shr')){
                               usrObj = [Select Id, Contact.Account.Id, Contact.Name, Contact.Primary_Contact_Type__c, Contact.Contact_Type__c, Contact.Tag__c, Username, Email, Contact.LDAP_Login__c, FederationIdentifier, UserType, User_License__c, IsActive, Partner_User__c from User Where User_License__c = 'Gold Partner' and (Contact.Account.Owner_Business_Group__c != 'Government' and Contact.Account.Shared_Partner__c=true) and Contact.Account.MPE_Program_Status__c='Active' and (Contact.Account.Partner_Region__c IN :includeRegions) Order By IsActive DESC];                                                                   
                              } else {
                              usrObj = [Select Id, Contact.Account.Id, Contact.Name, Contact.Primary_Contact_Type__c, Contact.Contact_Type__c, Contact.Tag__c, Username, Email, Contact.LDAP_Login__c, FederationIdentifier, UserType, User_License__c, IsActive, Partner_User__c from User Where User_License__c = 'Gold Partner' and (Contact.Account.Owner_Business_Group__c = 'Government' or Contact.Account.Shared_Partner__c=true) and Contact.Account.MPE_Program_Status__c='Active' and (Contact.Account.Partner_Region__c IN :includeRegions) Order By IsActive DESC];                                 
                              }
                         
                          } else {                 
          //usrTempObj = [Select Id from User Where User_License__c = 'Gold Partner' and Contact.Account.Owner_Business_Group__c = 'Government' and Contact.Account.MPE_Program_Status__c='Active' and (Contact.Account.Partner_Region__c IN :includeRegions) Order By IsActive DESC];                
          usrObj = [Select Id, Contact.Account.Id, Contact.Name, Contact.Primary_Contact_Type__c, Contact.Contact_Type__c, Contact.Tag__c, Username, Email, Contact.LDAP_Login__c, FederationIdentifier, UserType, User_License__c, IsActive, Partner_User__c from User Where User_License__c = 'Gold Partner' and (Contact.Account.Owner_Business_Group__c = 'Government' or Contact.Account.Shared_Partner__c=true) and Contact.Account.MPE_Program_Status__c='Active' and (Contact.Account.Partner_Region__c IN :includeRegions) Order By IsActive DESC];         
                          }
                 }
        includeRegions.clear();
        transient List<Group> gpId = [Select Id, Name From Group WHERE Name in :groupNms];                
        groupNms.clear();                           
        for(Group g : gpId){                 
                   grpIdGrpNames.put(g.Id, g.Name);              
                    }             
        for( User usrOb : usrObj) {       
                       
                   if(!(acctUsers.containsKey(usrOb.Contact.Account.Id))){                                                                               
                        
                        acctUsers.put(usrOb.Contact.Account.Id, usrOb.Id);                    
                        userIds.add(usrOb.Id);               
                    }                               

            }
//System.debug('Users :'+userIds.size());
           
        for(GroupMember gm : [Select UserOrGroupId, GroupId FROM GroupMember Where UserOrGroupId = :userIds AND GroupId IN :gpId]){
                        if(usrGrpIds != null) {
                            if(usrGrpIds.containsKey(gm.UserOrGroupId)){
                            transient List<String> tempGrpNames = usrGrpIds.get(gm.UserOrGroupId);                            
                            tempGrpNames.add(grpIdGrpNames.get(gm.GroupId));
                            usrGrpIds.put(gm.UserOrGroupId, tempGrpNames);
                           } else {
                           transient List<String> tempGrpNames = new List<String>();
                           tempGrpNames.add(grpIdGrpNames.get(gm.GroupId));                            
                            usrGrpIds.put(gm.UserOrGroupId, tempGrpNames);                           
                           }
                       } 
                     }
        gpId.clear();        
        userIds.clear();
        grpIdGrpNames.clear();        
         for(String acc : acctUsers.keySet()){
             if(usrGrpIds.containsKey(acctusers.get(acc))){
                 //System.debug(acc);
                 acctGroups.put(acc, usrGrpIds.get(acctusers.get(acc)));
             }
         }
       acctusers.clear();
       usrGrpIds.clear(); 
        for( User usrOb : usrObj) {
                
            String usrActive = ''+usrOb.IsActive;            
                
                if(acctGroups != null) {

                    if(acctGroups.containsKey(usrOb.Contact.Account.Id)){ 
                    //Set<String> uniqueEmpApps = new Set<String>();
                    transient Set<String> uniqueEmpApps = new Set<String>(acctGroups.get(usrOb.Contact.Account.Id));
                    //List<String> tempUserGroupNames = new List<String>();
                        //tempUserGroupNames = acctGroups.get(usrOb.Contact.Account.Id);

                            for(PC_Empower_Application__c app : empApps){                            
                            Boolean shouldContinue = true;
                            //PC_Groups__c, ET_Primary_Contact_Type__c, ET_Secondary_Contact_Type__c, ET_Tag__c, Application_Names__c, Contact.Primary_Contact_Type__c, Contact.Contact_Type__c, Contact.Tag__c
                            
                            if(shouldContinue) {
                                if(app.PC_Groups__c != null) {
                                    shouldContinue=false;
                                    if(uniqueEmpApps.contains(app.PC_Groups__c)){
                                     shouldContinue=true;
                                    }
                                }
                            }
                            
                            if(shouldContinue) {
                                if(app.ET_Primary_Contact_Type__c != null) {
                                   shouldContinue=false;
                                   if(usrOb.Contact.Primary_Contact_Type__c == app.ET_Primary_Contact_Type__c){
                                   shouldContinue=true;
                                   }  
                                }
                            }
                            
                            if(shouldContinue) {
                                if(app.ET_Secondary_Contact_Type__c != null) {
                                   shouldContinue=false;
                                   transient Set<String> secSet = new Set<String>();
                                   secSet.addAll(convertMultiSelectToSet(app.ET_Secondary_Contact_Type__c));
                                   Integer match = 0; 
                                   if(usrOb.Contact.Contact_Type__c != null){
                                       for(String sec:secSet) {                                 
                                           if(usrOb.Contact.Contact_Type__c.contains(sec)){
                                               match++;
                                           }
                                       }  
                                   }
                                   if(match >= 1) {
                                       shouldContinue=true;
                                   }
                                }
                            }
                            
                            if(shouldContinue) {
                                if(app.ET_Tag__c != null) {
                                   shouldContinue=false;
                                   transient Set<String> tagSet = new Set<String>();
                                           tagSet.addAll(convertMultiSelectToSet(app.ET_Tag__c));
                                           Integer match = 0;   
                                       if (usrOb.Contact.Tag__c != null) {                                                                                                                              
                                               for(String sec:tagSet) {                                               
                                                   if(usrOb.Contact.Tag__c.contains(sec)){
                                                   match++;
                                                   }  
                                                 } 
                                             }                                          
                                           if(match >= 1) {
                                               shouldContinue=true;
                                           }                                                                                    
                                       } 
                                }                            
                            
                            
                            if(shouldContinue) {
                                //add code to add multiple applications to the collection convertMultiSelectToSet(app.Application_Names__c);
                                uniqueEmpApps.addAll(convertMultiSelectToSet(app.Application_Names__c));
                            }
                            
                         }
                         transient List<String> userGroupNames = new List<String>(uniqueEmpApps);  
                         
                                                  
                        //objtest = new MyClass(usrOb.FederationIdentifier, usrOb.Contact.Name, usrOb.Email, acctGroups.get(usrOb.Contact.Account.Id), usrOb.Contact.Account.Id, usrActive);
                        objtest = new MyClass(usrOb.Id, usrOb.FederationIdentifier, usrOb.Contact.Name, usrOb.Email, userGroupNames, usrOb.Contact.Account.Id, usrActive);
                        obj.add(objtest);                    
                        }
                
                   }
 
        }
        usrobj.clear();
        System.debug('Check Heap Size :'+Limits.getHeapSize());
        return obj;
    }
}