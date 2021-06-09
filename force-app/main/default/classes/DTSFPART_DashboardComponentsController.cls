/**
 * @author		Krzysztof Pintscher
 * @created		2020-08-11
 * @updated		2021-01-28
 * @description	Provide data for Dashboard components
 */
public with sharing class DTSFPART_DashboardComponentsController {

    @AuraEnabled
    public static void updatePartnerPortalFlag(){
        try {
            DTSFPART_DashboardComponentsHelper.updatePartnerPortalFlag();
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }        
    }

    @AuraEnabled
    public static List<Opportunity> getDashboardOpportunities(){
        return [
            SELECT Id, Name, CloseDate, StageName, AccountId, Account.Name, SYM_Transaction_Number__c, Amount
            FROM Opportunity
            WHERE StageName IN ('Prospect', 'Position & Align', 'Design & Validate', 'Secure')
            AND Amount != null
            ORDER BY Amount DESC
            LIMIT 10
        ];
    }

    @AuraEnabled
    public static ListView getAllPartnersListViewId(){
        return [SELECT Id FROM ListView WHERE DeveloperName = 'All_Partner_Opportunities' LIMIT 1].get(0);
    }

    @AuraEnabled
    public static List<Lead> getDashboardLeads(){
        return [
            SELECT Id, Name, Company, Email, Status, Budget_Value__c
            FROM Lead
            WHERE Budget_Value__c != NULL AND Status NOT IN ('Won', 'Lost', 'No Pursuit/Reject')
            ORDER BY Budget_Value__c DESC
            LIMIT 10            
        ];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<MPEContact__c> getDashboardUsers(String userRole){
        if (String.isEmpty(userRole)) {
            return [
                SELECT Id, Email__c, Name, First_Name__c, Last_Name__c, City__c, Status__c, Primary_Role__c, CreatedDate, LastModifiedDate
                FROM MPEContact__c
                ORDER BY CreatedDate DESC
                LIMIT 100
            ];
        } else {
            return [
                SELECT Id, Email__c, Name, First_Name__c, Last_Name__c, City__c, Status__c, Primary_Role__c, CreatedDate, LastModifiedDate
                FROM MPEContact__c
                WHERE Primary_Role__c =: userRole
                ORDER BY CreatedDate DESC
                LIMIT 100
            ];
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<LabelValueWrapper> getRolesForUsers(){
        List<LabelValueWrapper> rolesPicklist = new List<LabelValueWrapper>();
        Schema.DescribeFieldResult userRoles = MPEContact__c.Primary_Role__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntry = userRoles.getPicklistValues();
        for (Schema.PicklistEntry entry : picklistEntry) {
			LabelValueWrapper pw = new LabelValueWrapper(entry.getLabel(), entry.getValue());
			rolesPicklist.add(pw);
        }
        return rolesPicklist;
    }

    @AuraEnabled(cacheable=true)
    public static String getCurrentUserPersona(){
        User currentUser = [SELECT Contact.Persona__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1].get(0);
        return currentUser.Contact.Persona__c;
    }

    public static User getCurrentUser() {
        return [
            SELECT Profile.PermissionsModifyAllData, ContactId, Contact.Persona__c, Contact.AccountId, Contact.Partner_Region__c
            FROM User
            WHERE Id =: UserInfo.getUserId() LIMIT 1
        ].get(0);
    }

    @AuraEnabled(cacheable=true)
    public static List<Dashboard_Setting__mdt> getDefaultSettingsForCurrentPersona(String communityHub){
        User currentUser = getCurrentUser();
        /* Is System Admin without Contact */
        if (String.isEmpty(currentUser.ContactId) && currentUser.Profile.PermissionsModifyAllData) {
            return [SELECT Settings__c FROM Dashboard_Setting__mdt WHERE Persona_Type__c = 'SysAdmin' LIMIT 1];
        }
        List<Dashboard_Setting__mdt> userSettings = [
                SELECT Settings__c
                FROM Dashboard_Setting__mdt
                WHERE   Persona_Type__c =: currentUser.Contact.Persona__c AND
                        Partner_Region__c =: currentUser.Contact.Partner_Region__c AND
                        Community_Hub__c = :communityHub
                LIMIT 1
            ];
        if (String.isEmpty(currentUser.Contact.Persona__c) || String.isEmpty(currentUser.Contact.Partner_Region__c) || userSettings.isEmpty()) {
            return [SELECT Settings__c FROM Dashboard_Setting__mdt WHERE Community_Hub__c = :communityHub AND Default_Fallback__c = true LIMIT 1];
        } else {
            return userSettings;
        }
    }

    @AuraEnabled
    public static String getCurrentUserSettings(){
        try {
            User currentUser = [SELECT Contact.DTSFPART_Dashboard_Settings__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1].get(0);
            return currentUser.Contact.DTSFPART_Dashboard_Settings__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void saveCurrentUserSettings(String settings){
        try {
            DTSFPART_DashboardComponentsHelper.saveCurrentUserSettings(settings);
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }        
    }

    @AuraEnabled(cacheable=true)
    public static List<LabelValueWrapper> getDashboardUsersCounter(){
        List<LabelValueWrapper> usersData = new List<LabelValueWrapper>();
        /* Self registered users */
        // Add WHERE condition - AccountId = CurrentUser.AccountID
        List<AggregateResult> pendingUsers = [SELECT COUNT(Id) Counter, Status__c FROM MPEContact__c WHERE Status__c = 'Pending Registration' GROUP BY Status__c];
        /* Contacts */
        // Add WHERE condition - AccountId = CurrentUser.AccountID
        List<AggregateResult> contacts = [SELECT COUNT(Id) Counter, Status__c FROM Contact WHERE Status__c IN ('Active','Inactive','Invited') GROUP BY Status__c];
        for (AggregateResult user : pendingUsers) {
            LabelValueWrapper pw = new LabelValueWrapper(String.valueOf(user.get('Status__c')), String.valueOf(user.get('Counter')));
			usersData.add(pw);
        }
        for (AggregateResult contact : contacts) {
            LabelValueWrapper pw = new LabelValueWrapper(String.valueOf(contact.get('Status__c')), String.valueOf(contact.get('Counter')));
			usersData.add(pw);
        }        
        return usersData;
    }

    @AuraEnabled(cacheable=true)
    public static List<CasesWrapper> getDashboardCases() {
        List<CasesWrapper> casesWrapper = new List<CasesWrapper>();

        if (DTSFPART_DashboardComponentsHelper.isMRCommunityTypeAssignedForUserAccount()) {
            List<AggregateResult> saleCases = [
                SELECT COUNT(Id) Counter, Priority
                FROM Case
                WHERE (RecordType.DeveloperName IN ('MR_Commission_Inquiry', 'MR_Customer_Account_Update', 'MR_Quoting')
                OR (RecordType.DeveloperName = 'Admin_Service_Case' AND Request_Type__c = 'Other'))
                AND Priority != ''
                AND Status NOT IN ('Closed', 'Cancelled', 'Resolved')
                GROUP BY Priority
            ];

            casesWrapper.add(
                new CasesWrapper('Sales', saleCases)
            );
        }
        
        List<AggregateResult> supportCases = [
            SELECT COUNT(Id) Counter, Priority
            FROM Case
            WHERE RecordType.DeveloperName IN ('Admin_Service_Case', 'MSI_Support_Case_Administrative', 'MSI_Support_Case_Order_Management')
            AND Request_Type__c != 'Other'
            AND Priority != ''
            AND Status NOT IN ('Closed', 'Cancelled', 'Resolved')
            GROUP BY Priority
        ];

        casesWrapper.add(
            new CasesWrapper('Support', supportCases)
        );

        return casesWrapper;
    }

    @AuraEnabled
    public static String generateCustomerNumberJson(String customerNumber) {
        Map<String,String> payload = new Map<String,String>();
        String privateKey = System.Label.Secret_Key_for_OCC_Integration; 
        payload.put('customerNumber', customerNumber);       
        return JWT.generateAuthToken(payload, privateKey);
    }    

    public class LabelValueWrapper {
		@AuraEnabled
		public String label { get; set; }
		@AuraEnabled
        public String value { get; set; }
        
        public LabelValueWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    public class CasesWrapper {
        @AuraEnabled
        public String type { get; set; }
        @AuraEnabled
        public List<AggregateResult> cases { get; set; }

        public CasesWrapper(String type, List<AggregateResult> cases) {
            this.type = type;
            this.cases = cases;
        }        
    }

}