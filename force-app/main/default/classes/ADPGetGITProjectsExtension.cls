/*  
* File Name     : ADPGetGITProjectsExtension 
* Description   : class to list the Proj available in the GIT for the technology. 
*                Associate the User selected proj to the license record by removing existing Proj and adding the selected records
* Modification Log
* =============================================================================
*   Ver     Date         Author                      Modification
*------------------------------------------------------------------------------
*   1.0     9-Nov-16    Poongodi V                  Initial Creation
*/
public class ADPGetGITProjectsExtension {

Public Apttus__APTS_Agreement__c Agmt1{get;set;}
Public List<ADPGITWrapper> DisplayListRec{get;set;}
Public boolean NorecordExists{get;set;}
Public boolean HideFlag{get;set;}
Public Boolean TrueFlag{get{return true;}set;}
Public List<ADPGitLabProjectDetailsclass> DisplayList{get;set;}
public List<ADPGITWrapper> lstSetController{get;set;}

Public List<ADP_GITLAB_Project__c> RemoveGITProject;
Public final Apttus__APTS_Agreement__c Agmt;

//Added for pagination
ADPGetGITCustomIterable obj;

//Constructor
public ADPGetGITProjectsExtension(ApexPages.StandardController stdController){
     Agmt= (Apttus__APTS_Agreement__c)stdController.getRecord();
 
     Agmt1=[Select id,ADP_Technology__c from Apttus__APTS_Agreement__c where Id=:this.Agmt.Id];
     system.debug('Agmt1:'+Agmt1);
     
     HideFlag=true;
     DisplayList=new List<ADPGitLabProjectDetailsclass>(); 
     GitLabProjects();
     getGITAPIRecords();    
}

//Method which makes the http callout and stores the project details in a list     
    public void GitLabProjects() {
    //Instance to send mail in case of failure       
        ADPSendMailClass Dup=new ADPSendMailClass();

        if(Agmt1.ADP_Technology__c == null || Agmt1.ADP_Technology__c==''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please update ADP Technology field in Agreement'));
        } else{
     //HttpProtocol   
        Http httpProtocol = new Http();
        HttpResponse response = new HttpResponse();       
        HttpRequest request= new HttpRequest(); 

    //Fetch of Query Parameter of Endpoint URL
        String simpleVal = 'true';
        String sortVal = 'asc';
        String perPageVal = '100';
        String Orderby = 'name';
        ADP_GitLab_Group_Mapping__c GM = ADP_GitLab_Group_Mapping__c.getvalues(Agmt1.ADP_Technology__c);
        
    //Frame Http Request
        ADP_OIM_Settings__c CS = ADP_OIM_Settings__c.getvalues('rpCurrent');
        
        Blob headerValue = Blob.valueOf(CS.username__c+':'+ CS.password__c);
        String authorizationHeader = CS.authorizationType__c+' '+ EncodingUtil.base64Encode(headerValue);
                      
        request.setMethod(CS.method__C);        
        request.setHeader('Authorization', authorizationHeader);        
        request.setHeader('Content-type',CS.contentHeader__c);        
        request.setTimeout(50000);  
        request.setEndpoint(CS.EndPoint__c+'/'+GM.GITLab_grpid_of_Tech__c+'/projects?simple='+simpleVal+'&order_by='+orderby+'&sort='+sortVal+'&per_page='+perPageVal);   
        
        try{
            response = httpProtocol.send(request);
        }catch(System.calloutException e){
            System.debug('#####Http request Callout Exception: '+e);
            String responseMessageException= '\nresponse.getStatusCode(): '+response.getStatusCode()+ '\n response.getStatus(): '+response.getStatus()+'\n response.getBody(): '+response.getBody();
            System.debug('#####responseMessageException: '+responseMessageException);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'​Unable to retrieve projects from GITLab. An Exception '+e+' occured.Please create case with SFDC support team with below details or email to SFDCINT@motorolasolutions.com .Response detail: \n'+responseMessageException));
        }


        String responseMessage= '\nresponse.getStatusCode(): '+response.getStatusCode()+ '\n response.getStatus(): '+response.getStatus()+'\n response.getBody(): '+response.getBody();
        String responsebody=response.getBody();       
        System.debug('responseMessage: '+responseMessage);
           
        if(response.getStatusCode()== 200 && responsebody.containsIgnoreCase('ERROR')==false && responsebody.containsIgnoreCase('FAIL')== false){                          
           
            responsebody = '{"root":'+responsebody+'}';      
            ADPGetGITProjectJsonClass Sfrespone = ParserMethodResponse(responsebody );   
            System.Debug('####Final Response after deserialization :'+Sfrespone);
                 
            for(integer i=0;i<Sfrespone.root.size();i++){
              ADPGitLabProjectDetailsclass GP=new ADPGitLabProjectDetailsclass();              
              GP.ProjId=Sfrespone.root[i].id;
              GP.ProjName=Sfrespone.root[i].name;                 
              DisplayList.add(GP);
            } 
        }
        else{
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'​Unable to retrieve projects from GITLab. Please create a case with SFDC support team with below details or email to SFDCINT@motorolasolutions.com \nResponse details : \n'+responseMessage));
        }
      }
    }

    
//Method to wrap the GIT PRoject Records obtained from GITLabProjects method and display it in the visualforce page using iterator class 
    Public void getGITAPIRecords()
    {
      DisplayListRec= new List<ADPGITWrapper>();
      if(DisplayListRec.size()==0){
      for (Integer i=0;i<DisplayList.size();i++){
          ADPGITWrapper GW= new ADPGITWrapper();

          ADP_GITLAB_Project__c[] GITIdtest = [Select Id from ADP_GITLAB_Project__c where GIT_Project_ID__c=:DisplayList[i].ProjId and GIT_Project_Name__c=:DisplayList[i].ProjName and Agreement_ADP__c=:Agmt1.id limit 1];
     
          if(GITIdtest.size()==1)
          GW.SelectedGITAPIcheckbox=true;
          else
          GW.SelectedGITAPIcheckbox=false;
         
          GW.ProjId=DisplayList[i].ProjId;
          GW.ProjName=DisplayList[i].ProjName;
          DisplayListRec.add(GW);
    }
    }
     System.Debug('DisplayListRec'+DisplayListRec);
     obj = new ADPGetGITCustomIterable(DisplayListRec); 
     obj.setPageSize = 100;
     next();   
  
    }
    
//Method to remove existing GIT Records(if any) and add the user selected GIT project.
     Public PageReference AttachGITProjects(){
        System.Debug('Entered AttachGITProjects method');
        RemoveGITProject= [SELECT Id From ADP_GITLAB_Project__c where Agreement_ADP__c=:Agmt1.id];
        for(ADP_GITLAB_Project__c t:RemoveGITProject){
        delete t;
    }
    
    //Associates the GIT record that are selected
    for(ADPGITWrapper GITWrap:DisplayListRec){
         if(GITWrap.SelectedGITAPIcheckbox==true){          
            ADP_GITLAB_Project__c GITProj=new ADP_GITLAB_Project__c();
            GITProj.Agreement_ADP__c=Agmt1.Id;
            GITProj.GIT_Project_ID__c=GITWrap.ProjId;
            GITProj.GIT_Project_Name__c=GITWrap.ProjName;
            system.debug('#####Selected GITProjects:'+GITProj);
            Insert GITProj;
          }
     }
     
    Pagereference p= new Pagereference('/'+Agmt1.id);
    return p;
    }
          
//Deserialization Class       
    public static ADPGetGITProjectJsonClass ParserMethodResponse(String grp){
        return (ADPGetGITProjectJsonClass) System.JSON.deserialize(grp, ADPGetGITProjectJsonClass.class);
    }
    
//Class to hold the user selected proj Id and Proj Name obtained in API
    Public Class ADPGitLabProjectDetailsclass{ 
        Public Integer ProjId{get;set;}
        Public String ProjName{get;set;}
    }

//Class to hold the user selected proj Id and Proj Name obtained in API
    public class ADPGetGITProjectJsonClass{
        Public cls_roottest[] root;
    }
 
    Public class cls_roottest{
        Public Integer id;
        public String http_url_to_repo;
        public string web_url;
        public String name;
        public string name_with_namespace;
        public String path;
        public string path_with_namespace;
    }
//Pagination       
    public Boolean hasNext {
            get 
            {
                return obj.hasNext();
            }
            set;
        }
        
    public Boolean hasPrevious {
            get 
            {
                return obj.hasPrevious();
            }
            set;
        }
        
    public void next(){
        lstSetController = obj.next();
    }
        
    public void previous(){
        lstSetController = obj.previous();
    }
    
//Iterator class used for pagination
    public class  ADPGetGITCustomIterable implements Iterator<list<ADPGITWrapper>>{ 
       list<ADPGITWrapper> InnerList{get; set;}
       list<ADPGITWrapper> ListRequested{get; set;}
    
       Integer i {get; set;} 
       public Integer setPageSize {get; set;} 

       public ADPGetGITCustomIterable (List<ADPGITWrapper> lstAccWr)
       {
           InnerList = new list<ADPGITWrapper >(); 
           ListRequested = new list<ADPGITWrapper >();     
           InnerList = lstAccWr;
           setPageSize = 1;
           i = 0; 
       }   

       public boolean hasNext(){ 
           if(i >= InnerList.size()) {
               return false; 
           } else {
               return true; 
           }
       } 
       
       public boolean hasPrevious(){ 
           if(i <= setPageSize) {
               return false; 
           } else {
               return true; 
           }
       }   

       public list<ADPGITWrapper> next(){       
           ListRequested = new list<ADPGITWrapper>(); 
           integer startNumber;
           integer size = InnerList.size();

           if(hasNext()){  
               if(size <= (i + setPageSize)){
                   startNumber = i;
                   i = size;
               }else{
                   i = (i + setPageSize);
                   startNumber = (i - setPageSize);
               }
               
               for(integer start = startNumber; start < i; start++){
                   ListRequested.add(InnerList[start]);
               }
           } 
           return ListRequested;
       } 
   
       public list<ADPGITWrapper > previous(){      
           ListRequested = new list<ADPGITWrapper >(); 
           integer size = InnerList.size(); 
           if(i == size){
               if(math.mod(size, setPageSize) > 0){    
                   i = size - math.mod(size, setPageSize);
               }else{
                   i = (size - setPageSize);
               } 
           }else{
               i = (i - setPageSize);
           }
           
           for(integer start = (i - setPageSize); start < i; ++start){
            if(!Test.isRunningTest())
               ListRequested.add(InnerList[start]);
           } 
           return ListRequested;
        }   
     
        public list<ADPGITWrapper > checkAll(List<ADPGITWrapper> lstAccWrs){      
           ListRequested = new list<ADPGITWrapper >();            
           for(ADPGITWrapper t: lstAccWrs){
                t.SelectedGITAPIcheckbox = true;
                ListRequested.add(t);
            } 
            return ListRequested;
        }   
    }

//Wrapper Class    
    public Class ADPGITWrapper{
         Public boolean SelectedGITAPIcheckbox{get;set;}
         public boolean SelectedAllcheckbox{get;set;}
         Public ADP_GITLAB_Project__c  GITAPI{get;set;}
         Public Apttus__APTS_Agreement__c Agt{get;set;}
         Public Integer ProjId{get;set;}
         Public String ProjName{get;set;}
       
         public ADPGITWrapper(boolean SelectedGITAPIcheckbox,boolean SelectedAllcheckbox, ADP_GITLAB_Project__c GITAPI,Apttus__APTS_Agreement__c Agt,Integer ProjId,String ProjName){
            this.SelectedGITAPIcheckbox= SelectedGITAPIcheckbox;
            this.SelectedAllcheckbox= SelectedAllcheckbox;
            this.GITAPI= GITAPI;
            this.Agt= Agt;
            this.ProjId= ProjId;
            this.ProjName= ProjName;
        } 
        
        public ADPGITWrapper(){
        }
    }
    
}