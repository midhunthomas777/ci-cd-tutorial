/*  
* File Name     : ADP_AEMService 
* Description   : This class is Webservice class to AEM Interface.
*                Both the Query paramenters (groupid and GetGoogeldriveId) are mandatory. When the GetGoogeldriveId is true, this class returns the Google drvie path. Else if false, returns the agreements having Group id in Partner Account
* Modification Log
* =============================================================================
*   Ver     Date         Author                      Modification
*------------------------------------------------------------------------------
*   1.0     5-Jan-17    Kalaivani Rajendran      Initial Creation
*   2.0     10-Jan-17   Poongodi V               Added the Query and Json response
*/

@RestResource(urlMapping='/showlicenses/*')
global class ADP_AEMService {
   global class MyClass {
   Public String technology;
   public string numberofAgreements;
   Public ResponseClass[] listofAgreements;
   
        public MyClass (String resTech, String resAgmtCount, ResponseClass[] resAgmtList){
            this.technology = resTech;
            this.numberofAgreements = resAgmtCount;
            this.listofAgreements= resAgmtList;
        }       
   } 
   
   global class MainClass{
   Public String status;
   public string googlepath;
   public string message;
   Public MyClass[] values;
           public MainClass(String resStatus,String resMessage,MyClass[] resOutputValues){
            this.status= resStatus;
            this.message= resMessage;
            this.values= resOutputValues;
        }
           public MainClass(String resStatus, String resMessage){
            this.Status= resStatus;
            this.Message= resMessage;
        }
           public MainClass(String resStatus,String resMessage,String resGooglepath){
            this.status= resStatus;
            this.message= resMessage;
            this.googlepath = resGooglepath;
        }
   }
    global class ResponseClass {
        public String AgreementTitle;
        public String AgreementADPTech;
        public String AgreementAccName; 
        Public String AgreementStartDate; 
        Public String AgreementEndDate; 
        public String AgreementSubTech; 
        Public String AgreementRegion; 
        Public String AgreementMSIAssignmentNo; 

        public ResponseClass (String AgmtTitle, String AgmtADPTech, String AgmtAccName, String AgmtStartDate, String AgmtEndDate, String AgmtSubTech, String AgmtRegion, String AgmtMSIAssignmentNo) {
            this.AgreementTitle = AgmtTitle;
            this.AgreementADPTech= AgmtADPTech ;
            this.AgreementAccName = AgmtAccName;
            this.AgreementStartDate = AgmtStartDate;
            this.AgreementEndDate = AgmtEndDate;
            this.AgreementSubTech = AgmtSubTech;
            this.AgreementRegion = AgmtRegion;
            this.AgreementMSIAssignmentNo = AgmtMSIAssignmentNo;
        }
    }


    @HttpGet
    global static  MainClass getAgreements() {
        //Get QueryParameters
        String groupid= '';
        String GetGoogeldriveId = '';
        
        transient MyClass responseObj;
        transient MainClass responseO;
        transient List<MyClass> responseObjList= new List<MyClass>();
        
        groupid= RestContext.request.params.get('groupid');
        GetGoogeldriveId = RestContext.request.params.get('GetGoogeldriveId');
        system.debug('#####Query Parameters: groupid-'+groupid+' and GetGoogeldriveId -'+GetGoogeldriveId );
        Integer intGroupId;
        String response ='';
        String stringResFrmJson = '';
        List<ADP_Global_Account_Name__c> listADPGlobName;
        String [] name=new String[]{'ASTRO','Convergence Suite','DIMETRA','MOTOTRBO'};
        
        if((string.isblank(groupid) == false) && (string.isblank(GetGoogeldriveId) == false)){
        intGroupId = Integer.valueof(groupid);                
            listADPGlobName=[select GoogleFolderID__c from ADP_Global_Account_Name__c where GitLab_Group_Id__c=:intGroupId limit 1];//='a8h1b00000000QE'];
        system.debug('#####listADPGlobName: '+listADPGlobName);                       
            if(listADPGlobName.size()== 1){
                
                if(GetGoogeldriveId.tolowercase() == 'false'){
                                
                List<Apttus__APTS_Agreement__c> lst;
                transient ResponseClass resClass;
                
                transient List<ResponseClass> astrolistResClass = new List<ResponseClass>();
                transient List<ResponseClass> imwlistResClass = new List<ResponseClass>();
                transient List<ResponseClass> dimetralistResClass = new List<ResponseClass>();
                transient List<ResponseClass> mototrbolistResClass = new List<ResponseClass>();
                RecordType theAgmtRecordType = [Select Id from RecordType where Name='ADP License' and SobjectType='Apttus__APTS_Agreement__c' limit 1];
    
                lst=[select id,Agreement_Title__c,m_Technology__c,m_GTM_Region__c,ADP_Technology__c,Apttus__Agreement_Number__c,Apttus__Account__r.name,Apttus__Contract_Start_Date__c,Apttus__Contract_End_Date__c from Apttus__APTS_Agreement__c where recordtypeId=:theAgmtRecordType.Id and Apttus__Account__r.ADP_Global_Account_Name1__r.GitLab_Group_Id__c=:intGroupId and Apttus__Status_Category__c=:'In Effect'];//  ='a8h1b00000000QE'];
                
                if(lst.size()>0){        
                    for (Apttus__APTS_Agreement__c  t:lst){
                        if(t.ADP_Technology__c == 'ASTRO'){
                            resClass = new ResponseClass(t.Agreement_Title__c, t.ADP_Technology__c, t.Apttus__Account__r.name,string.valueof(t.Apttus__Contract_Start_Date__c),string.valueof(t.Apttus__Contract_End_Date__c),t.m_Technology__c, t.m_GTM_Region__c, t.Apttus__Agreement_Number__c);
                            astrolistResClass.add(resClass); 
                        }else if(t.ADP_Technology__c == 'Convergence Suite'){
                            resClass = new ResponseClass(t.Agreement_Title__c, t.ADP_Technology__c, t.Apttus__Account__r.name,string.valueof(t.Apttus__Contract_Start_Date__c),string.valueof(t.Apttus__Contract_End_Date__c),t.m_Technology__c, t.m_GTM_Region__c, t.Apttus__Agreement_Number__c);
                            imwlistResClass.add(resClass);
                        }else if(t.ADP_Technology__c == 'DIMETRA'){
                            resClass = new ResponseClass(t.Agreement_Title__c, t.ADP_Technology__c, t.Apttus__Account__r.name,string.valueof(t.Apttus__Contract_Start_Date__c),string.valueof(t.Apttus__Contract_End_Date__c),t.m_Technology__c, t.m_GTM_Region__c, t.Apttus__Agreement_Number__c);
                            dimetralistResClass.add(resClass); 
                        }else{ 
                            resClass = new ResponseClass(t.Agreement_Title__c, t.ADP_Technology__c, t.Apttus__Account__r.name,string.valueof(t.Apttus__Contract_Start_Date__c),string.valueof(t.Apttus__Contract_End_Date__c),t.m_Technology__c, t.m_GTM_Region__c, t.Apttus__Agreement_Number__c);
                            mototrbolistResClass.add(resClass); 
                        }
                    } 
                    if(astrolistResClass.size()>0){
                        responseObj = new MyClass('ASTRO', string.valueof(astrolistResClass.size()), astrolistResClass);
                        responseObjList.add(responseObj);
                    }
                    if(imwlistResClass.size()>0){
                        responseObj = new MyClass('Convergence Suite', string.valueof(imwlistResClass.size()), imwlistResClass);
                        responseObjList.add(responseObj);
                    }
                    if(dimetralistResClass.size()>0){
                        responseObj = new MyClass('DIMETRA', string.valueof(dimetralistResClass.size()), dimetralistResClass);
                        responseObjList.add(responseObj);
                    }
                    if(mototrbolistResClass.size()>0){
                        responseObj = new MyClass('MOTOTRBO', string.valueof(mototrbolistResClass.size()), mototrbolistResClass);
                        responseObjList.add(responseObj);
                    }
                    
                    responseO= new MainClass('OK','Success',responseObjList);

                } else{
                    responseO= new MainClass('OK','No agreement record found for that group id in SFDC');                          
                }
            }else if(GetGoogeldriveId.tolowercase() == 'true'){  
                responseO= new MainClass('OK','Success','https://drive.google.com/drive/folders/'+listADPGlobName[0].GoogleFolderID__c);                 
            }else{
                responseO= new MainClass('Fail','GetGoogeldriveId value has to be either true or false'); 
            }
        }else{
                responseO= new MainClass('Fail','Group Id '+intGroupId +' is not available in SFDC');                          
        }             
    }else{
                responseO= new MainClass('Fail','Required Query parameters are not found'); 
    }
    system.debug('responseO:'+responseO);
    return responseO;
    }         
}