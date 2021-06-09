public class CreatePartnerAccountCtrl {
    @AuraEnabled
    public static List<Empower_Application__c> isApproved(String recId) {
        return [
            SELECT ID, Partner_Application_Status__c, Partner_Account__c
            FROM Empower_Application__c
            WHERE Id =: recId
        ];
    }
    @AuraEnabled
    public static String createAccOnApplication(String recId) {
        String apiErrorMessage = 'APIError';

        try {
            List<MPEContact__c> uMPE = new List<MPEContact__c> ();
            List<Account> acc = new List<Account> ();
            List<Partner_Profiles__c> lstPartnerProfile = new List<Partner_Profiles__c> ();
            List<Addendum__c> lstAddendum = new List<Addendum__c> ();
            List<MPEContact__c> lstMPEContact = new List<MPEContact__c> ();
            List<Partner_Location__c> lstPartnerLocation = new List<Partner_Location__c> ();
            List<Partner_Type__c> lstPartnerType = new List<Partner_Type__c> ();
            List<Product_Offered__c> lstProductOffred = new List<Product_Offered__c> ();
            List<Industry__c> lstIndustry = new List<Industry__c> ();
            List<Technology_Specialization__c> lstTechSpec = new List<Technology_Specialization__c> ();
            Empower_Application__c applicationRecord = fetchApplicationRecord(recId);
            if (applicationRecord != null) {
                Account newPartnerAccount = populateAccountFromApplication(
                    applicationRecord
                );
                if (newPartnerAccount.Id != null) {
                    createPartnerContact(applicationRecord, newPartnerAccount);
                    populatePartnerLocation(applicationRecord, newPartnerAccount);
                    Partner_Type__c partnerType = populateProgramType(
                        applicationRecord,
                        newPartnerAccount
                    );
                    populateProgramDetail(
                        applicationRecord,
                        newPartnerAccount,
                        partnerType
                    );
                    populateIndustry(applicationRecord, newPartnerAccount);
                    populateProductLines(applicationRecord, newPartnerAccount);
                    linkSignedAdobeAgreementToAccount(newPartnerAccount.Id, recId);
                    update(new Empower_Application__c(
                        Id = recId,
                        Partner_Application_Status__c = 'Account Created',
                        Partner_Account__c = newPartnerAccount.Id
                    ));
                    return 'Success' + newPartnerAccount.Id;
                }
                return apiErrorMessage;
            }
            return apiErrorMessage;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Empower_Application__c fetchApplicationRecord(String recId) {
        List<Empower_Application__c> applications = [
            SELECT
            Id,
            Headquarter_Company_Postal_Code__c,
            Company_Trading_Name__c,
            Partner_Region__c,
            Company_Legal_Name__c,
            Applicant_Primary_Role__c,
            Applicant_Last_Name__c,
            Applicant_Country__c,
            Applicant_State_Province__c,
            Applicant_Phone_Number__c,
			Applicant_Mobile_Number__c,
            Headquarter_Company_Address_1__c,
            Headquarter_Company_Address_2__c,
            Headquarter_Company_Town_City__c,
            Headquarter_Company_State__c,
            Headquarter_Company_Country__c,
            Company_Phone_Number__c,
            Headquarters_Fax_Number__c,
            Main_place_of_business_Postal_Code__c,
            Company_Website__c,
            Primary_Supervertical__c,
            Primary_Location_Fax_Number__c,
            Applicant_Salutation__c,
            Applicant_Secondary_Role_s__c,
            Company_Government_Tax_Registration_ID__c,
            of_Ownership__c,
            Main_place_of_business_State__c,
            Company_Tax_Registration_ID__c,
            Main_place_of_business_Address_2__c,
            Company_Signature_Authrty_Email_Address__c,
            Form_Of_Organization__c,
            Applicant_First_Name__c,
            Main_place_of_business_Town_City__c,
            Company_Signature_Authority_Email__c,
            Company_Signature_Authority_Primary__c,
            Incorporation_Country__c,
            Main_place_of_business_Country__c,
            Are_You_Authorized_to_Sign_Legal_Agmt__c,
            Incorporation_State_Province__c,
            Main_place_of_business_Address_1__c,
            Company_Signature_Authority_Primary_Role__c,
            Additional_Company_Websites__c,
            Partner_Technology_Segment__c,
            Partner_Account__c,
            Company_Signature_Authority_Phone_Number__c,
			Company_Signature_Authority_Mobile__c,
            Company_Description__c,
            Dun_Bradstreet__c,
            Region_Theater__c,
            Partner_Community_Type__c,
            Company_Signature_Authority_First_Name__c,
            Applicant_Primary_Language__c,
            Engagement_Model__c,
            MSI_Business_Group__c,
            Territory__c,
            Partner_Zone__c,
            Applicant_Email_Address__c,
            Parent_Corp_GovtTax_Registration_ID__c,
            Applicant_Title__c,
            Total_Number_of_Technical_Personnel__c,
            Total_Number_of_Marketing_Personnel__c,
            Company_Signature_Authority_Last_Name__c,
            Total_Number_of_Executive_Management_Per__c,
            Main_Business_Phone_Number__c,
            Total_Number_of_Sales_Personnel__c,
            Distributor__c
            FROM Empower_Application__c
            WHERE Id =: recId
        ];
        if (!applications.isEmpty())
            return applications[0];
        return null;
    }
    private static Account populateAccountFromApplication(Empower_Application__c applicationRecord) {
        Account newPartnerAccount = new Account(
            RecordTypeId = GlobalUtility.recordTypeId('Account', 'Partner'),
            NameLocal = applicationRecord.Company_Trading_Name__c,
            Partner_Technology_Segments__c = applicationRecord.Partner_Technology_Segment__c,
            Name = applicationRecord.Company_Legal_Name__c,
            DBA_Trading_Name__c = applicationRecord.Company_Trading_Name__c,
            Partner_Account_Name__c = applicationRecord.Company_Legal_Name__c,
            Main_Phone_Number__c = applicationRecord.Applicant_Phone_Number__c,
            Phone = applicationRecord.Applicant_Phone_Number__c,
            website = applicationRecord.Company_Website__c,
            Partner_Locator_Status__c = 'Inactive',
            Program_Level_Community__c = applicationRecord.Partner_Community_Type__c,
            Type = 'Partner',
            Website_URL__c = applicationRecord.Company_Website__c,
            Government_Tax_Registration_ID__c = applicationRecord.Company_Government_Tax_Registration_ID__c,
            Company_Tax_Registration_ID__c = applicationRecord.Company_Tax_Registration_ID__c,
            Form_Of_Organization__c = applicationRecord.Form_Of_Organization__c,
            Incorporation_Country__c = applicationRecord.Incorporation_Country__c,
            Incorporation_State_Province__c = applicationRecord.Incorporation_State_Province__c,
            Additional_Company_Websites__c = applicationRecord.Additional_Company_Websites__c,
            Company_Description__c = applicationRecord.Company_Description__c,
            D_B_Number__c = string.valueof(applicationRecord.Dun_Bradstreet__c),
            Primary_Langauge__c = applicationRecord.Applicant_Primary_Language__c,
            Engagement_Model__c = applicationRecord.Engagement_Model__c,
            Territory__c = applicationRecord.Territory__c,
            Partner_Zone__c = applicationRecord.Partner_Zone__c,
            MPE_Program_Status_New__c = 'Active',
            Partner_Distributor_email__c = applicationRecord.Applicant_Email_Address__c,
            of_Ownership__c = applicationRecord.of_Ownership__c,
            Parent_Corp_Govt_Tax_Registration_Id__c = applicationRecord.Parent_Corp_GovtTax_Registration_ID__c,
            Total_Number_of_Technical_Personnel__c = applicationRecord.Total_Number_of_Technical_Personnel__c,
            Total_Number_of_Marketing_Personnel__c = applicationRecord.Total_Number_of_Marketing_Personnel__c,
            Total_Number_of_Management_Personnel__c = applicationRecord.Total_Number_of_Executive_Management_Per__c,
            Metal_Level__c = 'Registered',
            Program_Join_Date__c = Date.today(),
            Hierarchy_Placement__c = 'Regional Account',
            //Prospect_Sales_Channel__c = 'Partner',
            Primary_Distributor__c = applicationRecord.Distributor__c,
            Total_Number_of_Sales_Personnel__c = applicationRecord.Total_Number_of_Sales_Personnel__c
        );
        newPartnerAccount.BillingStreet = applicationRecord.Main_place_of_business_Address_1__c;
        if (applicationRecord.Partner_Region__c == 'LA') {
            newPartnerAccount.Partner_Region__c = 'LACR';
        } else {
            newPartnerAccount.Partner_Region__c = applicationRecord.Partner_Region__c;
        }
        Database.SaveResult sr = Database.insert(newPartnerAccount, false);
        if (sr.isSuccess()) {
            System.debug('Successfully inserted account. Account ID: ' + sr.getId());
            return newPartnerAccount;
        } else {
            system.debug('test-->');
            return null;
        }
    }
    private static void createPartnerContact(Empower_Application__c applicationRecord, Account newPartnerAccount) {
        List<Contact> partnerContacts = new List<Contact> ();

        system.debug('inside method-->' + newPartnerAccount.Id);
        Map<String, String> rolePersonaMapping = getRolePersona_Mapping();
        Id partContactRecordtypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Contact', 'MPE_Partner_Contact');
        String persona = '';
        for (MPEContact__c partnerCon: [
                SELECT
                Id,
                First_Name__c,
                Last_Name__c,
                Email__c,
                Mobile__c,
                Phone__c,
                Primary_Language__c,
                Primary_Role__c,
                Title__c,
                Secondary_Role__c,
                First_Name_Local_Language__c,
                Last_Name_Local_Language__c
                FROM MPEContact__c
                WHERE Application__c =: applicationRecord.Id
            ]) {
            
            if(rolePersonaMapping != null && newPartnerAccount.Partner_Region__c == 'NA') {
                persona = rolePersonaMapping.containsKey(partnerCon.Primary_Role__c) ? rolePersonaMapping.get(partnerCon.Primary_Role__c) : '';
            }
            Contact cnt = new Contact(
                FirstName = partnerCon.First_Name__c,
                LastName = partnerCon.Last_Name__c,
                First_Name_Local_Language__c = partnerCon.First_Name_Local_Language__c,
                Last_Name_Local_Language__c = partnerCon.Last_Name_Local_Language__c,
                MobilePhone = partnerCon.Mobile__c,
                Phone = partnerCon.Phone__c,
                Email = partnerCon.Email__c,
                Preferred_Language__c = applicationRecord.Applicant_Primary_Language__c,
                AccountId = newPartnerAccount.Id,
                RecordTypeId = partContactRecordtypeId,
                Primary_Contact_Type__c = partnerCon.Primary_Role__c,
                Salutation = applicationRecord.Applicant_Salutation__c,
                MailingStreet = applicationRecord.Main_place_of_business_Address_1__c,
                MailingCity = applicationRecord.Main_place_of_business_Town_City__c,
                MailingState = applicationRecord.Applicant_State_Province__c,
                MailingCountry = applicationRecord.Main_place_of_business_Country__c,
                MailingPostalCode = applicationRecord.Main_place_of_business_Postal_Code__c,
                Persona__c = persona,
                Title = partnerCon.Title__c,
                Contact_Type__c = partnerCon.Secondary_Role__c,
                Status__c = 'Pending Onboarding',
                LDAP_Login__c = partnerCon.Email__c
            );
            partnerContacts.add(cnt);
        }

        partnerContacts.add(
            new Contact(
                AccountId = newPartnerAccount.Id,
                Email = applicationRecord.Applicant_Email_Address__c,
                Preferred_Language__c = applicationRecord.Applicant_Primary_Language__c,
                Primary_Contact_Type__c = applicationRecord.Applicant_Primary_Role__c,
                Phone = applicationRecord.Applicant_Phone_Number__c,
                MobilePhone = applicationRecord.Applicant_Mobile_Number__c,
                Title = applicationRecord.Applicant_Title__c,
                Contact_Type__c = applicationRecord.Applicant_Secondary_Role_s__c,
                FirstName = applicationRecord.Applicant_First_Name__c,
                LastName = applicationRecord.Applicant_Last_Name__c,
                RecordTypeId = partContactRecordtypeId,
                MailingStreet = applicationRecord.Main_place_of_business_Address_1__c,
                MailingCity = applicationRecord.Main_place_of_business_Town_City__c,
                MailingState = applicationRecord.Applicant_State_Province__c,
                MailingCountry = applicationRecord.Main_place_of_business_Country__c,
                MailingPostalCode = applicationRecord.Main_place_of_business_Postal_Code__c,
                Salutation = applicationRecord.Applicant_Salutation__c,
                Persona__c = newPartnerAccount.Partner_Region__c == 'NA'? 'Admin': '',
                Status__c = 'Pending Onboarding',
                LDAP_Login__c = applicationRecord.Applicant_Email_Address__c
            )
        );
        if (applicationRecord.Are_You_Authorized_to_Sign_Legal_Agmt__c != 'Yes') {
            if(newPartnerAccount.Partner_Region__c == 'NA'){
                if (String.isBlank(applicationRecord.Company_Signature_Authority_Primary_Role__c)) {
                    persona = 'SupportService';
                } else if (rolePersonaMapping != NULL && String.isNotBlank(applicationRecord.Company_Signature_Authority_Primary_Role__c)) {
                    persona = rolePersonaMapping.containskey(applicationRecord.Company_Signature_Authority_Primary_Role__c) ?
                            rolePersonaMapping.get(applicationRecord.Company_Signature_Authority_Primary_Role__c) : '';
                }
            } else {
                persona = '';
            }
            
            partnerContacts.add(
                new Contact(
                    AccountId = newPartnerAccount.Id,
                    Email = applicationRecord.Company_Signature_Authority_Email__c,
                    Preferred_Language__c = applicationRecord.Applicant_Primary_Language__c,
                    Primary_Contact_Type__c = applicationRecord.Company_Signature_Authority_Primary_Role__c,
                    Phone = applicationRecord.Company_Signature_Authority_Phone_Number__c,
                    MobilePhone = applicationRecord.Company_Signature_Authority_Mobile__c,
                    FirstName = applicationRecord.Company_Signature_Authority_First_Name__c,
                    LastName = applicationRecord.Company_Signature_Authority_Last_Name__c,
                    RecordTypeId = partContactRecordtypeId,
                    /* Title=applicationRecord.Applicant_Title__c ,Contact_Type__c =applicationRecord.Applicant_Secondary_Role_s__c,*/
                    MailingStreet = applicationRecord.Main_place_of_business_Address_1__c,
                    MailingCity = applicationRecord.Main_place_of_business_Town_City__c,
                    MailingState = applicationRecord.Main_place_of_business_State__c,
                    MailingCountry = applicationRecord.Main_place_of_business_Country__c,
                    MailingPostalCode = applicationRecord.Main_place_of_business_Postal_Code__c,
                    Salutation = applicationRecord.Applicant_Salutation__c,
                    Status__c = 'Pending Onboarding',
                    Persona__c = persona,
                    LDAP_Login__c = applicationRecord.Company_Signature_Authority_Email__c
                )
            );
        }
        system.debug('test list--' + partnerContacts);
        system.debug('test list--' + partnerContacts.size());
        if (!partnerContacts.isEmpty()) {
            insert partnerContacts;
        }
        //Database.insert(partnerContacts, false);
    }

    private static void populatePartnerLocation(Empower_Application__c applicationRecord, Account newPartnerAccount) {
        //if(!Test.isRunningTest()){
        Partner_Location__c partLoc = new Partner_Location__c(
            Account__c = newPartnerAccount.Id,
            Address_Line1__c = applicationRecord.Main_place_of_business_Address_1__c,
            Address_Type__c = 'Primary Location',
            City__c = applicationRecord.Main_place_of_business_Town_City__c,
            State__c = applicationRecord.Main_place_of_business_State__c,
            Country1__c = applicationRecord.Main_place_of_business_Country__c,
            Postal_code__c = applicationRecord.Main_place_of_business_Postal_Code__c,
            Phone__c = applicationRecord.Company_Phone_Number__c,
            Fax__c = applicationRecord.Primary_Location_Fax_Number__c
        );
        if (
            String.isNotBlank(applicationRecord.Main_place_of_business_Address_2__c)
        ) {
            partLoc.Address_Line2__c = applicationRecord.Main_place_of_business_Address_2__c;
        }
        if (!Test.isRunningTest()) {
            insert partLoc;
        }
    }
    private static Partner_Type__c populateProgramType(Empower_Application__c applicationRecord, Account newPartnerAccount) {
        Partner_Type__c programType = new Partner_Type__c(
            Account__c = newPartnerAccount.Id,
            Compliance_Status__c = 'Compliant',
            Program__c = 'RADIO',
            Status__c = 'Active',
            Partner_Track__c = 'Reseller'
        );
        if (newPartnerAccount.Partner_Region__c == 'LACR') {
            programType.Partner_Level__c = 'Registered';
        } else {
            programType.Partner_Level__c = 'Authorized Reseller';
        }
        if (
            applicationRecord.Partner_Community_Type__c.contains('Service Partner')
        ) {
            programType.Purchasing_Method__c = 'Tier 1';
        }
        if (
            applicationRecord.Partner_Region__c == 'APAC' ||
            applicationRecord.Partner_Region__c == 'LA' ||
            applicationRecord.Partner_Region__c == 'EMEA'
        ) {
            programType.Purchasing_Method__c = 'Tier 2';
        }
        if (
            applicationRecord.Partner_Community_Type__c.contains(
                'Federal Manufacturer Representative'
            )
        ) {
            programType.US_Federal__c = true;
        }
        Database.SaveResult sr = Database.insert(programType, false);
        if (sr.isSuccess()) {
            System.debug('Successfully inserted account. Account ID: ' + sr.getId());
            return programType;
        } else {
            return null;
        }
    }

    private static List<Technology_Specialization__c> populateProgramDetail(Empower_Application__c applicationRecord, Account newPartnerAccount, Partner_Type__c partnerType) {
        String newApplicationId = GlobalUtility.getRecordTypeIdByDeveloperName(
            'Addendum__c',
            'New_Application'
        );
        List<Technology_Specialization__c> programDetailToInsert = new List<Technology_Specialization__c> ();
        List<Addendum__c> addendumList = new List<Addendum__c> ();
        Map<String, List<String>> addendumMap = new Map<String, List<String>> ();
        Date reviewDate = Date.today().addYears(1);
        List<Empower_Application__c> empowerList = [
            SELECT
            Partner_Community_Type__c,
            Partner_Technology_Segment__c,
            (
                SELECT Partner_Community_Type__c,
                Technology_Segment__c,
                recordTypeId,
                Status__c FROM Addendums__r WHERE recordTypeId =: newApplicationId
            )
            FROM Empower_Application__c
            WHERE Id =: applicationRecord.Id
        ];
        //List<Partner_Type__c> partnerTypeList=[SELECT Account__c FROM Partner_Type__c WHERE Account__c=:newPartnerAccount.Id];

        for (Empower_Application__c empower: empowerList) {
            addendumList.addAll(empower.Addendums__r);
        }
        system.debug('all adm-->' + addendumList);

        if (addendumList.size()> 0) {
            List<String> allTechValues = new List<String> ();
            for (Addendum__c addendum: addendumList) {
                if (
                    addendum.Status__c == 'Accepted' &&
                    addendum.Technology_Segment__c != null
                ) {
                    if (addendumMap.containsKey(addendum.Partner_Community_Type__c)) {
                        List<String> seperateValues = new List<String> ();
                        List<String> techValues = addendumMap.get(
                            addendum.Partner_Community_Type__c
                        );
                        List<String> seperateTechSegment = addendum.Technology_Segment__c.split(
                            ';'
                        );
                        seperateValues.addAll(seperateTechSegment);
                        addendumMap.put(addendum.Partner_Community_Type__c, seperateValues);
                    } else {
                        List<String> seperateValues = new List<String> ();
                        List<String> seperateTechSegment = addendum.Technology_Segment__c.split(
                            ';'
                        );
                        seperateValues.addAll(seperateTechSegment);
                        addendumMap.put(addendum.Partner_Community_Type__c, seperateValues);
                    }
                }
            }
            if (!addendumMap.isEmpty()) {
                for (String addendumKey: addendumMap.keyset()) {
                    for (String techValue: addendumMap.get(addendumKey)) {
                        Technology_Specialization__c programDetail = new Technology_Specialization__c(
                            Partner_Program__c = partnerType.Id,
                            Account__c = newPartnerAccount.Id,
                            Authorized__c = true,
                            Community_Type__c = addendumKey,
                            Compliance_Review_Date__c = reviewDate,
                            Tech_Specialization_Compliant_Status__c = 'Compliant',
                            Partner_Category__c = 'Channel Partner',
                            Technology_Specialization_Level__c = 'Authorized'
                        );

                        if (applicationRecord.Partner_Region__c == 'NA') {
                            programDetail.Technology_Specialization_Level__c = 'Authorized';
                        } else {
                            programDetail.Technology_Specialization_Level__c = null;
                        }
                        if (applicationRecord.Partner_Region__c == 'EMEA') {
                            programDetail.Region__c = 'EMEA';
                            programDetail.Country__c = applicationRecord.Main_place_of_business_Country__c;
                        } else if (applicationRecord.Partner_Region__c == 'LA') {
                            programDetail.Region__c = 'LACR';
                            programDetail.Country__c = applicationRecord.Main_place_of_business_Country__c;
                        }
                        if (applicationRecord.Partner_Region__c == 'LA') {
                            programDetail.Type__c = 'Value Added Reseller';
                            programDetail.Technology_Specialization__c = techValue;
                        } else {
                            if (techValue.Contains('Application Partner')) {
                                programDetail.Type__c = 'Application';
                                programDetail.Technology_Specialization__c = techValue;
                            } else if (techValue.Contains('Service Partner')) {
                                programDetail.Type__c = 'Service Delivery';
                                programDetail.Technology_Specialization__c = null;
                            } else {
                                programDetail.Type__c = 'Technology';
                                programDetail.Technology_Specialization__c = techValue;
                            }
                        }

                        programDetail.Technology_Specialization_Status__c = 'Active';
                        //programDetail.Technology_Specialization__c=techValue;
                        programDetailToInsert.add(programDetail);
                    }
                }
            }
        } else if (addendumList.isEmpty()) {
            system.debug('inside all adm-->' + addendumList);
            List<String> technologySegList = applicationRecord.Partner_Technology_Segment__c.split(
                ';'
            );
            for (String techSegment: technologySegList) {
                Technology_Specialization__c programDetail = new Technology_Specialization__c(
                    Partner_Program__c = partnerType.Id,
                    Account__c = newPartnerAccount.Id,
                    Authorized__c = true,
                    Community_Type__c = applicationRecord.Partner_Community_Type__c,
                    Compliance_Review_Date__c = reviewDate,
                    Tech_Specialization_Compliant_Status__c = 'Compliant',
                    Partner_Category__c = 'Channel Partner'
                );
                if (applicationRecord.Partner_Region__c == 'LA') {
                    programDetail.Type__c = 'Value Added Reseller';
                    programDetail.Technology_Specialization__c = techSegment;
                } else {
                    if (
                        applicationRecord.Partner_Community_Type__c.Contains(
                            'Application Partner'
                        )
                    ) {
                        programDetail.Type__c = 'Application';
                        programDetail.Technology_Specialization__c = techSegment;
                    } else if (
                        applicationRecord.Partner_Community_Type__c.Contains(
                            'Service Partner'
                        )
                    ) {
                        programDetail.Type__c = 'Service Delivery';
                        programDetail.Technology_Specialization__c = null;
                    } else {
                        programDetail.Type__c = 'Technology';
                        programDetail.Technology_Specialization__c = techSegment;
                    }
                }
                if (applicationRecord.Partner_Region__c == 'NA') {
                    programDetail.Technology_Specialization_Level__c = 'Authorized';
                } else {
                    programDetail.Technology_Specialization_Level__c = null;
                }
                if (applicationRecord.Partner_Region__c == 'EMEA') {
                    programDetail.Region__c = 'EMEA';
                    programDetail.Country__c = applicationRecord.Main_place_of_business_Country__c;
                } else if (applicationRecord.Partner_Region__c == 'LA') {
                    programDetail.Region__c = 'LACR';
                    programDetail.Country__c = applicationRecord.Main_place_of_business_Country__c;
                }
                programDetail.Technology_Specialization_Status__c = 'Active';

                programDetailToInsert.add(programDetail);
                system.debug('test programs-->' + programDetailToInsert);
            }
        }

        Database.SaveResult[] insertResults = Database.insert(
            programDetailToInsert,
            false
        );
        for (Database.SaveResult sr: insertResults) {
            if (sr.isSuccess()) {
                System.debug('Successfully inserted Program Detail: ' + sr.getId());
                return programDetailToInsert;
            } else {
                system.debug('in else why');
                return null;
            }
        }
        return null;
    }

    private static Industry__c populateIndustry(Empower_Application__c applicationRecord, Account newPartnerAccount) {
        if (applicationRecord.Primary_Supervertical__c != null) {
            Industry__c industry = new Industry__c(
                Industry_Type__c = applicationRecord.Primary_Supervertical__c,
                Account__c = newPartnerAccount.Id
            );
            Database.SaveResult sr = Database.insert(industry, false);
            if (sr.isSuccess()) {
                System.debug(
                    'Successfully inserted account. Account ID: ' + sr.getId()
                );
                return industry;
            } else {
                return null;
            }
        }
        return null;
    }

    private static List<Product_Offered__c> populateProductLines(Empower_Application__c applicationRecord, Account newPartnerAccount) {
        List<Product_Offered__c> productToUpdate = new List<Product_Offered__c> ();
        if (!String.isBlank(applicationRecord.Partner_Technology_Segment__c)) {
            Set<String> setTechProducts = new Set<String> (
                applicationRecord.Partner_Technology_Segment__c.split(';')
            );
            for (String tech: setTechProducts) {
                Product_Offered__c product = new Product_Offered__c(
                    Product_offering__c = tech,
                    Account__c = newPartnerAccount.Id
                );
                productToUpdate.add(product);
            }
        }
        Database.SaveResult[] insertResults = Database.insert(
            productToUpdate,
            false
        );
        for (Database.SaveResult sr: insertResults) {
            if (sr.isSuccess()) {
                System.debug('Successfully inserted Program Detail: ' + sr.getId());
                return productToUpdate;
            } else {
                return null;
            }
        }
        return null;
    }
    public static void linkSignedAdobeAgreementToAccount(String accountId, String applnId) {
        List<echosign_dev1__SIGN_Agreement__c> lstAgreement = [
            SELECT Id
            FROM echosign_dev1__SIGN_Agreement__c
            WHERE
            PartnerEmpower_Application__c =: applnId
            AND echosign_dev1__Status__c = 'Signed'
        ];
        if (!lstAgreement.isEmpty()) {
            for (echosign_dev1__SIGN_Agreement__c aggr: lstAgreement) {
                aggr.echosign_dev1__Account__c = accountId;
            }
            update lstAgreement;
        }
    }

    private static Map<String, String> getRolePersona_Mapping() {
        Map<String, String> mapping = new Map<String, String> ();

        for(MR_Digitization_Settings__mdt metaData : [
            SELECT Id, Label, Values__c
            FROM MR_Digitization_Settings__mdt
            WHERE Category__c = 'DTSFPART'
        ]) {
            mapping.PUT(metaData.Label, metaData.Values__c);
        }
        return mapping;
    }
}