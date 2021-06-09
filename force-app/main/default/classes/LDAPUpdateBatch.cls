global class LDAPUpdateBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {
    
    global Set<Id> contactIds;
    global Boolean updateLDAPStatusToActive;
    List<LDAP_Log__c> ldapLogsToBeInserted = new List<LDAP_Log__c>();
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('Select Id,LDAP_Login__c from Contact WHERE Id IN : contactIds AND LDAP_Login__c!=null');    
    }
    
    global void execute(Database.BatchableContext BC,  List<Contact> scope){
        List<Integration_Framework__mdt> ldapUpdateMetaData = new List<Integration_Framework__mdt>();
        if(GlobalUtility.runningInASandbox()) {
            ldapUpdateMetaData = [SELECT DeveloperName,Basic_Authentication__c,ClientID__c,ClientSecret__c,Timeout__c,Endpoint_URL__c,OAuthToken_URL__c
                                  FROM Integration_Framework__mdt where Instance__c='Sandbox' and label='LDAPUpdateStatus' limit 1];
        }else{
            ldapUpdateMetaData = [SELECT DeveloperName,Basic_Authentication__c,ClientID__c,ClientSecret__c,Timeout__c,Endpoint_URL__c,OAuthToken_URL__c
                                  FROM Integration_Framework__mdt where Instance__c='Production' and label='LDAPUpdateStatus' limit 1];
        }
        
        System.debug('ldapUpdateMetaData##'+ldapUpdateMetaData);
        System.debug('updateLDAPStatusToActive##'+updateLDAPStatusToActive);
        System.debug('contactIds##'+contactIds);
        String body;
        String accessToken;
        Http httpLDAPUpdate = new Http();
        HttpRequest reqLDAPUpdate = new HttpRequest();
        for(Contact updatedCon:scope){
            body = null;
            if(updateLDAPStatusToActive){
                body = '{"UserID": "'+updatedCon.LDAP_Login__c+'","AccountStatus":"A"}';
            }else{
                body = '{"UserID": "'+updatedCon.LDAP_Login__c+'","AccountStatus":"I"}';
            } 
            accessToken = '';
            if(!ldapUpdateMetaData.isEmpty()){
                accessToken = generateLDAPOAuthToken(ldapUpdateMetaData);
            }
            if(String.isNotBlank(accessToken)){
                httpLDAPUpdate = new Http();
                reqLDAPUpdate = new HttpRequest();
                reqLDAPUpdate.setHeader('Authorization', 'Bearer '+accessToken);
                reqLDAPUpdate.setHeader('Content-Type', 'application/json');
                reqLDAPUpdate.setMethod('PUT');
                reqLDAPUpdate.setEndpoint(ldapUpdateMetaData[0].Endpoint_URL__c);
                reqLDAPUpdate.setBody(body);
                reqLDAPUpdate.setTimeout(Integer.valueOf(ldapUpdateMetaData[0].Timeout__c));//create metadata for timeout vlaue
                try{
                    HttpResponse res = httpLDAPUpdate.send(reqLDAPUpdate);//Try catch block required
                    System.debug('res.getBody()##'+res.getBody());                
                    LDAP_Log__c ldapLog = new LDAP_Log__c(Contact__c=updatedCon.Id, 
                                                          Event__c= 'Status Code ##'+res.getStatusCode()+'\n'+
                                                          'Status ##'+res.getBody(),
                                                          Success__c='S');
                    ldapLogsToBeInserted.add(ldapLog);
                }catch(Exception e){
                    System.debug('Exception in ldap update ##=>'+e);
                }
            }
        }
    }
    
    //IN FINISH METHOD UPDATING ATTRIBUTE ON CONTACT TO IDENTIFY STATUS OF PARTNER USER
    global void finish(Database.BatchableContext BC){
        Map<Id,Id> contactUserMap = new Map<Id,Id>();
        List<Contact> toBeUpdated = new List<Contact>();        
        for(User updatedUsr:[SELECT Id,ContactId FROM User WHERE ContactId IN:contactIds and ContactId!=null]){
            contactUserMap.put(updatedUsr.ContactId,updatedUsr.Id);
        }        
        for(Id updatedContactId:contactIds){
            if(contactUserMap.containsKey(updatedContactId)){
                toBeUpdated.add(new Contact(Id = updatedContactId,User__c = contactUserMap.get(updatedContactId)));
            }
        }
        try{
            if(!ldapLogsToBeInserted.isEmpty()){
                insert ldapLogsToBeInserted;
            }
            if(!toBeUpdated.isEmpty()){
                update toBeUpdated;
            }
        }catch(Exception e){
            System.debug('Exception in updating/inserting contacts and logs##=>'+e);
        }
    }
    
    /*** Generation of OAuth Token***/  
    public string generateLDAPOAuthToken(List<Integration_Framework__mdt> ldapUpdateMetaData){
        if(!ldapUpdateMetaData.isEmpty()){
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setHeader('Accept', 'application/json'); 
            req.setEndpoint(ldapUpdateMetaData[0].OAuthToken_URL__c+'?grant_type=client_credentials&client_id='+ldapUpdateMetaData[0].ClientID__c+'&client_secret='+ldapUpdateMetaData[0].ClientSecret__c);
           try{
                HttpResponse res = h.send(req);
                System.debug('res.getBody()##'+res.getBody());
                if(res.getStatusCode() == 200){
                    Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                    System.debug('responseMap##'+responseMap);
                    return responseMap.get('access_token').toString();
                }else{
                    return '';
                }
            } catch(exception e) {
                System.debug('Exception in receiving token##=>'+e);
                return '';
            }
        }else{
            System.debug('Error retreiving Metada for LDAP in Integration_Framework__mdt');
            return '';
        }
    }
}