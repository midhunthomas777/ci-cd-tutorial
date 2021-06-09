public without Sharing class CommunitiesWithoutSharingClass{

    @AuraEnabled
    public static Account getAccountDetail(String ConAccountID) {
        Account acct = new Account();
        acct=[SELECT id, Name, Type, Partner_Account_Name__c, NameLocal,Government_Tax_Registration_ID__c,Company_Tax_Registration_ID__c,Metal_Level__c, RecordType.Name, Owner.Name, Industry, Primary_Served__c, 
                          Secondary_Served__c, Segment__c, Region__c, Country__c, State__c, Billing_County__c, Territory__c,Company_Email_Address__c,Company_Description__c,Website_URL__c,Additional_Company_Websites__c,
                          Socio_Economic_Status__c,Systems_Integrator_Relationships__c,Contract_Vehicles__c,Contract_Vehicles_Other__c,Partner_Region__c,
                          toLabel(Socio_Economic_Status__c) EconomicStatusLabel,toLabel(Systems_Integrator_Relationships__c) IntegratorRelationshipLabel,toLabel(Contract_Vehicles__c) ContractVehicleLabel,
                          BillingStreet, BillingCity, BillingState, BillingPostalCode,BillingCountry,Customer_Type__c,
                          Phone, Fax, Website, Site, Assigned_MR__c,Assigned_MR__r.Name, Motorola_Customer_Number__c, 
                          CreatedBy.Id, CreatedBy.Name, LastModifiedBy.Name,Reseller_Enabled__c,Customer_or_Prospect_Account__c,Customer_or_Prospect_Account__r.Name,
                          Customer_or_Prospect_Account__r.Assigned_MR__r.Name,Customer_or_Prospect_Account__r.Assigned_MR__c,
              			  Shipping_Name__c,ShippingStreet,ShippingCity,ShippingState,ShippingCountry,ShippingPostalCode
                          FROM account where id=:ConAccountID];
        return acct;
    }
    
    /* Commented by Satish as part of SF-512
    @AuraEnabled
    public static List<Account_Identifier__c> getAccountIdentifierDetail(String ConAccountIdentifierId) {
        List<Account_Identifier__c> acc = new List<Account_Identifier__c>();
        acc =  [SELECT Id,Name,Owner.Name,CreatedBy.Name,LastModifiedBy.Name,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,Address_Line_4__c,
                    Address_Type__c,Assigned_MR__r.Name,Sales_Representative__r.Name,Assigned_Sales_Person__r.Name,City__c,County__c,ERP_Active__c,ID_Number__c,ID_Type__c,Is_Primary__c,
                    Operating_Unit__c,Account__c,Route_to_Market__c,State1__c,Postal_Code__c,Account__r.Name,Country_new__c
                    FROM Account_Identifier__c
                    WHERE Id =: ConAccountIdentifierId];
        return acc;
    }*/
    
    @AuraEnabled
    public static List<Account> getAccountIdentifierDetail(String ConAccountIdentifierId) {
        List<Account> acc = new List<Account>();
        acc =  [SELECT Id,Name,Motorola_Customer_Number__c,Customer_or_Prospect_Account__r.OwnerManager__c,
                        Customer_or_Prospect_Account__c,Customer_or_Prospect_Account__r.Name,
                		Primary_Route_to_Market__c,Assigned_MR__c,Assigned_MR_Sales_Person__c,Assigned_MR_Sales_Person__r.Name,
                		Assigned_MR_Sales_Person__r.Email,Customer_or_Prospect_Account__r.BillingCountry,
                  		Customer_or_Prospect_Account__r.BillingState,Customer_or_Prospect_Account__r.BillingCity
                FROM Account
                WHERE Id =: ConAccountIdentifierId];
        return acc;
    }
    
   @AuraEnabled
    public static List<Partner_Location__c> getPartnerLocationDetail(String ConPartnerLocationId) {
        List<Partner_Location__c> ploc = new List<Partner_Location__c>();
        ploc =  [SELECT Id,Name,Account_Name__c,Account__c,Location_Publish_Flag__c,Country1__c,Country_Code__c,Grouped_Location_Assignment__c,
                     SCR_Number__c,Vendor_Purchase_Site__c,Number_Of_Technicians__c,Number_Of_Certified_Technicians__c,
                     Service_Territory__c,Number_Of_Installers__c,Number_Of_Tower_Climbers__c,Address_Line1__c,
                     Address_Line2__c,Address_Line3__c,Address_Type__c,Phone__c,CreatedBy.Name,LastModifiedBy.Name,
                     City__c,State__c,Postal_code__c,Federal_Status__c
                     FROM Partner_Location__c
                     WHERE Id =: ConPartnerLocationId];
        return ploc;
    }
    
   @AuraEnabled
   public static List<Partner_Profiles__c> getPartnerProfileDetail(String ConPartnerProfileId) {
       List<Partner_Profiles__c> pp = new List<Partner_Profiles__c>();
       pp =  [SELECT Id,Name,Owner.Name,Partner_Locator_Permisson_Granted__c,Company_Owned_Type__c,Account__c,Account__r.Name,of_Ownership__c,Divison_of_or_Owned_by_Another_Company__c,
                  Parent_Corp_GovtTax_Registration_ID__c,Parent_Corporation__c,Parent_Corporation_Street_Address_1__c,Parent_Corporation_Street_Address_2__c,
                  Parent_Corporation_City_Town__c,Parent_Corporation_State_Province__c,Parent_Corporation_Postal_Code__c,Parent_Corporation_Country__c,
                  CreatedBy.Name,LastModifiedBy.Name,Total_Number_of_Company_Employees__c,Total_Number_of_Sales_Personnel__c,Total_Number_of_Accounting_Finance_Per__c,
                  Total_Number_of_Administration_Personnel__c,Total_Number_of_Executive_Management_Per__c,Total_Number_of_Marketing_Personnel__c,Total_Number_of_Technical_Personnel__c,
                  Total_Number_of_Services_Employees__c,Helpdesk_Support_Offered__c,Response_Level_Helpdesk_calls__c,Computer_Based_Call_Training__c,Offers_CS_Solution_Applications__c,
                  Break_Fix_Offered__c,Technical_Support_Offered__c,Customer_Projects_Tech_Support_Pct__c,Diagnostics_Offered__c
                  FROM Partner_Profiles__c
                  WHERE Id =: ConPartnerProfileId];
       return pp;
    }
    
   @AuraEnabled
    public static contact fetchContact(string conId){
        contact currentContact = new contact();
        currentContact = [select Name ,Salutation, FirstName, LastName,Account.Name, First_Name_Local_Language__c ,Last_Name_Local_Language__c ,Title ,AccountId ,Primary_Contact_Type__c ,Contact_Type__c ,Tag__c ,Delete_Requested__c ,RecordTypeId ,RecordType.Name ,Email ,MobilePhone ,Phone ,Fax ,Preferred_Language__c ,Technolgy_Preference__c ,Vertical_Market_Preference__c ,LDAP_Login__c ,CreatedById ,CreatedBy.Name,LastModifiedById,LastModifiedBy.Name,Mailingstreet,MailingPostalCode, MailingState,MailingCity,MailingCountry from contact where id=:conId ];
        return currentContact ;
    }
    
    @AuraEnabled
    public static Lead getLeadDetail(String leadId) { 
       /* return  [SELECT id, Name, Solution_Finder_Product_Selection__c,Solution_Finder_Comments__c,Salutation, FirstName, LastName, Owner.Name, Company, Title, Phone, Email, Rating, Technology_Segment__c, Marketing_Rating__c, Service_Family__c,
                      Industry, Subvertical__c, Budget_Value__c, Status, Opportunity_Reason__c, Reject_Reason__c, Rejection_reason__c, 
                      Hibernate_Reason__c, Lead_Timeframe__c, Lead_Value__c, Territory__c, Description, Website, Street, City, State, Product_Number__c,Number_of_units_users__c,
                      PostalCode, Country, CreatedBy.Name, CreatedDate, LastModifiedDate, LastModifiedBy.Name, LastTransferDate, ConvertedDate,IsConverted, (SELECT Id,Title,LastModifiedDate FROM Notes), (SELECT Id,Name,LastModifiedDate FROM Attachments),
                      (SELECT id, ActivityDate, CallDisposition, CallDurationInSeconds, Description, Owner.Name, Priority, Status, Subject, Type, WhatId, WhoId , TaskSubtype
                       FROM Tasks)                
                      FROM Lead Where id=:leadId];  removed  Reject_Reason__c & Hibernate_Reason__c  */
       //Added LeadSource field to below query (Satish for SF-466)               
       return  [SELECT id, Name, Solution_Finder_Product_Selection__c,Solution_Finder_Comments__c,Salutation, FirstName, LastName, Owner.Name, Company, Title, Phone, Email, Rating, Technology_Segment__c, Marketing_Rating__c, Service_Family__c,
                      Industry, Subvertical__c, Budget_Value__c, Status, Opportunity_Reason__c, Rejection_reason__c, 
                      Lead_Timeframe__c, Lead_Value__c, Territory__c, Description, Website, Street, City, State, Product_Number__c,Number_of_units_users__c,
                      PostalCode, Opportunity_Lookup_For_KYC__c,Opportunity_Lookup_For_KYC__r.Name,Country,Account__r.Name,LeadSource,Overdue_Status__c,Close_Date__c,Customer_Number__c, CreatedBy.Name, CreatedDate, LastModifiedDate, LastModifiedBy.Name, LastTransferDate, ConvertedDate,IsConverted, (SELECT Id,Title,LastModifiedDate FROM Notes), (SELECT Id,Name,LastModifiedDate FROM Attachments),
                      (SELECT id, ActivityDate, CallDisposition, CallDurationInSeconds, Description, Owner.Name, Priority, Status, Subject, Type, WhatId, WhoId , TaskSubtype
                       FROM Tasks)                
                      FROM Lead Where id=:leadId];  
    }   
   
    
}