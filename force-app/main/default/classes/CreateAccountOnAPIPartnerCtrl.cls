public class CreateAccountOnAPIPartnerCtrl {
    //Method to fetch the API Partner Application
    @AuraEnabled
    public static API_Partner_Application__c getAPIPartnerAppl(String recId){
        return fetchApplicationRecord(recId);
        //return [SELECT Id, Application_Status__c, Account__c FROM API_Partner_Application__c WHERE Id =:recId];
    }
    
    //Method to create Account records with values as on API Partner Appl and link.
    @AuraEnabled
    public static String createAccOnApplication(String recId){
        
        API_Partner_Application__c applicationRecord = fetchApplicationRecord(recId);
        if(applicationRecord != NULL){
            Account newAccount = populateAccountFromApplication(applicationRecord);
            if(newAccount.Id != NULL){
                Partner_Type__c partnerType = populateProgramType(applicationRecord, newAccount);
                populateProgramDetail(applicationRecord, newAccount, partnerType);
                update (new API_Partner_Application__c(Id = recId, Account__c = newAccount.Id));
                return 'Success'+newAccount.Id;
            }
            return 'Error';
        }
        return 'Error';
    }
    
    //Method to fetch the API Partner Application
    private static API_Partner_Application__c fetchApplicationRecord(String recId) {
        String query = '';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get('API_Partner_Application__c').getDescribe().fields.getMap();
        integer i = 0;
        for(String fieldName : fieldMap.keyset()){
            query += fieldName + ',' ;
        }        
        query = query.removeEnd(',');
        query = 'SELECT '+query+' FROM API_Partner_Application__c WHERE Id =:recId';
        System.debug('Query complete>> ' + query);
        List<API_Partner_Application__c> applications = Database.query(query);
        system.debug('API Record>>'+applications);
        if(!applications.isEmpty()) return applications[0];
        return NULL;
    }
    
    //Method to populate Account fields with API Partner Application field values
    private static Account populateAccountFromApplication(API_Partner_Application__c applicationRecord) {
        Account newAccount = new Account(
            RecordTypeId = GlobalUtility.recordTypeId('Account', 'Partner'),
            Name = applicationRecord.Company_Name__c,
            Phone = applicationRecord.Contact_Phone_Number__c,
            BillingCountry = applicationRecord.Company_Country__c,
            BillingState= applicationRecord.Company_State__c,
            BillingCity = applicationRecord.Company_City__c,
            BillingStreet = applicationRecord.Company_Address_Line_1__c,
            BillingPostalCode = applicationRecord.Company_Postal_Code__c,
            MPE_Program_Status_New__c = 'Active',                
            Metal_Level__c= '',
            Program_Join_Date__c = Date.today(),
            Hierarchy_Placement__c = 'Regional Account'
        );
        Database.SaveResult sr = Database.insert(newAccount, false);
        if (sr.isSuccess()) {
            System.debug('Successfully inserted account. Account ID: ' + sr.getId());
            return newAccount;
        } else {
            system.debug('test-->');
            return NULL;
        }
    }
    
    //Create Program Type
    private static Partner_Type__c populateProgramType(API_Partner_Application__c applicationRecord, Account newAccount){
        Partner_Type__c programType = new Partner_Type__c(
            Account__c = newAccount.Id,
            Compliance_Status__c = 'Compliant',
            Program__c = 'RADIO',
            Status__c = 'Active'
        );        
        Database.SaveResult sr = Database.insert(programType, false);
        if (sr.isSuccess()) {
            System.debug('Successfully inserted account. Account ID: ' + sr.getId());
            return programType;
        } else {
            return NULL;
        }
    }
    
    //Create Program Details
    private static List<Technology_Specialization__c> populateProgramDetail(API_Partner_Application__c applicationRecord, Account newPartnerAccount,Partner_Type__c partnerType){
        List<Technology_Specialization__c>  programDetailToInsert = new List<Technology_Specialization__c>();
        Date reviewDate = Date.today().addYears(1);
        Technology_Specialization__c programDetail = new Technology_Specialization__c(Partner_Program__c = partnerType.Id,
                                                                                      Account__c = newPartnerAccount.Id,     
                                                                                      Authorized__c = true, 
                                                                                      Compliance_Review_Date__c = reviewDate,
                                                                                      Tech_Specialization_Compliant_Status__c = 'Compliant',
                                                                                      Partner_Category__c = 'Application Developer',
                                                                                      Community_Type__c = 'Application Developer'
                                                                                     );
        programDetailToInsert.add(programDetail);
        
        
        Database.SaveResult[] insertResults = Database.insert(programDetailToInsert, false);
        for (Database.SaveResult sr : insertResults) {
            if (sr.isSuccess()) {
                System.debug('Successfully inserted Program Detail: ' + sr.getId());
                return programDetailToInsert;
            } else {
                return NULL;
            } 
        }
        return NULL;
        
    }
    
    
    
}