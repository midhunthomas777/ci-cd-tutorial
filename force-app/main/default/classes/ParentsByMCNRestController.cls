@RestResource(urlMapping = '/ParentAccountMCNRestService/v1/*')
global without sharing class ParentsByMCNRestController {
    
    global class MCNWrapper {
        public String mcn;
    }
    global class PersonWrapper {
        public String email;
    }    
    global class CreateCaseWrapperRequest {
        public String mcn;
        public String ldap;
        public String techSiteId;
    }    
    global class CreateCaseWrapperResponse {
        public String mcn;
        public String AccountId;
        public String LDAP_Login;
        public String ContactId;
        public String Technical_Site;
        public String RecordTypeId;
        public String status;
        public CreateCaseWrapperResponse(){}
        public CreateCaseWrapperResponse(String mcn, String AccountId, String RecordTypeId, String status) {
            this.mcn = mcn;this.AccountId = AccountId;this.RecordTypeId = RecordTypeId;this.status = status;
        }       
    } 
    
    @HttpPost
    global static List<CreateCaseWrapperResponse> getParentssByMCNs(List<MCNWrapper> MCNs, List<CreateCaseWrapperRequest> createCases, PersonWrapper personAccount) {
        ID partnerRecordId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('MPE_Partner_Contact').getRecordTypeId();
        ID customerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('EMS_Standard_Contact').getRecordTypeId();
        List<CreateCaseWrapperResponse> wrappersToBeReturned = new List<CreateCaseWrapperResponse>();
        try {
            if(MCNs != NULL && !MCNs.isEmpty()) {
                List<String> MCNSet = new List<String>();
                for(MCNWrapper wrapper : MCNs) {
                    MCNSet.add(wrapper.mcn);
                }
                Map<String, Account> mcnMap = fetchMcnMap(MCNSet);
                for(MCNWrapper mcnIncoming : MCNs) {
                    CreateCaseWrapperResponse wrapper = new CreateCaseWrapperResponse();
                    Account parentAccount = mcnMap.get(mcnIncoming.mcn);
                    if(parentAccount != NULL) {
                        wrapper.mcn = mcnIncoming.mcn;
                        wrapper.AccountId = parentAccount.Id;
                        wrapper.status = 'SUCCESS';
                    } else {
                        wrapper.mcn = mcnIncoming.mcn;
                        wrapper.status = 'ERROR';
                    }
                    wrappersToBeReturned.add(wrapper);
                }
            } else if(createCases != NULL && !createCases.isEmpty()) {
                Set<String> ldaps = new Set<String>();
                List<String> MCNsList = new List<String>();
                Set<String> techSites = new Set<String>();
                for(CreateCaseWrapperRequest createCase : createCases) {
                    if(String.isNotEmpty(createCase.mcn)) MCNsList.add(createCase.mcn);
                    if(String.isNotEmpty(createCase.ldap)) ldaps.add(createCase.ldap);
                    if(String.isNotEmpty(createCase.techSiteId)) techSites.add(createCase.techSiteId);
                }
                Map<String,Account> mcnMap = fetchMcnMap(MCNsList);
                system.debug('######mcnMap##### => ' + mcnMap);
                Map<String, List<Contact>> conMap = new Map<String, List<Contact>>();
                Map<String, Technical_Site__c> techSiteMap = new Map<String, Technical_Site__c>();
                for(Contact con : [Select Id,LDAP_Login__c,AccountId from Contact where LDAP_Login__c IN : ldaps]) { //change to fetch contacts which are associated with the Account
                    if(conMap.get(con.LDAP_Login__c) != NULL) {
                        List<Contact> conList = conMap.get(con.LDAP_Login__c);
                        conList.add(con);
                        conMap.put(con.LDAP_Login__c, conList);
                    } else {
                        List<Contact> conList = new List<Contact>();
                        conList.add(con);
                        conMap.put(con.LDAP_Login__c, conList);
                    }
                }
                system.debug('######conMap##### => ' + conMap);
                for(Technical_Site__c techSite : [Select Id,Site_ID__c from Technical_Site__c where Site_ID__c IN : techSites]) {
                    techSiteMap.put(techSite.Site_ID__c, techSite);
                }
                for(CreateCaseWrapperRequest createCase : createCases) {
                    system.debug('######conMapcreateCase => ' + createCase);
                    CreateCaseWrapperResponse wrapper = new CreateCaseWrapperResponse();
                    List<Contact> conDB = conMap.get(createCase.ldap);
                    Account accDB = mcnMap.get(createCase.mcn);
                    system.debug('######accDB => ' + accDB);
                    if(conDB != NULL && !conDB.isEmpty()) {
                        if(conDB.size() == 1) {
                            wrapper.ContactId = conDB[0].Id;
                            wrapper.AccountId = conDB[0].AccountId;
                        } else if(conDB.size() > 1 && accDB != NULL){
                            wrapper.AccountId = accDB.Id;
                            for(Contact conToBeMapped : conDB) {
                                if(conToBeMapped.AccountId == accDB.Id) {
                                    wrapper.ContactId = conToBeMapped.Id;
                                    break;
                                }
                            }
                        }
                        wrapper.status = 'SUCCESS';
                    }
                    system.debug('######wrapper##### => ' + wrapper);
                    if(String.isEmpty(wrapper.AccountId) && accDB != NULL) {
                        wrapper.AccountId = accDB.Id;
                        wrapper.status = 'SUCCESS';
                        if(accDB.RecordType.DeveloperName == 'SoldToAccount') {
                            wrapper.RecordTypeId = customerRecordTypeId;    
                        } else if (accDB.RecordType.DeveloperName == 'Partner') {
                            wrapper.RecordTypeId = partnerRecordId;
                        }
                    }
                    Technical_Site__c techSiteDB = techSiteMap.get(createCase.techSiteId);
                    if(techSiteDB != NULL) {
                        wrapper.Technical_Site = techSiteDB.Id;
                        wrapper.status = 'SUCCESS';
                    }
                    if(wrapper.status != 'SUCCESS') {
                        wrapper.status = 'ERROR';
                    }
                    wrapper.mcn = createCase.mcn;
                    wrapper.LDAP_Login = createCase.ldap;
                    wrappersToBeReturned.add(wrapper);
                }
            } else if (personAccount != NULL) {
                CreateCaseWrapperResponse wrapper = new CreateCaseWrapperResponse();
                List<Account> personAccounts = [Select Id,PersonContactId from Account where PersonEmail =: personAccount.email and RecordType.DeveloperName  = 'Internal' LIMIT 1];
                if(!personAccounts.isEmpty()) {
                    wrapper.AccountId = personAccounts.get(0).Id;
                    wrapper.ContactId = personAccounts.get(0).PersonContactId;
                    wrapper.status = 'SUCCESS';
                } else {
                    wrapper.status = 'ERROR';
                    wrapper.LDAP_Login = personAccount.email;
                }
                wrappersToBeReturned.add(wrapper);
            }
        } catch (Exception Ex) {
            CreateCaseWrapperResponse wrapper = new CreateCaseWrapperResponse();
            wrapper.status = 'ERROR';
            wrappersToBeReturned.add(wrapper);
        }
        return wrappersToBeReturned; 
    }
    
    private static Map<String, Account> fetchMcnMap(List<String> MCNSet) {
        Map<String, Account> wrappers = new Map<String, Account>();
        //Map<String, Account> foundPartners = new Map<String, Account>();
        Map<String, Account> foundcust = new Map<String, Account>();
        for(Account acc : [Select Id,Motorola_Customer_Number__c,ParentId,Parent.RecordType.DeveloperName from Account where RecordType.DeveloperName = 'Motorola_Customer_Number' AND Motorola_Customer_Number__c IN : MCNSet]) {
            foundcust.put(acc.Motorola_Customer_Number__c, acc.Parent);
        }
        for(Integer j = 0; j < MCNSet.size(); j++){
            if(foundcust.get(MCNSet[j]) != null){
                wrappers.put(MCNSet[j], foundcust.get(MCNSet[j]));
                MCNSet.remove(j);
            }
        }
        for(Account PI : [Select Id,Motorola_Customer_Number__c,Motorola_Enterprise_ID__c,RecordType.DeveloperName from Account where Motorola_Customer_Number__c IN : MCNSet AND RecordType.DeveloperName = 'Partner']) {
            wrappers.put(PI.Motorola_Enterprise_ID__c, PI);
        }
        for(Partner_Identifier__c PI : [Select ID_Number__c,Account__c,Account__r.RecordType.DeveloperName from Partner_Identifier__c where ID_Number__c IN : MCNSet]) {
            wrappers.put(PI.ID_Number__c, PI.Account__r);
        }
        
        /* for(Integer j = 0; j < MCNSet.size(); j++){
        if(foundPartners.get(MCNSet[j]) != null){
          wrappers.put(MCNSet[j], foundPartners.get(MCNSet[j]));  
          MCNSet.remove(j);
        }
      }      
      for(Account acc : [Select Id,Motorola_Customer_Number__c,ParentId,Parent.RecordType.DeveloperName from Account where RecordType.DeveloperName = 'Motorola_Customer_Number' AND Motorola_Customer_Number__c IN : MCNSet]) {
        wrappers.put(acc.Motorola_Customer_Number__c, acc.Parent);
      }*/
        return wrappers;
    }
}