/*  
* File Name     : ADPOIMCreateGroupInvokeClass
* Description   : This class is called from the Process Builder to invoke the OIM REST callout for creating a group 
*                 when a new Global account Name is created in the 'ADP Global Account Names' Object.
*                 The response obtained from the call will be a group id which will be updated in the created Global account record.
* Modification Log
* =============================================================================
*   Ver     Date         Author                      Modification
*------------------------------------------------------------------------------
*   1.0     18-Oct-16    Poongodi V                  Initial Creation
*   2.0     19-Dec-16    Poongodi V                  Invocable and Future method. Changes made for Json and Endppoint URL
*/
public class ADPOIMCreateGroupInvokeClass{
    @InvocableMethod(label='Create Group OIM call' description='Invoke OIM call when a new Global name is inserted')
     public static void InsertRecord(List<Id> GlobalAccountRecId)
    {
     system.debug('In InsertRecord '+GlobalAccountRecId);
     List<ADP_Global_Account_Name__c> GlobalAcc= [Select Id,Name,GitLab_Group_Id__c,CreatedBy.Name,CreatedBy.Email from ADP_Global_Account_Name__c where Id = :GlobalAccountRecId];
     system.debug('#####GlobalAcc[0]:'+GlobalAcc[0]);
         If(GlobalAcc.size() == 0)
        {
            system.debug('No Global Account Name found');
            return;
        }
        String GlobalAccName = GlobalAcc[0].Name;
        Id GlobalAccRecId = GlobalAcc[0].Id;
        if(String.isblank(String.Valueof(GlobalAcc[0].GitLab_Group_Id__c))==true){
        callCreateGroup(GlobalAccName,GlobalAccRecId);
        }
    }
        
//Future callout method which makes API call to fetch group id
        @future(callout=true)
        public static void callCreateGroup(String GlobalAccName,Id GlobalAccRecId) {
        
    //Class instance to send mail in case of failure
        ADPSendMailClass Dup=new ADPSendMailClass(); 
        
    //List of mail recipients
        string[] useremail = new List<String>();
        ADP_OIM_Settings__c CG = ADP_OIM_Settings__c.getvalues('cgCurrent');
        String emailToAddress =CG.emailToAddress__c;       
        useremail= emailToAddress.split(',');

    //Http protocol
        Http httpProtocol = new Http();
        HttpResponse response = new HttpResponse(); 
        HttpRequest request = new HttpRequest(); 
                       
    //Frame the body of request
        string inputGlobalName= 'dev-'+GlobalAccName; 
                  
         Map <String, String> jsonMap = new Map <String, String> ();
            jsonmap.put('visibility', 'private'); // 20th Sep 2017- Added by Harish as per the request from Amol
            jsonmap.put('visibility_level', '10');
            jsonmap.put('description', '< companyname> - <registeredaddress>');  // Modified to include Partner Address instead of 'OK'
            jsonmap.put('path', inputGlobalName);
            jsonmap.put('name',inputGlobalName);  
        
        String strbody = JSON.serialize(jsonMap);
        system.debug('#####in request.setBody :' +strbody);
              
        Blob headerValue = Blob.valueOf(CG.username__c+':'+CG.password__c);
        System.Debug('headerValue###'+headerValue);
        String authorizationHeader = CG.authorizationType__c +' ' +EncodingUtil.base64Encode(headerValue);
        System.Debug('authorizationHeader ###'+authorizationHeader);        
    //Frame the Http Request      
        request.setMethod(CG.method__c);        
        request.setHeader('Authorization', authorizationHeader);        
        request.setHeader('Content-type',CG.contentHeader__c);        
        request.setTimeout(50000);        
        request.setEndPoint(CG.EndPoint__c);    
        request.setBody(strbody);


        try{
            response = httpProtocol.send(request);
        }catch(System.calloutException e){  
             System.debug('#####Callout Exception: '+e+' , response.toString(): '+response.toString());          
             String responseMessageException= '\nresponse.getStatusCode(): '+response.getStatusCode()+ '\nresponse.getStatus(): '+response.getStatus()+'\nresponse.getBody(): '+response.getBody();

    //Send mail in case of exception
             String emailcontentbody='Dear Team,\nADP Create Group API HttpCallout is failed. It threw Exception:\n'+e+'\nPlease work with OAG/OSB team to fix the issue.\nDetails:\n'+responseMessageException;
             String subject = 'Unable to create ADP Global Name '+GlobalAccName+' group in GITLab';
             Dup.sendEmail(emailcontentbody,useremail,subject);
            
        
        }
            String responseMessage= 'response.getStatusCode(): '+response.getStatusCode()+ '\nresponse.getStatus(): '+response.getStatus()+'\nresponse.getBody(): '+response.getBody();
            String responsebody=response.getBody();
            System.debug('#####'+responseMessage);
            integer responsestatuscode= response.getStatusCode();

            if(responsestatuscode == 200 && responsebody.containsIgnoreCase('FAIL')== false && responsebody.containsIgnoreCase('ERROR')==false){
            
    //Deserialize the Http response
                if(!String.isEmpty(responsebody)) {
                Map<String,Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responsebody);
                Integer intrspid= (Integer)responseMap.get('id');
                system.debug('#####GIT Group Id Created is '+intrspid );
                
                List<ADPOIMCreateGroupJsonClass> DisplayList = new List<ADPOIMCreateGroupJsonClass>(); 
                ADPOIMCreateGroupJsonClass GP=new ADPOIMCreateGroupJsonClass ();   
                GP.id=intrspid;  
                DisplayList.add(GP);
                                
    //Update the fetched Group id in the ADP Globalaccount name record
                ADP_Global_Account_Name__c a = [SELECT Id,GitLab_Group_Id__c  FROM ADP_Global_Account_Name__c WHERE Id = :GlobalAccRecId];
                a.GitLab_Group_Id__c= DisplayList[0].id;
                    update a; } 
            }else{
            
    //Send mail in case of error response   
             String emailcontentbody='Dear Team,\nADP Create Group API HttpCallout is failed.\nPlease work with OAG/OSB team to fix the issue.\nDetails:\n'+responseMessage;        
             String subject = 'Unable to create ADP Global Name '+GlobalAccName+' group in GITLab';
             Dup.sendEmail(emailcontentbody,useremail,subject);
           
            } 
        }
        
    //Deserializing Method
        public static ADPOIMCreateGroupJsonClass ParserMethodCreateGroup(String json){
            return (ADPOIMCreateGroupJsonClass) System.JSON.deserialize(json, ADPOIMCreateGroupJsonClass .class);
        } 
        
    //Class to hold the attribute in JSON response after deserialization
        public class ADPOIMCreateGroupJsonClass{
            public Integer id; 
        }
        
    }