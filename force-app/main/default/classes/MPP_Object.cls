public class MPP_Object {
  private static CustomUser currentUser;
  public static CustomUser getCustomUser()
  {
    if (currentUser == null)
    {
      currentUser = new CustomUser();
    }
    return currentUser;
  }
    
    public class CustomUser{
        public String userId {get;set;}
        public String region {get;set;}
        public String communityName {get;set;}
        public String partnerLevel {get;set;}
        public String metalLevel {get;set;}
        public String techSpecLevel {get;set;}
        public String appSpec {get;set;}
        public String appSpecLevel {get;set;}
        public String marketSpec {get;set;}
        public String techSpec {get;set;}
        public String title {get;set;}
        public String phone {get;set;}
        public String mobilePhone {get;set;}
        public String languageLocaleKey {get;set;}
        public String position {get;set;}
        public String country {get;set;}
        public String profileName {get;set;}
        public String quickLinks {get;set;}
        public String accountId {get;set;}
        public String name {get;set;}
        public String role {get;set;}
        public String purchasingMethod {get;set;}

        public Set<String> communitySet {get;set;}
        public Set<String> partnerSet {get;set;}
        public Set<String> partnerLevelSet {get;set;}
        public Set<String> techSpecSet {get;set;}
        public Set<String> techSpecLevelSet {get;set;}
        public Set<String> appSpecSet {get;set;}
        public Set<String> appSpecLevelSet {get;set;}

        public CustomUser(User u){
            this.setCustomUserFields(u);
        }
    
        public CustomUser(){
//  RC -  Is it necessary to create a new user object?
//            User u = new User();
//            for(User use : [Select Contact.Title, Contact.Phone, Contact.MobilePhone, mh_Blue_Sheet_Read_Write_License__c, WirelessEmail, Utilization_Metric__c, Username, UserType, UserRoleId, UserPreferencesTaskRemindersCheckboxDefault, UserPreferencesReminderSoundOff, UserPreferencesOptOutOfTouch, UserPreferencesHideCSNGetChatterMobileTask, UserPreferencesHideCSNDesktopTask, UserPreferencesEventRemindersCheckboxDefault, UserPreferencesContentNoEmail, UserPreferencesContentEmailAsAndWhen, UserPreferencesApexPagesDeveloperMode, UserPreferencesActivityRemindersPopup, UserPermissionsWirelessUser, UserPermissionsSFContentUser, UserPermissionsOfflineUser, UserPermissionsMobileUser, UserPermissionsMarketingUser, UserPermissionsInteractionUser, UserPermissionsCallCenterAutoLogin, UserPermissionsAvantgoUser, Title, TimeZoneSidKey, Theater__c, Theater_Code__c, Test_Region__c,  SystemModstamp, Subregion__c, Street, State, Start_Date__c, Special_Needs__c, Short_R3__c, Sales_Analytics_Data_Refresh__c, Reporting_Data_Type__c, Region__c, ReceivesInfoEmails, ReceivesAdminInfoEmails, ProfileId, Pre_merger_Origin__c, PostalCode, Position__c, Phone, Partner_Administrator__c, Organization__c, Org__c, OfflineTrialExpirationDate, OfflinePdaTrialExpirationDate, Office__c, Non_Friendly_Flag__c, Name, MobilePhone, Migrated_From_NA_Govt__c, ManagerId, LocaleSidKey, LastPasswordChangeDate, LastName, LastModifiedDate, LastModifiedById, LastLoginDate, LanguageLocaleKey, IsPortalEnabled, IsActive, Id, High_Touch__c, Headline_Group__c, Green_Sheet_Read_Write_License__c, Green_Sheet_Read_Only_License__c, Green_Sheet_Managers_License__c, Gold_Sheet_Read_Write_License__c, Gold_Sheet_Read_Only_License__c, Gold_Sheet_Managers_License__c, ForecastEnabled, FirstName, FederationIdentifier, Fax, Extension, Employee_SAP_Hierarchy_Number__c, Employee_R3_Number__c, EmployeeNumber, EmailEncodingKey, Email, Division, Direct_Bill_to_User__c, Department, DelegatedApproverId, Default_Pricebook_Id__c, DefaultCurrencyIsoCode, CurrencyIsoCode, CreatedDate, CreatedById, Country, Core_ID__c, ContactId, CompanyName, CommunityNickname, City, CallCenterId, Business_Division__c, Blue_Sheet_Read_Only_License__c, Blue_Sheet_Managers_License__c, Area__c, Area_Controller__c, Apttus_Approval__Next_Level_Approver__c, Apttus_Approval__Approval_Level__c, Alias, Additional_Roles__c, AccountId, APTPS_Set_Backup_Approver__c, APTPS_Region__c, APTPS_Permissible_Assignee_Label__c, APTPS_Authorized_Dollar_Value__c, APTPS_Agreement_RecordType__c, Quick_Links__c,Profile.Name From User WHERE Id = :UserInfo.getUserId()]){
//                u = use;
//            }

      User u = [Select Contact.Title, 
               Contact.Phone, 
               Contact.MobilePhone, 
//               mh_Blue_Sheet_Read_Write_License__c, 
//               WirelessEmail, 
//               Utilization_Metric__c, 
//               Username, 
//               UserType, 
//               UserRoleId, 
//               UserPreferencesTaskRemindersCheckboxDefault, 
//               UserPreferencesReminderSoundOff, 
//               UserPreferencesOptOutOfTouch, 
//               UserPreferencesHideCSNGetChatterMobileTask, 
//               UserPreferencesHideCSNDesktopTask, 
//               UserPreferencesEventRemindersCheckboxDefault, 
//               UserPreferencesContentNoEmail, 
//               UserPreferencesContentEmailAsAndWhen, 
//               UserPreferencesApexPagesDeveloperMode, 
//               UserPreferencesActivityRemindersPopup, 
//               UserPermissionsWirelessUser, 
//               UserPermissionsSFContentUser, 
//               UserPermissionsOfflineUser, 
//               UserPermissionsMobileUser, 
//               UserPermissionsMarketingUser, 
//               UserPermissionsInteractionUser, 
//               UserPermissionsCallCenterAutoLogin, 
//               UserPermissionsAvantgoUser, 
//               Title, 
//               TimeZoneSidKey, 
//               Theater__c, 
//               Theater_Code__c, 
//               Test_Region__c, 
//               SystemModstamp, 
//               Subregion__c, 
//               Street, 
//               State, 
//               Start_Date__c, 
//               Special_Needs__c, 
//               Short_R3__c, 
//               Sales_Analytics_Data_Refresh__c, 
//               Reporting_Data_Type__c, 
//               Region__c, 
//               ReceivesInfoEmails, 
//               ReceivesAdminInfoEmails, 
//               ProfileId, 
//               Pre_merger_Origin__c, 
//               PostalCode, 
               Position__c, 
//               Phone, 
//               Partner_Administrator__c, 
//               Organization__c, 
//               Org__c, 
//               OfflineTrialExpirationDate, 
//               OfflinePdaTrialExpirationDate, 
//               Office__c, 
//               Non_Friendly_Flag__c, 
               Name, 
//               MobilePhone, 
//               Migrated_From_NA_Govt__c, 
//               ManagerId, 
//               LocaleSidKey, 
//               LastPasswordChangeDate, 
//               LastName, 
//               LastModifiedDate, 
//               LastModifiedById, 
//               LastLoginDate, 
               LanguageLocaleKey, 
//               IsPortalEnabled, 
//               IsActive, 
               Id, 
//               High_Touch__c, 
//               Headline_Group__c, 
//               Green_Sheet_Read_Write_License__c, 
//               Green_Sheet_Read_Only_License__c, 
//               Green_Sheet_Managers_License__c, 
//               Gold_Sheet_Read_Write_License__c, 
//               Gold_Sheet_Read_Only_License__c, 
//               Gold_Sheet_Managers_License__c, 
//               GPS_User_Id__c, 
//               ForecastEnabled, 
//               FirstName, 
//               FederationIdentifier, 
//               Fax, 
//               Extension, 
//               Employee_SAP_Hierarchy_Number__c, 
//               Employee_R3_Number__c, 
//               EmployeeNumber, 
//               EmailEncodingKey, 
//               Email, 
//               Division, 
//               Direct_Bill_to_User__c, 
//               Department, 
//               DelegatedApproverId, 
//               Default_Pricebook_Id__c, 
//               DefaultCurrencyIsoCode, 
//               CurrencyIsoCode, 
//               CreatedDate, 
//               CreatedById, 
               Country, 
//               Core_ID__c, 
               ContactId, 
//               CompanyName, 
//               CommunityNickname, 
//               City, 
//               CallCenterId, 
//               Business_Division__c, 
//               Blue_Sheet_Read_Only_License__c, 
//               Blue_Sheet_Managers_License__c, 
//               Area__c, 
//               Area_Controller__c, 
//               Apttus_Approval__Next_Level_Approver__c, 
//               Apttus_Approval__Approval_Level__c, 
//               Alias, 
//               Additional_Roles__c, 
               AccountId, 
//               APTPS_Set_Backup_Approver__c, 
//               APTPS_Region__c, 
//               APTPS_Permissible_Assignee_Label__c, 
//               APTPS_Authorized_Dollar_Value__c, 
//               APTPS_Agreement_RecordType__c, 
               Quick_Links__c,
               Profile.Name From User WHERE Id = :UserInfo.getUserId() LIMIT 1];
//      User u = [Select Contact.Title, Contact.Phone, Contact.MobilePhone,mh_Blue_Sheet_Read_Write_License__c, WirelessEmail, Utilization_Metric__c, Username, UserType, UserRoleId, UserPreferencesTaskRemindersCheckboxDefault, UserPreferencesReminderSoundOff, UserPreferencesOptOutOfTouch, UserPreferencesHideCSNGetChatterMobileTask, UserPreferencesHideCSNDesktopTask, UserPreferencesEventRemindersCheckboxDefault, UserPreferencesContentNoEmail, UserPreferencesContentEmailAsAndWhen, UserPreferencesApexPagesDeveloperMode, UserPreferencesActivityRemindersPopup, UserPermissionsWirelessUser, UserPermissionsSFContentUser, UserPermissionsOfflineUser, UserPermissionsMobileUser, UserPermissionsMarketingUser, UserPermissionsInteractionUser, UserPermissionsCallCenterAutoLogin, UserPermissionsAvantgoUser, Title, TimeZoneSidKey, Theater__c, Theater_Code__c, Test_Region__c,  SystemModstamp, Subregion__c, Street, State, Start_Date__c, Special_Needs__c, Short_R3__c, Sales_Analytics_Data_Refresh__c, Reporting_Data_Type__c, Region__c, ReceivesInfoEmails, ReceivesAdminInfoEmails, ProfileId, Pre_merger_Origin__c, PostalCode, Position__c, Phone, Partner_Administrator__c, Organization__c, Org__c, OfflineTrialExpirationDate, OfflinePdaTrialExpirationDate, Office__c, Non_Friendly_Flag__c, Name, MobilePhone, Migrated_From_NA_Govt__c, ManagerId, LocaleSidKey, LastPasswordChangeDate, LastName, LastModifiedDate, LastModifiedById, LastLoginDate, LanguageLocaleKey, IsPortalEnabled, IsActive, Id, High_Touch__c, Headline_Group__c, Green_Sheet_Read_Write_License__c, Green_Sheet_Read_Only_License__c, Green_Sheet_Managers_License__c, Gold_Sheet_Read_Write_License__c, Gold_Sheet_Read_Only_License__c, Gold_Sheet_Managers_License__c, ForecastEnabled, FirstName, FederationIdentifier, Fax, Extension, Employee_SAP_Hierarchy_Number__c, Employee_R3_Number__c, EmployeeNumber, EmailEncodingKey, Email, Division, Direct_Bill_to_User__c, Department, DelegatedApproverId, Default_Pricebook_Id__c, DefaultCurrencyIsoCode, CurrencyIsoCode, CreatedDate, CreatedById, Country, Core_ID__c, ContactId, CompanyName, CommunityNickname, City, CallCenterId, Business_Division__c, Blue_Sheet_Read_Only_License__c, Blue_Sheet_Managers_License__c, Area__c, Area_Controller__c, Apttus_Approval__Next_Level_Approver__c, Apttus_Approval__Approval_Level__c, Alias, Additional_Roles__c, AccountId, APTPS_Set_Backup_Approver__c, APTPS_Region__c, APTPS_Permissible_Assignee_Label__c, APTPS_Authorized_Dollar_Value__c, APTPS_Agreement_RecordType__c, Quick_Links__c From User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            this.setCustomUserFields(u);
        }
        
        public void setCustomUserFields(User u){

//  RC - Testing breaking out the query from user
/*      this.title = '';
      this.phone = '';
      this.mobilePhone = '';

      if (u.ContactId != null)
      {
        Contact con = [SELECT Title, Phone, MobilePhone FROM Contact WHERE Id = :u.ContactId LIMIT 1];
        this.title = con.Title;
        this.phone = con.Phone;
        this.mobilePhone = con.mobilePhone;
      }
      if (u.ProfileId != null)
      {
        Profile prof = [SELECT Name FROM Profile WHERE Id = :u.ProfileId LIMIT 1];
        this.profileName = prof.Name;
      }
*/
//  RC - end of test

            this.region = '';
            this.metalLevel = '';
            this.communityName = '';
            this.partnerLevel = '';
            this.techSpecLevel = '';
            this.appSpecLevel = '';
            this.marketSpec = '';
            this.techSpec = '';
            this.appSpec = '';
            this.role = '';
            this.purchasingMethod = '';

            this.userId = u.Id;
            this.title = u.Contact.Title;
            this.phone = u.Contact.Phone;
            this.mobilePhone = u.Contact.MobilePhone;
            this.languageLocaleKey = u.LanguageLocaleKey;
            this.position = u.Position__c;
            this.country = u.Country;
            this.profileName = u.Profile.Name;
            this.accountId = u.AccountId;
            this.quickLinks = u.Quick_Links__c;
            this.name = u.Name;
            
//            for(Account a : [Select Partner_Region__c, Metal_Level__c From Account WHERE Id = :u.AccountId]){
//                this.region = checkNull(a.Partner_Region__c);
//                this.metalLevel = checkNull(a.Metal_Level__c);
//            }

      if (u.AccountId != null)
      {  
        Account a = [Select Partner_Region__c, Metal_Level__c From Account WHERE Id = :u.AccountId];
                this.region = checkNull(a.Partner_Region__c);
                this.metalLevel = checkNull(a.Metal_Level__c);
            }
      
            this.communitySet = new Set<String>();
            this.partnerSet = new Set<String>();
            this.partnerLevelSet = new Set<String>();
            this.techSpecSet = new Set<String>();
            this.techSpecLevelSet = new Set<String>();
            this.appSpecSet = new Set<String>();
            this.appSpecLevelSet = new Set<String>();
//  RC - only query for what you need
//            for(Technology_Specialization__c t : [Select Type__c, Technology_Specialization__c, Technology_Specialization_Status__c, Technology_Specialization_Level__c, Tech_Specialization_Compliant_Status__c, SystemModstamp, Sort_Order__c, Program__c, Partner_Zone__c, Partner_Program__c, Partner_Category__c, Name, Market_Term__c, LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, Id, CurrencyIsoCode, CreatedDate, CreatedById, ConnectionSentId, ConnectionReceivedId, Compliance_Review_Date__c, Community_Type__c, Authorized__c, Account__c, Account_Unique_Id__c, AccountPartnerRegion__c, Acc_Prgm_Track_Cmnty__c From Technology_Specialization__c WHERE Account__c = :u.AccountId]){
            for(Technology_Specialization__c t : [Select Type__c, 
                  Technology_Specialization__c, 
//                  Technology_Specialization_Status__c, 
                  Technology_Specialization_Level__c, 
/*
                  Tech_Specialization_Compliant_Status__c, 
                  SystemModstamp, 
                  Sort_Order__c, 
                  Program__c, 
                  Partner_Zone__c, 
                  Partner_Program__c, 
                  Partner_Category__c, 
                  Name, 
                  Market_Term__c, 
                  LastModifiedDate, 
                  LastModifiedById, 
                  LastActivityDate, 
                  IsDeleted, 
                  Id, 
                  CurrencyIsoCode, 
                  CreatedDate, 
                  CreatedById, 
                  ConnectionSentId,
                  ConnectionReceivedId, 
                  Compliance_Review_Date__c, 
*/
                  Community_Type__c
/*                  Authorized__c, 
                  Account__c, 
                  Account_Unique_Id__c, 
                  AccountPartnerRegion__c, 
                  Acc_Prgm_Track_Cmnty__c 
*/
                  From Technology_Specialization__c WHERE Account__c = :u.AccountId]){

                if(!communitySet.contains(t.Community_Type__c)){
                    this.communityName += t.Community_Type__c + ', ';
                    communitySet.add(t.Community_Type__c);
                }
                //if(t.Type__c == 'Technology'){
                    if(!techSpecLevelSet.contains(t.Technology_Specialization_Level__c)){
                        this.techSpecLevel += t.Technology_Specialization_Level__c + ';';
                        techSpecLevelSet.add(t.Technology_Specialization_Level__c);
                    }
                    if(!techSpecSet.contains(t.Technology_Specialization__c)){
                        this.techSpec += t.Technology_Specialization__c + ';';
                        techSpecSet.add(t.Technology_Specialization__c);
                    }
                //}
                if(t.Type__c == 'Application'){
                    if(!appSpecLevelSet.contains(t.Technology_Specialization_Level__c)){
                        this.appSpecLevel += t.Technology_Specialization_Level__c + ';';
                        appSpecLevelSet.add(t.Technology_Specialization_Level__c);
                    }
                    if(!appSpecSet.contains(t.Technology_Specialization__c)){
                        this.appSpec += t.Technology_Specialization__c + ';';
                        appSpecSet.add(t.Technology_Specialization__c);
                    }
                }
            }

            for(Partner_Type__c p : [Select 
/*
                sort_order__c, 
                sort_order_1__c, 
                US_Federal_Specialization__c, 
                Tech_Levels__c, 
                SystemModstamp, 
                Support_Services__c, 
                Status__c, 
                RHO__c, 
*/
                Purchasing_Method__c, 
/*
                Program__c, 
                Partner_Track__c, 
*/
                Partner_Level__c 
/*                PartnerTypeKey__c, 
                PROGRAM_EXT_REF_ID__c, 
                Name, 
                LastModifiedDate, 
                LastModifiedById, 
                IsDeleted, 
                Id, 
                Federal_Specialization_Sort__c, 
                CurrencyIsoCode, 
                CreatedDate, 
                CreatedById, 
                ConnectionSentId, 
                ConnectionReceivedId, 
                Compliance_Status__c, 
                Compliance_Review_Date__c, 
                Compliance_Order__c, 
                CommunityList__c, 
                Authorized_Service_Center__c, 
                Advanced_Services__c, 
                Account__c,
                Account_Unique_ID__c, 
                Account_PartnerTrack__c 
*/
                From Partner_Type__c p WHERE Account__c = :u.AccountId]){
                if(!partnerLevelSet.contains(p.Partner_Level__c)){
                    this.partnerLevel += p.Partner_Level__c + ';';
                    partnerLevelSet.add(p.Partner_Level__c);
                }
                if(!partnerSet.contains(p.Purchasing_Method__c)){
                    this.purchasingMethod += p.Purchasing_Method__c + ', ';
                    partnerSet.add(p.Purchasing_Method__c);
                }
            }
            
            for(Market_Specializations__c m : [Select Market_Specialization__c FROM Market_Specializations__c WHERE Account__c = :u.AccountId]){
                this.marketSpec += m.Market_Specialization__c + ';';        
            }
            
            for(Contact c : [Select Id, Primary_Contact_Type__c, Contact_Type__c FROM Contact WHERE Id = :u.ContactId]){
                this.role += c.Primary_Contact_Type__c + ';';
                this.role += c.Contact_Type__c + ';';
            }

            this.communityName = this.communityName.replace('null, ', '');
            this.communityName = this.communityName.removeEnd(', ');
            this.partnerLevel = this.partnerLevel.replace('null, ', '');
            this.partnerLevel = this.partnerLevel.removeEnd(', ');
            this.purchasingMethod = this.purchasingMethod.replace('null, ', '');
            this.purchasingMethod = this.purchasingMethod.removeEnd(', ');
            this.techSpecLevel = this.techSpecLevel.replace('null;', '');
            this.appSpecLevel = this.appSpecLevel.replace('null;', '');
            this.marketSpec = this.marketSpec.replace('null;', '');
            this.techSpec = this.techSpec.replace('null;', '');
            this.appSpec = this.appSpec.replace('null;', '');
            this.role = this.role.replace('null;', '');
            this.purchasingMethod = this.purchasingMethod.replace('null;', '');
            
        }
        
    private Map<String, String> fieldMap;
        public String getField(String fieldName){
      if (this.fieldMap == null)
      {
              fieldMap = new Map<String, String>();
              fieldMap.put('userId', this.userId);
              fieldMap.put('region', this.region);
              fieldMap.put('communityName', this.communityName);
              fieldMap.put('partnerLevel', this.partnerLevel);
              fieldMap.put('metalLevel', this.metalLevel);
              fieldMap.put('techSpec', this.techSpec);
              fieldMap.put('techSpecLevel', this.techSpecLevel);
              fieldMap.put('appSpec', this.appSpec);
              fieldMap.put('appSpecLevel', this.appSpecLevel);
              fieldMap.put('marketSpec', this.marketSpec);
              fieldMap.put('title', this.title);
              fieldMap.put('phone', this.phone);
              fieldMap.put('mobilePhone', this.mobilePhone);
              fieldMap.put('languageLocaleKey', this.languageLocaleKey);
              fieldMap.put('position', this.position);
              fieldMap.put('country', this.country);
              fieldMap.put('profileName', this.profileName);
              fieldMap.put('quickLinks', this.quickLinks);
              fieldMap.put('accountId', this.accountId);
              fieldMap.put('name', this.name);
              fieldMap.put('role', this.role);
      }
            return(fieldMap.get(fieldName) == null)?'':fieldMap.get(fieldName);
        }

/*   RC - old getField method
        public String getField(String fieldName){
            Map<String, String> fieldMap = new Map<String, String>();
            fieldMap.put('userId', this.userId);
            fieldMap.put('region', this.region);
            fieldMap.put('communityName', this.communityName);
            fieldMap.put('partnerLevel', this.partnerLevel);
            fieldMap.put('metalLevel', this.metalLevel);
            fieldMap.put('techSpec', this.techSpec);
            fieldMap.put('techSpecLevel', this.techSpecLevel);
            fieldMap.put('appSpec', this.appSpec);
            fieldMap.put('appSpecLevel', this.appSpecLevel);
            fieldMap.put('marketSpec', this.marketSpec);
            fieldMap.put('title', this.title);
            fieldMap.put('phone', this.phone);
            fieldMap.put('mobilePhone', this.mobilePhone);
            fieldMap.put('languageLocaleKey', this.languageLocaleKey);
            fieldMap.put('position', this.position);
            fieldMap.put('country', this.country);
            fieldMap.put('profileName', this.profileName);
            fieldMap.put('quickLinks', this.quickLinks);
            fieldMap.put('accountId', this.accountId);
            fieldMap.put('name', this.name);
            fieldMap.put('role', this.role);
            
            return(fieldMap.get(fieldName) == null)?'':fieldMap.get(fieldName);
        }
*/  
  
        public String checkNull(String s){
            return (s == null)?'':s;
        }
        
    }

//  RC - 7/17/2014 - Singleton for checking if access level field is enabled
  private Static Boolean bAccessLevelEnabled;
    /*This is a temporary solution to determine if access levels are enabled.
     * This needs to change when this becomes available through service api
     * */
    public static Boolean isAccessLevelEnabled(){
        if (bAccessLevelEnabled == null)
        {
      bAccessLevelEnabled = false;
          Schema.SObjectType sot1 = Schema.Sobjecttype.User.getsObjectType();
          Map<String, SObjectField> userFields = sot1.getDescribe().fields.getMap();
          if(userFields.containsKey('Access_Level__c'))
              bAccessLevelEnabled = true;
        }
        return bAccessLevelEnabled;
    }
    private static Decimal dAccessLevel;
    public static Boolean doesUserHaveAccess(String pm, Decimal contentLevel)
    {
    //  If this is a preview page, allow access, only check production pages
        if (pm != null && pm != 'production')
        {
           return true;
        }

    //  Get the user's access level, only once
    if (isAccessLevelEnabled() && dAccessLevel == null)
    {
        String query ='Select Access_Level__c From User Where Id=\'' + UserInfo.getUserId() + '\'';
          SObject loginUser = Database.query(query);
      String userType = null;
      String accessLevel ='Guest';
        if (loginUser != null)
          {
              if (loginUser.get('Access_Level__c') != null)
              {
                accessLevel=(String)loginUser.get('Access_Level__c');
              }
            query='Select cms__Name__c,cms__Value__c From cms__Access_Level__c Where  cms__Name__c=\''+accessLevel+'\'';
              List<sObject> contLevel = Database.query(query); 

            if(contLevel.size()>0 )
            {
                dAccessLevel = (Decimal)contLevel[0].get('cms__Value__c');
            }
          }
    }
    
    //  Now check if the access level was set, if so compare against it
    if (isAccessLevelEnabled() && dAccessLevel != null)
    {
      if (contentLevel >= dAccessLevel)
      {
        return true;
      }
      else
      {
        return false;
      }
    }
    
    //  Access levels are disabled or no access level set for user, so user will have access
    return true;              
    }

//  RC - 6/18/2014 - Singleton for empowering tools
  private static UserEmpoweringTools empoweringTools;
  public static UserEmpoweringTools getUserEmpoweringTools()
  {
    if (empoweringTools == null)
    {
      empoweringTools = new UserEmpoweringTools(UserInfo.getUserId());
    }    
    return empoweringTools;
  }    

    public class UserEmpoweringTools{
        public List<MotAppAccess> empoweringLinks{get;set;}
        public List<MotAppAccess> quickLinks{get;set;}
        private Boolean isProduction = MPP_Class_HLPR_SSO.isProduction();
        
        /**
        *    This is a list of the links.  For each type there are two links specified.
        *    The first link is the production link and the second link is the link for test.
        *  The variables names correspond to the name of the link in the Empowering tools 
        *  Access Edits spreadsheet.
        *  
        *  To edit the name of the link i.e. what shows on the page to the user, simple
        *  search for the name that is currently showing e.g. 'Channel Partner Scorecard'
        *  and simply edit the text to be what the link should be. 
        *   
        *  To add additional empowering tools, please follow these specific steps:
        *  1.  Create a private string for each button that needs to be created for the 
        *    associated empowering tool.
        *  2.  Follow the same format for determining the environment as all other links have:
        *    private String LINK_VARIABLE = isProduction?'http://production-url':'http://test-url';
        *  3.  Scroll down to where the tools are starting to be created.  Search for 'Start to create 
        *    the empowering tool links here' which is where it actually starts.
        *  4.  Determine what the visibiliy of the Empowering Tool needs to be i.e. if a the
        *    tool is region specific for NAMR you would use:
        *    if(a.Partner_Region__c == 'NAMR' || superUser){
      *           singleLinkList.add(new MotAppLink('Name of Button 1', LINK_VARIABLE));
      *           singleLinkList.add(new MotAppLink('Name of Button 2', ANOTHER_LINK_VARIABLE));
      *           hasAccessList.add(new MotAppAccess('Name of Empowering Tool', singleLinkList));
      *           singleLinkList = new List<MotAppLink>();
        *    }
        *    a.  A couple of notes with this.  The superUser variable is used for using the
        *      preview functionality and should contain all tools even if they are region
        *      specific or some other type of visibiliy lock.
        *    b.  If the Empowering Tool should be available for all users, simply remove the
        *      if statement wrapped around the addition of the links.
        *    c.  Currently the visibility checks are determined from a few separate fields on 
        *      User, Account, Contact, Partner_Type__c, and Technology_Specialization__c.
        *      Should the field needed for visibiliy is either not present in the queries for 
        *      these objects or the needed object is not being queried, you will need to query 
        *      said object/field to reference in the visibility check.        
        */
        
        //My Licenses Trilogy
        private String ELC_ACCESS_LINK = isProduction?'https://mylicenses.motorolasolutions.com/':'https://catlicen.motorolasolutions.com';
        private String ELC_ACCESS_PENDING_LINK = isProduction?'https://partnercentral-uat.motorolasolutions.com/resources/sales/MyLicensing_pending.aspx':'https://partnercentral-uat.motorolasolutions.com/resources/sales/MyLicensing_pending.aspx';
        private String ELC_REGISTER_LINK = isProduction?'https://portal.motorolasolutions.com/web/Portal/pre-registration-new/preregistration-steps.html?ispartner=y':'http://ext-dev-preview.mot.com/web/Portal/pre-registration-new/preregistration-steps.html?ispartner=y';
        private String ELC_LEARN_MORE_LINK = isProduction?'':'';
        
        //My Orders Trilogy
        private String ISR_ACCESS_LINK = isProduction?'https://myorders.motorolasolutions.com/':'https://catshop.motorolasolutions.com';
        private String ISR_REGISTER_LINK = isProduction?'https://portal.motorolasolutions.com/web/Portal/pre-registration-new/preregistration-steps.html?ispartner=y':'http://ext-dev-preview.mot.com/web/Portal/pre-registration-new/preregistration-steps.html?ispartner=y';
        private String ISR_UPGRADE_ACCESS_LINK = isProduction?'https://portal.motorolasolutions.com/web/Portal/pre-registration-new/preregistration-steps.html?ispartner=y':'http://ext-dev-preview.mot.com/web/Portal/pre-registration-new/preregistration-steps.html?ispartner=y';
        private String ISR_ACCESS_PENDING_LINK = isProduction?'':'';
        private String ISR_LEARN_MORE_LINK = isProduction?'':'';
        
        //My Receivables Trilogy
        private String IRC_ACCESS_LINK = isProduction?'https://myreceivables.motorolasolutions.com/':'https://catreceiv.motorolasolutions.com/';
        private String IRC_REGISTER_LINK = isProduction?'https://portal.motorolasolutions.com/web/Portal/pre-registration-new/preregistration-steps.html?ispartner=y':'http://ext-dev-preview.mot.com/web/Portal/pre-registration-new/preregistration-steps.html?ispartner=y';
        private String IRC_ACCESS_PENDING_LINK = isProduction?'':'';
        private String IRC_LEARN_MORE_LINK = isProduction?'':'';
        
        //My Contracts Trilogy
        private String ECT_ACCESS_LINK = isProduction?'':'https://catcontr.motorolasolutions.com';
        private String ECT_REGISTER_LINK = isProduction?'':'http://ext-dev-preview.mot.com/web/Portal/pre-registration-new/preregistration-steps.html?ispartner=y';
        private String ECT_ACCESS_PENDING_LINK = isProduction?'':'';
        private String ECT_LEARN_MORE_LINK = isProduction?'':'';
        
        //private String GENERIC_LEARN_MORE = isProduction?'':'';
        
        //private String CHANNEL_PARTNER_SCORECARD_NA = isProduction?'http://www.dealer-rewards.com/login/seamlessaccess.aspx':'http://www.dealer-rewards.com/login/seamlessaccess.aspx';
        
        private String PARTNER_ADMINISTRATION_ACCESS = isProduction?'https://motorolasolutions.my.salesforce.com/home/home.jsp':'https://motorolasolutions.my.salesforce.com/home/home.jsp';
        private String PARTNER_ADMINISTRATION_LEARN_MORE = isProduction?'https://motorolasolutions.secure.force.com/partnerportal/Resources-Administrator-Dashboard':'https://motorolasolutions.secure.force.com/partnerportal/Resources-Administrator-Dashboard';
      //private String PARTNER_ADMINISTRATION_REGISTER = isProduction?'https://motorolasolutions.secure.force.com/participationRequestForm':'https://motorolasolutions.secure.force.com/participationRequestForm';
                
      //private String PARTNER_ADMINISTRATION_LEARN_MORE_EMEA = isProduction?'https://motorolasolutions.secure.force.com/partnerportal/Resources-Administrator-Dashboard':'https://motorolasolutions.secure.force.com/partnerportal/Resources-Administrator-Dashboard';
         
      //  private String AGENT_MR_REPORTING = isProduction?'https://businessonline.motorolasolutions.com/Member/AgentCommision/agent_id_search.asp':'https://businessonline.motorolasolutions.com/Member/AgentCommision/agent_id_search.asp';
        
    private String ABP_MR_REGISTRATION = isProduction?'https://businessonline.motorolasolutions.com/Member/Menus/show_menu.asp?menu=Alt+Channel+Registration':'https://businessonline.motorolasolutions.com/Member/Menus/show_menu.asp?menu=Alt+Channel+Registration';        

      private String CO_BRANDING_WIZARD = isProduction?'https://oamprod.motorolasolutions.com/oamfed/idp/initiatesso?providerid=http://msp.elateral.com/sso/':'https://oamprod.motorolasolutions.com/oamfed/idp/initiatesso?providerid=http://msp.elateral.com/sso/';
        private String CO_BRANDING_WIZARD_LEARN_MORE = isProduction?'https://motorolasolutions.secure.force.com/partnerportal/Resources-Co-Branding-Wizard':'https://motorolasolutions.secure.force.com/partnerportal/Resources-Co-Branding-Wizard';

        private String COMMERCIAL_SYSTEMS_SITE = isProduction?'http://rewards.motorolasolutions.com/':'http://rewards.motorolasolutions.com/';
        private String COMMERCIAL_SYSTEMS_SITE_LEARN_MORE = isProduction?'https://motorolasolutions.secure.force.com/partnerportal/Resources-Sales-Commercial-Systems':'https://motorolasolutions.secure.force.com/partnerportal/Resources-Sales-Commercial-Systems';
        
        private String MARKET_DEVELOPMENT_FUNDS_NA = isProduction?'https://oamprod.motorolasolutions.com/oamfed/idp/initiatesso?providerid=https://sso2.tradeonemktg.com':'https://oamprod.motorolasolutions.com/oamfed/idp/initiatesso?providerid=https://sso2.tradeonemktg.com';
        private String MARKET_DEVELOPMENT_FUNDS_NA_LEARN_MORE = isProduction?'https://motorolasolutions.secure.force.com/partnerportal/Resources-Cooperative-Marketing-Program-Co-op':'https://motorolasolutions.secure.force.com/partnerportal/Resources-Cooperative-Marketing-Program-Co-op';

    //private String MARKET_DEVELOPMENT_FUNDS_EMEA = isProduction?'https://cims.ccionline.biz/motorolasso.aspx':'https://cims.ccionline.biz/motorolasso.aspx';
        //private String MARKET_DEVELOPMENT_FUNDS_EMEA_LEARN_MORE = isProduction?'https://partnercentral.motorolasolutions.com/resources/marketing/mdf.aspx':'https://partnercentral.motorolasolutions.com/resources/marketing/mdf.aspx';
    
                    
    private String DEAL_REGISTRATION_ACCESS = isProduction?'https://motorolasolutions.my.salesforce.com/home/home.jsp':'https://motorolasolutions.my.salesforce.com/home/home.jsp';
        //private String DEAL_REGISTRATION_REGISTER = isProduction?'http://motorolasolutions.secure.force.com/portalaccess':'http://motorolasolutions.secure.force.com/portalaccess';
        //private String DEAL_REGISTRATION_LEARN_MORE = isProduction?'https://motorolasolutions.secure.force.com/partnerportal/Resources-Deal-Registration-NA':'https://motorolasolutions.secure.force.com/partnerportal/Resources-Deal-Registration-NA';
        
    //private String DEAL_REGISTRATION_ACCESS_EMEA = isProduction?'https://motorolasolutions.my.salesforce.com/a11/o':'https://motorolasolutions.my.salesforce.com/a11/o';
        //private String DEAL_REGISTRATION_REGISTER_EMEA = isProduction?'http://motorolasolutions.secure.force.com/PortalAccessRequestEMEAdealReg':'http://motorolasolutions.secure.force.com/PortalAccessRequestEMEAdealReg';
        //private String DEAL_REGISTRATION_LEARN_MORE_EMEA = isProduction?'https://motorolasolutions.secure.force.com/partnerportal/Resources-Deal-Registration-NA':'https://motorolasolutions.secure.force.com/partnerportal/Resources-Deal-Registration-NA';

        private String EMPOWER_REWARDS_NA = isProduction?'http://rewards.motorolasolutions.com/':'http://rewards.motorolasolutions.com/';
        private String EMPOWER_REWARDS_LEARN_MORE_NA = isProduction?'https://motorolasolutions.secure.force.com/partnerportal/Resources-Sales-Empower-Rewards':'https://motorolasolutions.secure.force.com/partnerportal/Resources-Sales-Empower-Rewards';

        private String NA_CHANNEL_PARTNER_SCORECARD = isProduction?label.Scorecard_Prod_URL:label.Scorecard_Test_URL;
        private String NA_CHANNEL_PARTNER_SCORECARD_LEARN_MORE = isProduction?label.Scorecard_LearnMore_Prod:label.Scorecard_LearnMore_Test;
        
        private String GLOBAL_CHANNEL_PARTNER_SCORECARD = isProduction?'https://partnercentral.motorolasolutions.com/scorecard/ProgramStatus.aspx':'https://partnercentral-uat.motorolasolutions.com/scorecard/ProgramStatus.aspx';
        private String GLOBAL_CHANNEL_PARTNER_SCORECARD_LEARN_MORE = isProduction?'https://motorolasolutions.secure.force.com/partnerportal/Resources-Channel-Partner-Scorecard':'https://motorolasolutions.secure.force.com/partnerportal/Resources-Channel-Partner-Scorecard';
        
        
    private String IMPACT_21 = isProduction?'https://businessonline.motorolasolutions.com/Member/Menus/show_menu.asp?menu=Impact+21':'https://businessonline.motorolasolutions.com/Member/Menus/show_menu.asp?menu=Impact+21';
        private String IMPACT_21_LEARN_MORE = isProduction?'https://motorolasolutions.secure.force.com/partnerportal/Resources-IMPACT21':'https://motorolasolutions.secure.force.com/partnerportal/Resources-IMPACT21';

        //private String LEAD_MANAGEMENT_REGISTER = isProduction?'https://motorolasolutions.secure.force.com/portalaccess':'https://motorolasolutions.secure.force.com/portalaccess';
        private String LEAD_MANAGEMENT_ACCESS_NAMR = isProduction?'https://motorolasolutions.my.salesforce.com/servlet/servlet.Integration?lid=01r80000000HiD2&ic=1':'https://motorolasolutions.my.salesforce.com/servlet/servlet.Integration?lid=01r80000000HiD2&ic=1';        
    private String LEAD_MANAGEMENT_ACCESS = isProduction?'https://motorolasolutions.my.salesforce.com/00Q/o':'https://motorolasolutions.my.salesforce.com/00Q/o';
        private String LEAD_MANAGEMENT_LEARN_MORE = isProduction?'https://motorolasolutions.secure.force.com/partnerportal/Resources-Lead-Management-PRM':'https://motorolasolutions.secure.force.com/partnerportal/Resources-Lead-Management-PRM';
        
    
        private String LEARNING_MANAGEMENT_SYSTEM = isProduction?'https://learning.motorolasolutions.com':'https://learning.motorolasolutions.com';
        private String LEARNING_MANAGEMENT_SYSTEM_LEARN_MORE = isProduction?'https://motorolasolutions.secure.force.com/partnerportal/Resources-Training-and-Certification':'https://motorolasolutions.secure.force.com/partnerportal/Resources-Training-and-Certification';

        private String MOL_NA = isProduction?'https://businessonline.motorolasolutions.com/':'https://businessonline.motorolasolutions.com/';
        private String MOL_LEARN_MORE_NA = isProduction?'https://motorolasolutions.secure.force.com/partnerportal/Resources-MOL':'https://motorolasolutions.secure.force.com/partnerportal/Resources-MOL';
        private String MOL_EMEA = isProduction?'https://emeaonline.motorolasolutions.com':'https://emeaonline.motorolasolutions.com';
        private String Social_On_Demand = isProduction?'https://socialondemand.motorolasolutions.com':'https://socialondemand.motorolasolutions.com';
        private String Social_On_Demand_LEARN_MORE = isProduction?'https://motorolasolutions.secure.force.com/partnerportal/Resources-Social-On-Demand':'https://motorolasolutions.secure.force.com/partnerportal/Resources-Social-On-Demand';
        
        private String APP_FINDER_NA = isProduction?'http://mpe.motorolasolutions.com/?loc=US-EN':'http://mpe.motorolasolutions.com/?loc=US-EN';
        private String APP_FINDER_EA = isProduction?'http://mpe.motorolasolutions.com/?loc=XU-EN':'http://mpe.motorolasolutions.com/?loc=XU-EN';        
        private String APP_FINDER_LEARN_MORE_NA = isProduction?'https://motorolasolutions.secure.force.com/partnerportal/Resources-Partner-Finder-or-Application-Finder':'https://motorolasolutions.secure.force.com/partnerportal/Resources-Partner-Finder-or-Application-Finder';

        //private String APP_FINDER_EMEA = isProduction?'http://mpe.motorolasolutions.com/?loc=XU-EN':'http://mpe.motorolasolutions.com/?loc=XU-EN';
        //private String APP_FINDER_LEARN_MORE_EMEA = isProduction?'https://motorolasolutions.secure.force.com/partnerportal/Resources-Partner-Finder-or-Application-Finder':'https://motorolasolutions.secure.force.com/partnerportal/Resources-Partner-Finder-or-Application-Finder';

        private String PARTNER_ORIENTATION_NA = isProduction?'https://partnercentral.motorolasolutions.com/radio_orientation/index.html':'https://partnercentral.motorolasolutions.com/radio_orientation/index.html';
        
        private String PRODUCT_APPLICATION_IMAGES_REGISTER = isProduction?'https://www.motorolasolutionscollective.com':'https://www.motorolasolutionscollective.com';
        private String PRODUCT_APPLICATION_IMAGES_LEARN_MORE = isProduction?'https://motorolasolutions.secure.force.com/partnerportal/Resources-Product-and-Application-Images':'https://motorolasolutions.secure.force.com/partnerportal/Resources-Product-and-Application-Images';

    private String PROMOTIONS_INCENTIVES_LEARN_MORE_NA = isProduction?'https://motorolasolutions.secure.force.com/partnerportal/Resources-Promotions-and-Incentives':'https://motorolasolutions.secure.force.com/partnerportal/Resources-Promotions-and-Incentives';
    
    Private String MR_REGISTRATION = isProduction?'https://motorolasolutions.secure.force.com/partnerportal/a7X/o':'https://motorolasolutions.secure.force.com/partnerportal/a7X/o';
    Private String MR_REGISTRATION_LEARN_MORE = isProduction?'https://motorolasolutions.secure.force.com/partnerportal/Resources-Sales-MR-Registration':'https://motorolasolutions.secure.force.com/partnerportal/Resources-Sales-MR-Registration'; 
    
    Private String STRATUS_CONFIGURATOR = isProduction?label.URL_for_Stratus_Configurator:label.URL_for_Stratus_Configurator;
    Private String SALES_VIEW = isProduction?label.Sales_View_Access_PROD_URL:label.Sales_View_Access_Test_URL;
    Private String SALES_VIEW_LEARN_MORE = isProduction?label.Sales_View_LearnMore_PROD_URL:label.Sales_View_LearnMore_Test_URL;
    Private String MR_FINANCING_QUOTE_TOOL = isProduction?'https://mcclease.motorolasolutions.com/':'https://mcclease.motorolasolutions.com/';
    
    //private String TURF_BUILDER_II = isProduction?'https://businessonline.motorolasolutions.com/member/impact21/birst/birst.asp?ClickedOn=birst':'https://businessonline.motorolasolutions.com/member/impact21/birst/birst.asp?ClickedOn=birst';
        //private String TURF_BUILDER_II_LEARN_MORE = isProduction?'https://motorolasolutions.secure.force.com/partnerportal/Resources-Turf-Builder-II':'https://motorolasolutions.secure.force.com/partnerportal/Resources-Turf-Builder-II';


        //private String SALES_POWER2_LEARN_MORE_EMEA = isProduction?'https://partnercentral.motorolasolutions.com/resources/promotions/Salespower_Incentive_Program.aspx':'https://partnercentral.motorolasolutions.com/resources/promotions/Salespower_Incentive_Program.aspx';
        

        //private String APPX_EMEA = isProduction?'http://www.motorolasolutions.com/emea/appx':'http://www.motorolasolutions.com/emea/appx';
        //private String APPX_LEARN_MORE_EMEA = isProduction?'https://partnercentral.motorolasolutions.com/resources/sales/appfinder_appx.aspx':'https://partnercentral.motorolasolutions.com/resources/sales/appfinder_appx.aspx';        
        
    //private String REP_CONNECT = isProduction?'http://www.coming-in-first.com':'http://www.coming-in-first.com';
                                                                
        
        //Quick Links -- Stubbed out... not sure what the actual quick links are or where they go
        /*
        private String QL_CASE_STUDIES = isProduction?'':'';        
        private String QL_EVENTS = isProduction?'':'';      
        private String QL_SOLUTION_BUILDER = isProduction?'':'';        
        private String QL_SUPPORT_CENTRAL = isProduction?'':'';     
        private String QL_TRAINING_CERTIFICATION = isProduction?'':'';  
        private Map<String, String> quickLinkMap = new Map<String, String>{'Case Studies' => QL_CASE_STUDIES, 'Events' => QL_EVENTS, 'Solution Builder' => QL_SOLUTION_BUILDER, 'Training & Certification' => QL_TRAINING_CERTIFICATION};
            

        private Map<String, String> CODE_TO_NAME_MAP = new Map<String, String>{'ELC' => 'My Licenses', 'ISR' => 'My Orders', 'IRC' => 'My Receivables', 'ECT' => 'My Contracts'};
        private Map<String, String> CODE_TO_LINK_ACCESS_MAP = new Map<String, String>{'ELC' => ELC_ACCESS_LINK, 'ISR' => ISR_ACCESS_LINK, 'IRC' => IRC_ACCESS_LINK, 'ECT' => ECT_ACCESS_LINK};
        private Map<String, String> CODE_TO_LINK_UPGRADE_ACCESS_MAP = new Map<String, String>{'ELC' => '', 'ISR' => ISR_UPGRADE_ACCESS_LINK, 'IRC' => '', 'ECT' => ''};
        private Map<String, String> CODE_TO_LINK_ACCESS_PENDING_MAP = new Map<String, String>{'ELC' => '', 'ISR' => ISR_ACCESS_PENDING_LINK, 'IRC' => IRC_ACCESS_PENDING_LINK, 'ECT' => ECT_ACCESS_PENDING_LINK};
        private Map<String, String> CODE_TO_LINK_LEARN_MORE_MAP = new Map<String, String>{'ELC' => ELC_LEARN_MORE_LINK, 'ISR' => '', 'IRC' => '', 'ECT' => ''};
        private Map<String, String> CODE_TO_REGISTER_MAP = new Map<String, String>{'ELC' => ELC_REGISTER_LINK, 'ISR' => ISR_REGISTER_LINK, 'IRC' => IRC_REGISTER_LINK, 'ECT' => ECT_REGISTER_LINK};
        */
        
        public UserEmpoweringTools(Id userId){
            Boolean superUser;
            Boolean IsVarPcr=false;    // INC0869741: Added by Harish 
            Boolean IsVarMcr=false;    // INC0869741: Added by Harish
            this.empoweringLinks = new List<MotAppAccess>();
            //this.quickLinks = new List<MotAppAccess>();
            User u = new User();
//  RC - 6/18/2014 - avoiding creating a new account and contact
//            Account a = new Account();
//            Contact c = new Contact();
            Account a;
            Contact c;
//  RC - 6/18/2014 - partnerList is not used
//            List<Partner_Type__c> partnerList = new List<Partner_Type__c>();
            Set<String> trackSet = new Set<String>();
//  RC - 6/18/2014 - techList is not used
//            List<Technology_Specialization__c> techList = new List<Technology_Specialization__c>();
            Set<String> communitySet = new Set<String>();
            Set<String> techSet = new Set<String>();
            Set<String> techSpecLevelSet = new Set<String>();            
            Set<String> marketSet = new Set<String>();
            List<String> quickLinkStringList = new List<String>();
            Set<String> programSet = new Set<String>();
            Set<String> purchaseSet = new Set<String>();
            for(User use : [Select Id, motappaccess__c, Quick_Links__c, AccountId, ContactId FROM User WHERE Id = :userId]){
                u = use;
            }
            superUser = (u.ContactId == null)?true:false;
            System.debug('superUser:  ' + superUser);
            if(u.Quick_Links__c != null){
                quickLinkStringList = u.Quick_Links__c.split(';');
            }
      try
      {
        a = [Select Id, Partner_Region__c, Partner_HQ_Country__c FROM Account WHERE Id = :u.AccountId LIMIT 1];
      }
      catch (Exception ex)
      {
        a = new Account();
      }
//      for(Account acct : [Select Id, Partner_Region__c, Partner_HQ_Country__c FROM Account WHERE Id = :u.AccountId]){
//                a = acct;
//            }
//            System.debug('a.Partner_Region__c:  ' + a.Partner_Region__c);
      try
      {
        c = [Select Id, Primary_Contact_Type__c, Contact_Type__c, Tag__c FROM Contact WHERE Id = :u.ContactId LIMIT 1];
      }
      catch (Exception ex)
      {
        c = new Contact();
      }
//            for(Contact con : [Select Id, Primary_Contact_Type__c, Contact_Type__c FROM Contact WHERE Id = :u.ContactId]){
//                c = con;
//            }
            for(Partner_Type__c part : [Select p.Partner_Track__c, p.Account__c, p.Program__c, p.Purchasing_Method__c From Partner_Type__c p WHERE Account__c = :u.AccountId]){
//  RC - 6/18/2014 - partnerList is not used
//                partnerList.add(part);
                programSet.add(part.Program__c);
                purchaseSet.add(part.Purchasing_Method__c);
                trackSet.add(part.Partner_Track__c);
            }
            for(Technology_Specialization__c tech : [Select t.Id, t.Community_Type__c, t.Technology_Specialization__c, t.Technology_Specialization_Level__c, t.Account__c From Technology_Specialization__c t where Account__c = :u.AccountId]){
//  RC - 6/18/2014 - techList is not used
//                techList.add(tech);
                communitySet.add(tech.Community_Type__c);
                techSet.add(tech.Technology_Specialization__c);
                if(tech.Technology_Specialization__c == 'Mission Critical Radio Systems' || tech.Technology_Specialization__c == 'Professional and Commercial Radio')
                techSpecLevelSet.add(tech.Technology_Specialization_Level__c);
                
                /*** INC0869741: Addded by Harish***/
                if(tech.Technology_Specialization_Level__c!='' && tech.Technology_Specialization_Level__c!='open' && tech.Community_Type__c=='Value Added Reseller' && tech.Technology_Specialization__c == 'Mission Critical Radio Systems' )
                {
                IsVarMcr=true;  
                }
                if(tech.Technology_Specialization_Level__c!='' && tech.Technology_Specialization_Level__c!='open' && tech.Community_Type__c=='Value Added Reseller' && tech.Technology_Specialization__c == 'Professional and Commercial Radio')
                {
                IsVarPcr=true;  
                }
                /** Ended by Harish***/
                
                
            }
            
            for(Market_Specializations__c m : [Select Market_Specialization__c FROM Market_Specializations__c WHERE Account__c = :u.AccountId]){
                marketSet.add(m.Market_Specialization__c);        
            }
            List<MotAppAccess> hasAccessList = new List<MotAppAccess>();
            List<MotAppAccess> trilogyAccessList = new List<MotAppAccess>();
            List<MotAppAccess> quickLinkList = new List<MotAppAccess>();
            
            List<MotAppLink> singleLinkList = new List<MotAppLink>();

            //Quick Links
            /*
            for(Integer i = 0; i < quickLinkStringList.size(); i++){
                singleLinkList.add(new MotAppLink('Access', quickLinkMap.get(quickLinkStringList[i])));
                quickLinkList.add(new MotAppAccess(quickLinkStringList[i], singleLinkList));
                singleLinkList = new List<MotAppLink>();
            }
            //Start to create the empowering tool links here:
            if((a.Partner_Region__c == 'NAMR') && (c.Primary_Contact_Type__c == 'Executive' || c.Contact_Type__c == 'Executive') || superUser){
                singleLinkList.add(new MotAppLink('Access', CHANNEL_PARTNER_SCORECARD_NA));
                singleLinkList.add(new MotAppLink('Learn More', GENERIC_LEARN_MORE));
                hasAccessList.add(new MotAppAccess('Channel Partner Scorecard', singleLinkList));
                singleLinkList = new List<MotAppLink>();
            }*/
            String secondaryTypeString = c.Contact_Type__c;
                if(secondaryTypeString == null || secondaryTypeString == ''){
                  secondaryTypeString = 'none';    
                }
            String tagString = c.Tag__c;
            if (tagString == null || tagString == '') {
                tagString = 'none';
            }                
             //System.debug('Tech Specialization Val :'+techSpecLevelSet.contains('Open'));
            //Start to create the empowering tool links here:
            if((a.Partner_Region__c == 'NAMR') && ((techSet.contains('Mission Critical Radio Systems') || techSet.contains('Professional and Commercial Radio')) && (techSpecLevelSet.contains('Authorized') || techSpecLevelSet.contains('Specialist') || techSpecLevelSet.contains('Elite Specialist'))) && ((c.Primary_Contact_Type__c == 'Executive' || c.Primary_Contact_Type__c == 'Key Contact') || (secondaryTypeString.contains('Executive') || secondaryTypeString.contains('Key Contact') || tagString.contains('SFDC Partner Admin') || tagString.contains('Partner Scorecard Access'))) || superUser){
                singleLinkList.add(new MotAppLink('Access', NA_CHANNEL_PARTNER_SCORECARD));
                singleLinkList.add(new MotAppLink('Learn More', NA_CHANNEL_PARTNER_SCORECARD_LEARN_MORE));
                hasAccessList.add(new MotAppAccess('Channel Partner Scorecard', singleLinkList));
                singleLinkList = new List<MotAppLink>();
            }

            if((a.Partner_Region__c == 'NAMR') && ((techSet.contains('Mission Critical Radio Systems') && (communitySet.contains('State/Local Manufacturer Representative') || communitySet.contains('Federal Manufacturer Representative')))) || superUser)
            {
                singleLinkList.add(new MotAppLink('Access', MR_REGISTRATION));
                singleLinkList.add(new MotAppLink('Learn More', MR_REGISTRATION_LEARN_MORE));
                hasAccessList.add(new MotAppAccess('MR Registration', singleLinkList));
                singleLinkList = new List<MotAppLink>();
            }

            if((a.Partner_Region__c == 'NAMR') && (tagString.contains('Permission for Stratus Configurator')) && ((techSet.contains('Mission Critical Radio Systems') && (communitySet.contains('State/Local Manufacturer Representative') || communitySet.contains('Federal Manufacturer Representative')))) || superUser)
            {
                singleLinkList.add(new MotAppLink('Access', STRATUS_CONFIGURATOR));
                hasAccessList.add(new MotAppAccess('Stratus Configurator', singleLinkList));
                singleLinkList = new List<MotAppLink>();
            } 
            // Added by Harish : INC0869741-Enable SALES VIEW access for PCR Resellers & Federal Resellers only
           if(SuperUser || ((a.Partner_Region__c == 'NAMR') && (tagString.contains('Sales View Admin') || tagString.contains('Sales View Rep') )&& ( IsVarPcr || (IsVarMcr && marketSet.contains('US Federal')))))
            {
                singleLinkList.add(new MotAppLink('Access', SALES_VIEW));
                singleLinkList.add(new MotAppLink('Learn More', SALES_VIEW_LEARN_MORE));
                hasAccessList.add(new MotAppAccess('Sales View', singleLinkList));
                singleLinkList = new List<MotAppLink>();
            } 
            
            if((a.Partner_Region__c == 'EMEA') && ((techSet.contains('Mission Critical Radio Systems') || techSet.contains('Professional and Commercial Radio') || techSet.contains('Business Radio')) && (techSpecLevelSet.contains('Authorized') || techSpecLevelSet.contains('Specialist') || techSpecLevelSet.contains('Elite Specialist'))) && ((c.Primary_Contact_Type__c == 'Executive' || c.Primary_Contact_Type__c == 'Key Contact') || (secondaryTypeString.contains('Executive') || secondaryTypeString.contains('Key Contact') || tagString.contains('SFDC Partner Admin') || tagString.contains('Partner Scorecard Access'))) || superUser){
                singleLinkList.add(new MotAppLink('Access', GLOBAL_CHANNEL_PARTNER_SCORECARD));
                singleLinkList.add(new MotAppLink('Learn More', GLOBAL_CHANNEL_PARTNER_SCORECARD_LEARN_MORE));
                hasAccessList.add(new MotAppAccess('Channel Partner Scorecard', singleLinkList));
                singleLinkList = new List<MotAppLink>();
            }            
            if((a.Partner_Region__c == 'NAMR' || a.Partner_Region__c == 'EMEA' || a.Partner_Region__c == 'APAC' || a.Partner_Region__c == 'LACR') || superUser){
                singleLinkList.add(new MotAppLink('Access', LEARNING_MANAGEMENT_SYSTEM));
                singleLinkList.add(new MotAppLink('Learn More', LEARNING_MANAGEMENT_SYSTEM_LEARN_MORE));
                hasAccessList.add(new MotAppAccess('Learning Management System (LMS)', singleLinkList));
                singleLinkList = new List<MotAppLink>();
            }
      /*
            if(a.Partner_Region__c == 'EMEA' || superUser){
                singleLinkList.add(new MotAppLink('Register & Access', MARKET_DEVELOPMENT_FUNDS_EMEA));
                singleLinkList.add(new MotAppLink('Learn More', MARKET_DEVELOPMENT_FUNDS_EMEA_LEARN_MORE));
                hasAccessList.add(new MotAppAccess('Market Development Funds', singleLinkList));
                singleLinkList = new List<MotAppLink>();
            }*/
            
            if(a.Partner_Region__c == 'NAMR' || a.Partner_Region__c == 'EMEA'|| superUser){
                singleLinkList.add(new MotAppLink('Access', MARKET_DEVELOPMENT_FUNDS_NA));
                singleLinkList.add(new MotAppLink('Learn More', MARKET_DEVELOPMENT_FUNDS_NA_LEARN_MORE));
                hasAccessList.add(new MotAppAccess('Co-Op Funds', singleLinkList));
                singleLinkList = new List<MotAppLink>();
            }
            if((a.Partner_Region__c == 'NAMR' || a.Partner_Region__c == 'EMEA') || superUser){
            singleLinkList.add(new MotAppLink('Access', CO_BRANDING_WIZARD));
            singleLinkList.add(new MotAppLink('Learn More', CO_BRANDING_WIZARD_LEARN_MORE));
            hasAccessList.add(new MotAppAccess('Co-Branding Wizard', singleLinkList));
            singleLinkList = new List<MotAppLink>();
            }
            if((a.Partner_Region__c == 'NAMR' && marketSet.contains('US Federal')) || superUser){
                singleLinkList.add(new MotAppLink('Access', DEAL_REGISTRATION_ACCESS));
                //singleLinkList.add(new MotAppLink('Register', DEAL_REGISTRATION_REGISTER));
              //singleLinkList.add(new MotAppLink('Learn More', DEAL_REGISTRATION_LEARN_MORE));
              hasAccessList.add(new MotAppAccess('Federal Deal Registration', singleLinkList));
              singleLinkList = new List<MotAppLink>();
            }
            
            if(a.Partner_Region__c == 'NAMR' || superUser){
                singleLinkList.add(new MotAppLink('Access', LEAD_MANAGEMENT_ACCESS_NAMR));
              //singleLinkList.add(new MotAppLink('Register', LEAD_MANAGEMENT_REGISTER));
              singleLinkList.add(new MotAppLink('Learn More', LEAD_MANAGEMENT_LEARN_MORE));
              hasAccessList.add(new MotAppAccess('Lead Management', singleLinkList));
              singleLinkList = new List<MotAppLink>();
            
            }
            /*
            if(a.Partner_Region__c == 'LACR' || a.Partner_Region__c == 'EMEA' || superUser){
                singleLinkList.add(new MotAppLink('Access', LEAD_MANAGEMENT_ACCESS));
            }
            
            if(a.Partner_Region__c == 'NAMR' || superUser){
                singleLinkList.add(new MotAppLink('Access', SERVICE_REFERRALS_ACCESS));
                singleLinkList.add(new MotAppLink('Register', SERVICE_REFERRALS_REGISTER));
                singleLinkList.add(new MotAppLink('Learn More', SERVICE_REFERRALS_LEARN_MORE));
              hasAccessList.add(new MotAppAccess('Service Referrals', singleLinkList));
              singleLinkList = new List<MotAppLink>();
            } */
            
            
            if(((a.Partner_Region__c == 'NAMR' || a.Partner_Region__c == 'EMEA') && tagString.contains('SFDC Partner Admin'))|| superUser){
            singleLinkList.add(new MotAppLink('Access', PARTNER_ADMINISTRATION_ACCESS));      
            singleLinkList.add(new MotAppLink('Learn More', PARTNER_ADMINISTRATION_LEARN_MORE));                                
            hasAccessList.add(new MotAppAccess('Administrator Dashboard', singleLinkList));
            singleLinkList = new List<MotAppLink>();
            }
            /*
            singleLinkList.add(new MotAppLink('Access Salesforce', INFLUENCE_REWARDS_ACCESS_SALESFORCE));
            singleLinkList.add(new MotAppLink('Register', INFLUENCE_REWARDS_REGISTER));
            singleLinkList.add(new MotAppLink('Learn More', INFLUENCE_REWARDS_LEARN_MORE));
            hasAccessList.add(new MotAppAccess('Influence Registration', singleLinkList));
            singleLinkList = new List<MotAppLink>();
      
            

            singleLinkList.add(new MotAppLink('Access', SOLUTION_BUILDER_ACCESS));
            singleLinkList.add(new MotAppLink('Learn More', SOLUTION_BUILDER_LEARN_MORE));
            hasAccessList.add(new MotAppAccess('Solution Builder', singleLinkList));
            singleLinkList = new List<MotAppLink>();

            singleLinkList.add(new MotAppLink('Register & Access', DEVELOPER_CENTRAL_REGISTER_ACCESS));
            singleLinkList.add(new MotAppLink('Learn More', DEVELOPER_CENTRAL_LEARN_MORE));
            hasAccessList.add(new MotAppAccess('Developer Central', singleLinkList));
            singleLinkList = new List<MotAppLink>();
            
            if(communitySet.contains('Application Partner') || superUser){
                singleLinkList.add(new MotAppLink('Access', LAUNCHPAD_FOR_DEVELOPERS_REGISTER_ACCESS));
                singleLinkList.add(new MotAppLink('Learn More', LAUNCHPAD_FOR_DEVELOPERS_LEARN_MORE));
                hasAccessList.add(new MotAppAccess('Launchpad for Developers', singleLinkList));
                singleLinkList = new List<MotAppLink>();
            }else{
                singleLinkList.add(new MotAppLink('Access', LAUNCHPAD_FOR_DEVELOPERS_LEARN_MORE));
                singleLinkList.add(new MotAppLink('Learn More', GENERIC_LEARN_MORE));
                hasAccessList.add(new MotAppAccess('Launchpad for Developers', singleLinkList));
                singleLinkList = new List<MotAppLink>();
            }
            */
            if((a.Partner_Region__c == 'NAMR' || a.Partner_Region__c == 'EMEA') || superUser){
            singleLinkList.add(new MotAppLink('Access', PRODUCT_APPLICATION_IMAGES_REGISTER));
            singleLinkList.add(new MotAppLink('Learn More', PRODUCT_APPLICATION_IMAGES_LEARN_MORE));
            hasAccessList.add(new MotAppAccess('Product & Application Images', singleLinkList));
            singleLinkList = new List<MotAppLink>();
            }
            if((a.Partner_Region__c == 'NAMR') || superUser){
                singleLinkList.add(new MotAppLink('Access', APP_FINDER_NA));
                singleLinkList.add(new MotAppLink('Learn More', APP_FINDER_LEARN_MORE_NA));
                hasAccessList.add(new MotAppAccess('Partner Finder', singleLinkList));
                singleLinkList = new List<MotAppLink>();
            }
            if((a.Partner_Region__c == 'EMEA') || superUser){
                singleLinkList.add(new MotAppLink('Access', APP_FINDER_EA));
                singleLinkList.add(new MotAppLink('Learn More', APP_FINDER_LEARN_MORE_NA));
                hasAccessList.add(new MotAppAccess('Partner Finder', singleLinkList));
                singleLinkList = new List<MotAppLink>();
            }
            /*
            if(a.Partner_Region__c == 'EMEA' || superUser){
                singleLinkList.add(new MotAppLink('Access', APPX_EMEA));
                singleLinkList.add(new MotAppLink('Learn More', APPX_LEARN_MORE_EMEA));
                hasAccessList.add(new MotAppAccess('AppX', singleLinkList));
                singleLinkList = new List<MotAppLink>();

                singleLinkList.add(new MotAppLink('Access', APP_FINDER_EMEA));
                singleLinkList.add(new MotAppLink('Learn More', APP_FINDER_LEARN_MORE_EMEA));
                hasAccessList.add(new MotAppAccess('App Finder', singleLinkList));
                singleLinkList = new List<MotAppLink>();
            }
            singleLinkList.add(new MotAppLink('Access', GLOBAL_UNIVERSAL_PARTNER_LOCATOR));
            singleLinkList.add(new MotAppLink('Learn More', GENERIC_LEARN_MORE));
            hasAccessList.add(new MotAppAccess('Global Universal Partner Locator', singleLinkList));
            singleLinkList = new List<MotAppLink>();
      */
            if(superUser || (a.Partner_Region__c == 'NAMR' )){
                singleLinkList.add(new MotAppLink('Access', MOL_NA));
                singleLinkList.add(new MotAppLink('Learn More', MOL_LEARN_MORE_NA));
                hasAccessList.add(new MotAppAccess('Motorola Online (MOL)', singleLinkList));
                singleLinkList = new List<MotAppLink>();
            }
             
            if(superUser || (a.Partner_Region__c == 'EMEA' && (communitySet.contains('Value Added Reseller') || communitySet.contains('Value Added Distributor')) && purchaseSet.contains('Tier 1'))){
                singleLinkList.add(new MotAppLink('Access', MOL_EMEA));
                singleLinkList.add(new MotAppLink('Learn More', MOL_LEARN_MORE_NA));
                hasAccessList.add(new MotAppAccess('Motorola Online (MOL)', singleLinkList));
                singleLinkList = new List<MotAppLink>();
            }
            
            if(superUser || (a.Partner_Region__c == 'EMEA' ) || a.Partner_Region__c == 'NAMR'){
                singleLinkList.add(new MotAppLink('Access', Social_On_Demand));
                singleLinkList.add(new MotAppLink('Learn More', Social_On_Demand_LEARN_MORE));
                hasAccessList.add(new MotAppAccess('Social on Demand', singleLinkList));
                singleLinkList = new List<MotAppLink>();
            }                
            /*
            if(superUser || (a.Partner_Region__c == 'EMEA' && (techSet.contains('P25 Systems') || techSet.contains('Mission Critical Radio Systems') || techSet.contains('Business Radio') || techSet.contains('Professional and Commercial Radio') || marketSet.contains('US Federal') || techSet.contains('MOTOTRBO') || techSet.contains('TETRA Systems')))){
                singleLinkList.add(new MotAppLink('Access', MOL_EMEA));
                singleLinkList.add(new MotAppLink('Learn More', MOL_LEARN_MORE_NA));
                hasAccessList.add(new MotAppAccess('MOL (EMEA)', singleLinkList));
                singleLinkList = new List<MotAppLink>();
            }*/
            

            if(superUser || (a.Partner_Region__c == 'NAMR' && (communitySet.contains('Manufacturer Representative')) && (techSet.contains('Mission Critical Radio Systems') || techSet.contains('Business Radio') || techSet.contains('Professional and Commercial Radio')))){

                /*
                singleLinkList.add(new MotAppLink('Access', REP_CONNECT));
                singleLinkList.add(new MotAppLink('Learn More', GENERIC_LEARN_MORE));
                hasAccessList.add(new MotAppAccess('Rep Connect', singleLinkList));
                singleLinkList = new List<MotAppLink>();
      
                singleLinkList.add(new MotAppLink('Access', AGENT_MR_REPORTING));
                singleLinkList.add(new MotAppLink('Learn More', GENERIC_LEARN_MORE));
                hasAccessList.add(new MotAppAccess('Agent MR Reporting', singleLinkList));
                singleLinkList = new List<MotAppLink>();
                 */ //commented by Kalai as per INC1037083 

                singleLinkList.add(new MotAppLink('Access', ABP_MR_REGISTRATION));                
                hasAccessList.add(new MotAppAccess('Alternate Channel Registration', singleLinkList));
                singleLinkList = new List<MotAppLink>();

            }
            
            if(superUser || (a.Partner_Region__c == 'NAMR' && techSet.contains('Professional and Commercial Radio'))){

               // singleLinkList.add(new MotAppLink('Access', COMMERCIAL_SYSTEMS_SITE));  // Commented as part of INC0658733
                singleLinkList.add(new MotAppLink('Learn More', COMMERCIAL_SYSTEMS_SITE_LEARN_MORE));
                hasAccessList.add(new MotAppAccess('Commercial System Loading', singleLinkList));
                singleLinkList = new List<MotAppLink>();
                
                //singleLinkList.add(new MotAppLink('Access', TURF_BUILDER_II));
                //singleLinkList.add(new MotAppLink('Learn More', TURF_BUILDER_II_LEARN_MORE));
                //hasAccessList.add(new MotAppAccess('Turf Builder II', singleLinkList));
                //singleLinkList = new List<MotAppLink>();                        

            }

            if((a.Partner_Region__c == 'NAMR' && (techSet.contains('Mission Critical Radio Systems') || techSet.contains('Professional and Commercial Radio'))) || superUser){
                singleLinkList.add(new MotAppLink('Access', EMPOWER_REWARDS_NA));
                singleLinkList.add(new MotAppLink('Learn More', EMPOWER_REWARDS_LEARN_MORE_NA));
                hasAccessList.add(new MotAppAccess('EmpowerRewards', singleLinkList));
                singleLinkList = new List<MotAppLink>();

                singleLinkList.add(new MotAppLink('Access', IMPACT_21));
                singleLinkList.add(new MotAppLink('Learn More', IMPACT_21_LEARN_MORE));
                hasAccessList.add(new MotAppAccess('IMPACT21', singleLinkList));
                singleLinkList = new List<MotAppLink>();

            }
             if((a.Partner_Region__c == 'NAMR' && techSet.contains('Mission Critical Radio Systems') && communitySet.contains('State/Local Manufacturer Representative') ) || superUser){
                singleLinkList.add(new MotAppLink('Access', MR_FINANCING_QUOTE_TOOL));
                hasAccessList.add(new MotAppAccess('MR Financing Quote Tool', singleLinkList));
                singleLinkList = new List<MotAppLink>();
            }

            if(a.Partner_Region__c == 'NAMR' || superUser){                
                singleLinkList.add(new MotAppLink('Learn More', PROMOTIONS_INCENTIVES_LEARN_MORE_NA));
                hasAccessList.add(new MotAppAccess('Promotions & Incentives', singleLinkList));
                singleLinkList = new List<MotAppLink>();
                }
            /*
            if(a.Partner_Region__c == 'EMEA' || superUser){                
                singleLinkList.add(new MotAppLink('Learn More', SALES_POWER2_LEARN_MORE_EMEA));
                hasAccessList.add(new MotAppAccess('Empower Rewards', singleLinkList));
                singleLinkList = new List<MotAppLink>();
                }*/
            
            if((a.Partner_Region__c == 'NAMR' && (communitySet.contains('Value Added Reseller') || communitySet.contains('Manufacturer Representative')) && (techSet.contains('Mission Critical Radio Systems') || techSet.contains('Professional and Commercial Radio'))) || superUser){                
                singleLinkList.add(new MotAppLink('Access', PARTNER_ORIENTATION_NA));
                hasAccessList.add(new MotAppAccess('Partner Orientation', singleLinkList));
                singleLinkList = new List<MotAppLink>();
                }            
            
              /*
                singleLinkList.add(new MotAppLink('Access', MY_SOFTWARE));
                hasAccessList.add(new MotAppAccess('My Software', singleLinkList));
                singleLinkList = new List<MotAppLink>();
            if(a.Partner_Region__c == 'APAC' || superUser){
                singleLinkList.add(new MotAppLink('Access', XCELERATOR_PLUS_APAC));
                singleLinkList.add(new MotAppLink('Learn More', GENERIC_LEARN_MORE));
                hasAccessList.add(new MotAppAccess('Xcelerator Plus-APAC', singleLinkList));
                singleLinkList = new List<MotAppLink>();
                singleLinkList.add(new MotAppLink('Access', EMPOWER_REWARDS_APAC));
                singleLinkList.add(new MotAppLink('Learn More', GENERIC_LEARN_MORE));
                hasAccessList.add(new MotAppAccess('Empower Rewards-APAC', singleLinkList));
                singleLinkList = new List<MotAppLink>();
            }
            */

            //TODO:  Need more info on this one about what values to use for Tech Spec   
            /*       
            if(techSet.contains('Mobile Computing') || superUser){
                singleLinkList.add(new MotAppLink('Access', PSION_IW));
                singleLinkList.add(new MotAppLink('Learn More', GENERIC_LEARN_MORE));
                hasAccessList.add(new MotAppAccess('Psion IW', singleLinkList));
                singleLinkList = new List<MotAppLink>();
            }*/
            
            /*
            if(superUser){
                //load them up with motappaccess
                singleLinkList.add(new MotAppLink('Access', ELC_ACCESS_LINK));
                singleLinkList.add(new MotAppLink('Access Pending', ELC_ACCESS_PENDING_LINK));
                singleLinkList.add(new MotAppLink('Register', ELC_REGISTER_LINK));
                singleLinkList.add(new MotAppLink('Learn More', ELC_LEARN_MORE_LINK));
                trilogyAccessList.add(new MotAppAccess('My Licenses', singleLinkList));
                singleLinkList = new List<MotAppLink>();

                singleLinkList.add(new MotAppLink('Access', ISR_ACCESS_LINK));
                singleLinkList.add(new MotAppLink('Register', ISR_REGISTER_LINK));
                singleLinkList.add(new MotAppLink('Upgrade Access', ISR_UPGRADE_ACCESS_LINK));
                singleLinkList.add(new MotAppLink('Access Pending', ISR_ACCESS_PENDING_LINK));
                singleLinkList.add(new MotAppLink('Learn More', ISR_LEARN_MORE_LINK));
                trilogyAccessList.add(new MotAppAccess('My Orders', singleLinkList));
                singleLinkList = new List<MotAppLink>();

                singleLinkList.add(new MotAppLink('Access', IRC_ACCESS_LINK));
                singleLinkList.add(new MotAppLink('Register', IRC_REGISTER_LINK));
                singleLinkList.add(new MotAppLink('Access Pending', IRC_ACCESS_PENDING_LINK));
                //singleLinkList.add(new MotAppLink('Learn More', IRC_LEARN_MORE_LINK));
                trilogyAccessList.add(new MotAppAccess('My Receivables', singleLinkList));
                singleLinkList = new List<MotAppLink>();

                singleLinkList.add(new MotAppLink('Access', ECT_ACCESS_LINK));
                singleLinkList.add(new MotAppLink('Register', ECT_REGISTER_LINK));
                singleLinkList.add(new MotAppLink('Access Pending', ECT_ACCESS_PENDING_LINK));
                singleLinkList.add(new MotAppLink('Learn More', ECT_LEARN_MORE_LINK));
                trilogyAccessList.add(new MotAppAccess('My Contracts', singleLinkList));
                singleLinkList = new List<MotAppLink>();
            }else{
                if((u.motappaccess__c != null && u.motappaccess__c != '') && u.motappaccess__c.containsIgnoreCase('ELC:A')){
                    singleLinkList.add(new MotAppLink('Access', ELC_ACCESS_LINK));
                    singleLinkList.add(new MotAppLink('Learn More', ELC_LEARN_MORE_LINK));
                    trilogyAccessList.add(new MotAppAccess('My Licenses', singleLinkList));
                }else if((u.motappaccess__c != null && u.motappaccess__c != '') && u.motappaccess__c.containsIgnoreCase('ELC:R')){
                    singleLinkList.add(new MotAppLink('Access Pending', ELC_ACCESS_PENDING_LINK));
                    singleLinkList.add(new MotAppLink('Learn More', ELC_LEARN_MORE_LINK));
                    trilogyAccessList.add(new MotAppAccess('My Licenses', singleLinkList));
                }else if((u.motappaccess__c == null || u.motappaccess__c == '' || u.motappaccess__c.containsIgnoreCase('ELC')) && (programSet.contains('WNS') || programSet.contains('Mobility'))){
                    singleLinkList.add(new MotAppLink('Register', ELC_REGISTER_LINK));
                    singleLinkList.add(new MotAppLink('Learn More', ELC_LEARN_MORE_LINK));
                    trilogyAccessList.add(new MotAppAccess('My Licenses', singleLinkList));
                }
                singleLinkList = new List<MotAppLink>();
    
                if((u.motappaccess__c != null && u.motappaccess__c != '') && u.motappaccess__c.containsIgnoreCase('ISR:A')){
                    singleLinkList.add(new MotAppLink('Access', ISR_ACCESS_LINK));
                    singleLinkList.add(new MotAppLink('Upgrade Access', ISR_UPGRADE_ACCESS_LINK));
                    singleLinkList.add(new MotAppLink('Learn More', ISR_LEARN_MORE_LINK));
                    trilogyAccessList.add(new MotAppAccess('My Orders', singleLinkList));
                }else if((u.motappaccess__c != null && u.motappaccess__c != '') && u.motappaccess__c.containsIgnoreCase('ISR:R')){
                    singleLinkList.add(new MotAppLink('Access Pending', ISR_ACCESS_PENDING_LINK));
                    singleLinkList.add(new MotAppLink('Learn More', ISR_LEARN_MORE_LINK));
                    trilogyAccessList.add(new MotAppAccess('My Orders', singleLinkList));
                }else if((u.motappaccess__c == null || u.motappaccess__c == '' || u.motappaccess__c.containsIgnoreCase('ISR')) && (programSet.contains('WNS') || programSet.contains('Mobility')) && purchaseSet.contains('Tier 1')){
                    singleLinkList.add(new MotAppLink('Register', ISR_REGISTER_LINK));
                    singleLinkList.add(new MotAppLink('Learn More', ISR_LEARN_MORE_LINK));
                    trilogyAccessList.add(new MotAppAccess('My Orders', singleLinkList));
                }
                singleLinkList = new List<MotAppLink>();
    
                if((u.motappaccess__c != null && u.motappaccess__c != '') && u.motappaccess__c.containsIgnoreCase('IRC:A')){
                    singleLinkList.add(new MotAppLink('Access', IRC_ACCESS_LINK));
                    //singleLinkList.add(new MotAppLink('Learn More', IRC_LEARN_MORE_LINK));
                    trilogyAccessList.add(new MotAppAccess('My Receivables', singleLinkList));
                }else if((u.motappaccess__c != null && u.motappaccess__c != '') && u.motappaccess__c.containsIgnoreCase('IRC:R')){
                    singleLinkList.add(new MotAppLink('Access Pending', IRC_ACCESS_PENDING_LINK));
                    //singleLinkList.add(new MotAppLink('Learn More', IRC_LEARN_MORE_LINK));
                    trilogyAccessList.add(new MotAppAccess('My Receivables', singleLinkList));
                }else if((u.motappaccess__c == null || u.motappaccess__c == '' || u.motappaccess__c.containsIgnoreCase('IRC')) && (programSet.contains('WNS') || programSet.contains('Mobility')) && purchaseSet.contains('Tier 1')){
                    singleLinkList.add(new MotAppLink('Register', IRC_REGISTER_LINK));
                    //singleLinkList.add(new MotAppLink('Learn More', IRC_LEARN_MORE_LINK));
                    trilogyAccessList.add(new MotAppAccess('My Receivables', singleLinkList));
                }
                singleLinkList = new List<MotAppLink>();

                if((u.motappaccess__c != null && u.motappaccess__c != '') && u.motappaccess__c.containsIgnoreCase('ECT:A')){
                    singleLinkList.add(new MotAppLink('Access', ECT_ACCESS_LINK));
                    singleLinkList.add(new MotAppLink('Learn More', ECT_LEARN_MORE_LINK));
                    trilogyAccessList.add(new MotAppAccess('My Contracts', singleLinkList));
                }else if((u.motappaccess__c != null && u.motappaccess__c != '') && u.motappaccess__c.containsIgnoreCase('ECT:R')){
                    singleLinkList.add(new MotAppLink('Access Pending', ECT_ACCESS_PENDING_LINK));
                    singleLinkList.add(new MotAppLink('Learn More', ECT_LEARN_MORE_LINK));
                    trilogyAccessList.add(new MotAppAccess('My Contracts', singleLinkList));
                }else if((u.motappaccess__c == null || u.motappaccess__c == '' || u.motappaccess__c.containsIgnoreCase('ECT')) && (programSet.contains('WNS') || programSet.contains('Mobility')) && purchaseSet.contains('Tier 1')){
                    singleLinkList.add(new MotAppLink('Register', ECT_REGISTER_LINK));
                    singleLinkList.add(new MotAppLink('Learn More', ECT_LEARN_MORE_LINK));
                    trilogyAccessList.add(new MotAppAccess('My Contracts', singleLinkList));
                }
                singleLinkList = new List<MotAppLink>();
            }
      */

            hasAccessList.sort();
            
            this.empoweringLinks.addAll(trilogyAccessList);
            this.empoweringLinks.addAll(hasAccessList);
            //this.quickLinks.addAll(quickLinkList);
        }
        
        public String checkNull(String s){
            return (s == null)?'':s;
        }
    }

    
    public class MotAppAccess implements Comparable{
        public String name {get;set;}
        public List<MotAppLink> linkList {get;set;}
        
        public MotAppAccess(){
        }
        
        public MotAppAccess(String n, MotAppLink singleLink){
            this.name = n;
            this.linkList = new List<MotAppLink>();
            this.linkList.add(singleLink);
        }
        
        public MotAppAccess(String n, List<MotAppLink> links){
            this.name = n;
            this.linkList = links;
        }
        
        public Integer compareTo(Object compareTo){
            MotAppAccess compareToMotApp = (MotAppAccess)compareTo;
            return name.compareTo(compareToMotApp.name);
        }
    }
    
    public class MotAppLink{
        public String name {get;set;}
        public String url {get;set;}
        
        public MotAppLink (String n, String u){
            this.name = n;
            this.url = u;
        }
    }
    
    
    /*public class ContentWrapper implements Comparable{
        public DateTime publishedStartDate;
        public Id contentId;
        public Boolean published;
        public cms__Content__c content;
        
        public ContentWrapper(cms__Content__c c){ 
            publishedStartDate = c.cms__Published_Start_Date__c;
            contentId = c.Id;
            published = c.cms__Published__c; 
      content = c;
        }
        
        public Integer compareTo(Object compareTo){
            ContentWrapper compareToContent = (ContentWrapper)compareTo;
            
            Integer returnValue = 0;
            if(publishedStartDate > compareToContent.publishedStartDate){
                returnValue = 1;                
            }else if(publishedStartDate < compareToContent.publishedStartDate){
                returnValue = -1;
            }
            return returnValue;
        }
    }*/
    
    
    public static User mapCustomUserToUser(CustomUser customUser){
        User u = new User();
        for(User use : [Select mh_Blue_Sheet_Read_Write_License__c, WirelessEmail, Utilization_Metric__c, Username, UserType, UserRoleId, UserPreferencesTaskRemindersCheckboxDefault, UserPreferencesReminderSoundOff, UserPreferencesOptOutOfTouch, UserPreferencesHideCSNGetChatterMobileTask, UserPreferencesHideCSNDesktopTask, UserPreferencesEventRemindersCheckboxDefault, UserPreferencesContentNoEmail, UserPreferencesContentEmailAsAndWhen, UserPreferencesApexPagesDeveloperMode, UserPreferencesActivityRemindersPopup, UserPermissionsWirelessUser, UserPermissionsSFContentUser, UserPermissionsOfflineUser, UserPermissionsMobileUser, UserPermissionsMarketingUser, UserPermissionsInteractionUser, UserPermissionsCallCenterAutoLogin, UserPermissionsAvantgoUser, Title, TimeZoneSidKey, Theater__c, Theater_Code__c, Test_Region__c, SystemModstamp, Subregion__c, Street, State, Start_Date__c, Special_Needs__c, Short_R3__c, Sales_Analytics_Data_Refresh__c, Reporting_Data_Type__c, Region__c, ReceivesInfoEmails, ReceivesAdminInfoEmails, ProfileId, Pre_merger_Origin__c, PostalCode, Position__c, Phone, Partner_Administrator__c, Organization__c, Org__c, OfflineTrialExpirationDate, OfflinePdaTrialExpirationDate, Office__c, Non_Friendly_Flag__c, Name, MobilePhone, Migrated_From_NA_Govt__c, ManagerId, LocaleSidKey, LastPasswordChangeDate, LastName, LastModifiedDate, LastModifiedById, LastLoginDate, LanguageLocaleKey, IsPortalEnabled, IsActive, Id, High_Touch__c, Headline_Group__c, Green_Sheet_Read_Write_License__c, Green_Sheet_Read_Only_License__c, Green_Sheet_Managers_License__c, Gold_Sheet_Read_Write_License__c, Gold_Sheet_Read_Only_License__c, Gold_Sheet_Managers_License__c, ForecastEnabled, FirstName, FederationIdentifier, Fax, Extension, Employee_SAP_Hierarchy_Number__c, Employee_R3_Number__c, EmployeeNumber, EmailEncodingKey, Email, Division, Direct_Bill_to_User__c, Department, DelegatedApproverId, DefaultCurrencyIsoCode, CurrencyIsoCode, CreatedDate, CreatedById, Country, Core_ID__c, ContactId, CompanyName, CommunityNickname, City, CallCenterId, Business_Division__c, Blue_Sheet_Read_Only_License__c, Blue_Sheet_Managers_License__c, Area__c, Area_Controller__c, Apttus_Approval__Next_Level_Approver__c, Apttus_Approval__Approval_Level__c, Alias, Additional_Roles__c, AccountId, APTPS_Set_Backup_Approver__c, APTPS_Region__c, APTPS_Permissible_Assignee_Label__c, APTPS_Authorized_Dollar_Value__c, APTPS_Agreement_RecordType__c, Quick_Links__c,Profile.Name From User WHERE Id = :customUser.userId]){
            u = use;
        }
        
        u.Title = customUser.title;
        u.Phone = customUser.phone;
        u.MobilePhone = customUser.mobilePhone;
        u.LanguageLocaleKey = customUser.languageLocaleKey;
        u.Position__c = customUser.position;
        u.Country = customUser.country;
        u.Quick_Links__c = customUser.quickLinks;
        
        return u;       
    }
    
    public static String getUserRegion(){
        for(User u : [Select Contact.Account.Partner_Region__c from user where Id = :UserInfo.getUserId()]){
            return (u.Contact.Account.Partner_Region__c == null || u.Contact.Account.Partner_Region__c == '')?'':u.Contact.Account.Partner_Region__c;
        }
        return '';
    }
}