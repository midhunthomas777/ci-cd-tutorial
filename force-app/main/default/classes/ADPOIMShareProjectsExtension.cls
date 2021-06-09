/*  
* File Name     : ADPOIMShareProjectsExtension
* Description   : This class is used for settting the checkbox(createcontact) to true to trigger contact creation and make the future call out to Share Project.
*                   This share project API call can be invoked only once.
* Modification Log
* =============================================================================
*   Ver     Date         Author                      Modification
*------------------------------------------------------------------------------
*   1.0     23-Dec-16   Poongodi V               Initial Creation 
*/

Public class ADPOIMShareProjectsExtension{
Public final Apttus__APTS_Agreement__c Agmt1;
Public final Account PartnerAcc;
Public Apttus__APTS_Agreement__c Agmt{get;set;}
Public String ErrorException='';
Public String ErrorStatus='';


    public ADPOIMShareProjectsExtension(ApexPages.StandardController stdController) {
        Agmt1= (Apttus__APTS_Agreement__c)stdController.getRecord();
        
        Agmt=[Select id,Create_Contact__c,Apttus__Contract_End_Date__c,ADP_Technology__c,ADP_Application__c,Apttus__Account__r.ADP_Global_Account_Name1__r.GitLab_Group_Id__c,Apttus__Account__r.ADP_Global_Account_Name1__r.Name  from Apttus__APTS_Agreement__c where Id=:this.Agmt1.Id];           
        PartnerAcc=[Select Id,Name,ADP_Technology_Segment__c,ADP_Partner__c from Account where Id=:Agmt.Apttus__Account__c limit 1];    
    }
    
    public PageReference enableCreateContact(){
        String addprojid; 
        List<String> ListGITGroupId = new List<String>();
        String AgmtId= String.valueof(Agmt.id); 
        system.debug('PartnerAcc.ID:'+PartnerAcc.Id+'Agmt:'+AgmtId);
        String GlobalGroupId= String.valueof(Agmt.Apttus__Account__r.ADP_Global_Account_Name1__r.GitLab_Group_Id__c)  ; 
        String GlobalGroupName= Agmt.Apttus__Account__r.ADP_Global_Account_Name1__r.Name  ;   
        String AgmtEnddate= String.valueof(Agmt.Apttus__Contract_End_Date__c);
        List<ADP_GITLAB_Project__c> ListGITGroup= [SELECT GIT_Project_ID__c From ADP_GITLAB_Project__c where Agreement_ADP__c=:Agmt.id];
        
        if(ListGITGroup.size()>0){
            for(ADP_GITLAB_Project__c t: ListGITGroup){
            addprojid= String.valueof(t.GIT_Project_ID__c );
            ListGITGroupId.add(addprojid);
           }
        }
          
        System.debug('#####GlobalGroupName: '+GlobalGroupName+', GlobalGroupId: '+GlobalGroupId+', AgmtEnddate:'+AgmtEnddate+' , ListGITGroupId: '+ListGITGroupId);
        if(GlobalGroupId=='' || GlobalGroupId== null){
           Agmt.adderror('No GitLab groupId exists for this ADP Global Account Name. Please check it and retry');
        }else if(ListGITGroup.size()==0){
           Agmt.adderror('No Gitlab Projects selected. Please add the GitLab Projects using Manage GitLab Projects Button and try Provisioning');
        }else if(AgmtEnddate=='' || AgmtEnddate== null){
           Agmt.adderror('No Agreement End date. Please update it');
        }else{
              if(Agmt.Create_Contact__c == false)
              try{
                    //Add ADP technology update 
                    if(PartnerAcc.ADP_Technology_Segment__c=='' || PartnerAcc.ADP_Technology_Segment__c==null){
                        PartnerAcc.ADP_Technology_Segment__c =Agmt.ADP_Technology__c;
                    }else{            
                        if(PartnerAcc.ADP_Technology_Segment__c.contains(Agmt.ADP_Technology__c) == false)
                        PartnerAcc.ADP_Technology_Segment__c = PartnerAcc.ADP_Technology_Segment__c + ';' + Agmt.ADP_Technology__c;
                    }
                    //Update ADP Partner Flag
                    if(PartnerAcc.ADP_Partner__c==false)
                        PartnerAcc.ADP_Partner__c=true;
                        
                    update PartnerAcc;
                    
                    //creation of the Program Information and detail( if not available) for the account
                   Partner_Type__c[] ProgInfo1=[Select Id from Partner_Type__c where Account__c=:Agmt.Apttus__Account__c and Status__c=:'Active'  and Program__c=:'RADIO' limit 1];
                   if(ProgInfo1.size()==0){
                        Partner_Type__c ProgInfo=new Partner_Type__c();
                        ProgInfo.Account__c=Agmt.Apttus__Account__c;
                        ProgInfo.Status__c='Active';
                        ProgInfo.Program__c='RADIO';
                        Insert ProgInfo;
                        
                        Technology_Specialization__c TechSeg=new Technology_Specialization__c();
                        TechSeg.Partner_Program__c=ProgInfo.Id;
                        TechSeg.Partner_Category__c=Label.ADPFDProgDetPartnerCategory; //'Application Developer'
                        TechSeg.Community_Type__c=Label.ADPFDProgDetCommunityType; //'Application Developer'
                        TechSeg.Type__c=Label.ADPFDProgDetType; //'Application'
                        TechSeg.Technology_Specialization__c=Agmt.ADP_Technology__c;
                        TechSeg.Account__c=Agmt.Apttus__Account__c;
                        Insert TechSeg;
                    }else{
                        Technology_Specialization__c[] TechInfo1=[Select Id,Technology_Specialization__c from Technology_Specialization__c where Partner_Program__c=:ProgInfo1[0].Id and Community_Type__c=:Label.ADPFDProgDetCommunityType and Technology_Specialization__c=:Agmt.ADP_Technology__c limit 1]; 
                        system.debug('#####TechInfo1:'+TechInfo1);
                        if(TechInfo1.size()==0 || (TechInfo1[0].Technology_Specialization__c != Agmt.ADP_Technology__c)){
                            Technology_Specialization__c TechSeg=new Technology_Specialization__c();
                            TechSeg.Partner_Program__c=ProgInfo1[0].Id;
                            TechSeg.Partner_Category__c=Label.ADPFDProgDetPartnerCategory; //'Application Developer'
                            TechSeg.Community_Type__c=Label.ADPFDProgDetCommunityType; //'Application Developer'
                            TechSeg.Type__c=Label.ADPFDProgDetType; //'Application'
                            TechSeg.Account__c=Agmt.Apttus__Account__c;
                            TechSeg.Technology_Specialization__c=Agmt.ADP_Technology__c;
                            Insert TechSeg;
                       }
                    }
        
    //Enable the Create contact checkbox
                   Agmt.Create_Contact__c = true;
                   update Agmt;
           
    //Make future callout to Share Project
                   callShareProject(ListGITGroupId,GlobalGroupId,AgmtEnddate,GlobalGroupName,AgmtId);
                   Pagereference p =new Pagereference('/'+Agmt.id);
                   return p;
               }catch (Exception e) { 
                    Agmt.adderror('There are errors in the Agreement record. Please correct them before proceeding further.');
                    ApexPages.addmessages(e);    
                    PageReference p= ApexPages.currentPage();    
                    return p;
               }
        }
       return null;
    }
     
        @future(callout=true)
        public static void callShareProject(List<String> GITGroups, String GlobalGrpId, String AgmtEnddate, String GlobalGroupName, String AgmtId) {
        
    //Class Instance to send mail
        ADPSendMailClass Dup=new ADPSendMailClass();
        
    //Frame the Http Callout Request
        string[] useremail = new List<String>();
        ADP_OIM_Settings__c CG = ADP_OIM_Settings__c.getvalues('spCurrent');
        String emailToAddress =CG.emailToAddress__c;       
        useremail= emailToAddress.split(',');
            
        Http httpProtocol = new Http();
        HttpResponse response = new HttpResponse(); 
        HttpRequest request= new HttpRequest();  
        
    //Frame the body of the request    
        List<String> GITGroupsNew = new List<String>();
        string reqGrpAccess ='20'; // 20th Sep 2017 - Modified by Harish from 30 to 20 as per the request from Amol
    
        String strbody= '{"count":"'+GITGroups.size()+'","gitLabProjectIds":["';
           for (String gpid: GITGroups) {
                strbody = strbody+gpid+'","';
             }
        strbody = strbody.substring(0,strbody.length()-2);
        strbody = strbody+'],"expires_at":"'+AgmtEnddate+'","group_id":"'+GlobalGrpId+'","group_access":"'+reqGrpAccess+'"}'; 
        system.debug('#####strbody is'+strbody );
        
           
    //Frame the Http Request
        ADP_OIM_Settings__c CS = ADP_OIM_Settings__c.getvalues('spCurrent');
        
        Blob headerValue = Blob.valueOf(CS.username__c+':'+ CS.password__c);
        String authorizationHeader = CS.authorizationType__c +' '+ EncodingUtil.base64Encode(headerValue);
              
        request.setMethod(CS.method__c);        
        request.setHeader('Authorization', authorizationHeader);        
        request.setHeader('Content-type',CS.contentHeader__c);        
        request.setTimeout(50000);        
        request.setEndPoint(CS.EndPoint__c);          
        request.setBody(strbody);
                

        try{
            system.debug ('#####Before callout : getcallouts'+Limits.getcallouts());
            system.debug ('#####Before callout : getLimitCallouts'+Limits.getLimitCallouts());

    //Fetch the response
            response = httpProtocol.send(request);
            system.debug ('#####After callout : getcallouts'+Limits.getcallouts());
            system.debug ('#####After callout : getLimitCallouts'+Limits.getLimitCallouts());
            
        }catch(System.calloutException e){
             System.debug('#####Callout Exception: '+e+' , response.toString(): '+response.toString());              
             String responseMessageException= '\n response.getStatusCode(): '+response.getStatusCode()+ '\n response.getStatus(): '+response.getStatus()+'\n response.getBody(): '+response.getBody();

    //Send Mail if an exception occurs
             String emailcontentbody='Dear Team,\nADP share project(Provision Asset) is failed for the Agreeement Record:'+AgmtId+'.It threw Exception:\n'+e+'\nPlease work with OAG/OSB team to fix the issue.\nDetails:\n'+responseMessageException;
             String subject = 'Unable to Share projects with the group: '+GlobalGroupName+' in GITLab';
             Dup.sendEmail(emailcontentbody,useremail,subject);

        }
            String responsebody=response.getBody();
            System.debug('#####response.getStatusCode(): '+response.getStatusCode()+ ', response.getStatus(): '+response.getStatus()+',response.getBody(): '+response.getBody());
            String responseMessage= '\n response.getStatusCode(): '+response.getStatusCode()+ '\n response.getStatus(): '+response.getStatus()+'\n response.getBody(): '+response.getBody();
            
            Integer responsecode =response.getStatusCode();           
                      
            if ( responsecode == 200 || responsecode == 409){                 
                 if(responsebody.containsIgnoreCase('FAIL') == true || responsebody.containsIgnoreCase('ERROR') == true ){
                     //Send Mail if the response body is error or fail
                    String emailcontentbody='Dear Team,\nADP share project(Provision Asset) is failed for the Agreeement Record:'+AgmtId+'.\nPlease work with OAG/OSB team to fix the issue.\nDetails:\n'+responseMessage;
                    String subject = 'Unable to Share projects with the group: '+GlobalGroupName+' in GITLab';
                    Dup.sendEmail(emailcontentbody,useremail,subject); 
                  }
            }  else{
                    //Send Mail if the response code is not success
                String emailcontentbody='Dear Team,\nADP share project(Provision Asset) is failed for the Agreeement Record:'+AgmtId+'.\nPlease work with OAG/OSB team to fix the issue.\nDetails:\n'+responseMessage;
                String subject = 'Unable to Share projects with the group: '+GlobalGroupName+' in GITLab';
                system.debug('#####Inside Failure Status Code, responsecode:' +responsecode+' responsebody:'+responsebody);
                Dup.sendEmail(emailcontentbody,useremail,subject);            
            } 
      }      
}