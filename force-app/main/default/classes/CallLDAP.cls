global class CallLDAP {
    
    public static integer updateContact=0;
    public static Contact currContact;
    public static boolean isTest = false;
    public static integer testidCount=0;
    global static ID lastBatch;
    
    public  void queryBatch(List<Id> input) {
        List<Contact> toUpdate=[select id, ldap_batch__c from contact where id in:input];
        for (Contact c : toUpdate){
            c.ldap_batch__c='Q';
        }
        List<LDAP_Log__c> newLogs = new List<LDAP_Log__c>();
        for (Id c : input){
            LDAP_Log__c l = new LDAP_Log__c(Contact__c=c, Event__c='Query/update request submitted.',Success__c='R');
            newLogs.add(l); 
        }
        insert newLogs;
        update toUpdate;
    }
    
    public  void updateBatch(List<Id> input) {
        List<Contact> toUpdate=[select id, ldap_batch__c from contact where id in:input];
        
        for (Contact c : toUpdate){
            c.ldap_batch__c='U';    
        }
        List<LDAP_Log__c> newLogs = new List<LDAP_Log__c>();
        for (Id c : input){
            LDAP_Log__c l = new LDAP_Log__c(Contact__c=c, Event__c='Update request submitted.',Success__c='R');
            newLogs.add(l); 
        }
        insert newLogs;
        Database.update(toUpdate,false);
    }
    
    // Method to create webservice calls based on changes to user record - called from User trigger
    public void changeUser(Id input,String op) {
        userCall(input, op);  //Call method to create and send webservice call - op parameter indicates whether user is being promoted or demoted
        if (Test.isRunningTest()){
            System.Debug('Batch submitted via test method');
            System.Debug('Test run OK');
        }
    }
    
    @future(callout=true)
    public static void userCall(Id input, String op) {
        String userSoapXML;
        
        Integer idCount=0;
        currContact = [SELECT email, ldap_login__c from Contact where Id=:input LIMIT 1];
        ldapContact thisContact = new ldapContact(input);
        ldapCallout userCallout = new ldapCallout();
        HttpRequest userReq = userCallout.getLdapCallout();
        String SOAPHeader = userReq.getBody();
        if (op=='A'){
            userSoapXML = SOAPHeader + thisContact.getUserEnable();  // Retrieve user enable post body from ldapContact class
        }else if (op=='Admin'){
            userSoapXML = SOAPHeader + thisContact.getAdminUserEnable();  // Retrieve user enable post body from ldapContact class  
        }else{
            userSoapXML = SOAPHeader + thisContact.getUserDisable();  // Retrieve user disable post body from ldapContact class
        } 
        userReq.setBody(userSoapXML);
        Integer uContentLength=userSoapXML.length();
        userReq.setHeader('Content-Length',uContentLength.format());
        Http uh = new Http();
        HttpResponse ures = new HttpResponse();
        try{
            if (isTest==false){
                ures = uh.send(userReq);
            }
            
        }catch(System.Exception e){
            if (e.getMessage().contains('timed out')){
                ures=NULL;
                idCount=-1;
            }else{
                ures=NULL;
                idCount=-1;
            }
        }
    }
}