public without sharing class AccountRecordtypeRedirect{
  private ApexPages.StandardController controller;
  public String retURL {get; set;}
  public String rType {get; set;}
  private String RecordTypeName;
  public String checkSF1orDesktop{get;set;}
  public List<String> listrecordTypeAllowed;
  public AccountRecordtypeRedirect(ApexPages.StandardController controller) {
      this.controller = controller;
      RecordTypeName = '';
      retURL = ApexPages.currentPage().getParameters().get('retURL');
      rType = ApexPages.currentPage().getParameters().get('RecordType');
      listrecordTypeAllowed = System.Label.SBC_RecordTypes.split(',');
  }
  public PageReference redirect(){
  try{   
        checkSF1orDesktop=ApexPages.currentPage().getParameters().get('validateSF1flag');     
        PageReference returnURL;
        String RecordTypeName='';
        String DefaultRecordType=''; 
      system.debug('rType----------->'+rType);
        if(string.isblank(rType)){
        system.debug('rType----------->'+rType);
                DefaultRecordType=getdefRecordType();
                if(DefaultRecordType != null && DefaultRecordType != ''){
                         RecordTypeName =[select id,name from recordtype where id =:DefaultRecordType].Name;                  	  
                        if(listrecordTypeAllowed.contains(RecordTypeName)){
                        //if(RecordTypeName.equalsignorecase('Prospect')){
                         returnURL = new PageReference('/apex/SearchBeforeCreate?RecordType='+DefaultRecordType);//SF-2094
                          // if(checkSF1orDesktop == 'false')
                           // returnURL = new PageReference('/apex/DDC_AccountSBC_LightningM_V1');
                           // else
                              //returnURL = new PageReference('/apex/DB_AccountSearchCreate_SF1');
                          }
                          else{
                                  returnURL = new PageReference('/001/e');
                                  returnURL.getParameters().put('retURL', retURL);
                                  returnURL.getParameters().put('RecordType', DefaultRecordType);
                                  returnURL.getParameters().put('nooverride', '1');  
                                  returnURL.setRedirect(true);
                              }
                              
                         }
                         else{                   
                                  returnURL=new PageReference('/setup/ui/recordtypeselect.jsp?ent=Account&nooverride=1&save_new_url=%2F001%2Fe');                             
                                  returnURL.setRedirect(true);              
                             }
        
           }
             else{
                     system.debug('recordtype else part');
                      RecordTypeName =[select id,name from recordtype where id =:rType].Name; 
                 system.debug('RecordTypeName----------->'+RecordTypeName);
                     if(listrecordTypeAllowed.contains(RecordTypeName)){
                      //if(RecordTypeName.equalsignorecase('Prospect')){
                          //if(checkSF1orDesktop == 'false')
                            returnURL = new PageReference('/apex/SearchBeforeCreate?RecordType='+rType);//SF-2094
                         //returnURL = new PageReference('/apex/DDC_AccountSBC_LightningM_V1');
                       // else
                         // returnURL = new PageReference('/apex/DB_AccountSearchCreate_SF1');                    
                      }                    
                     else{
                          returnURL = new PageReference('/001/e');
                          returnURL.getParameters().put('retURL', retURL);
                          returnURL.getParameters().put('RecordType', rType);
                          returnURL.getParameters().put('nooverride', '1');  
                          returnURL.setRedirect(true);
                        }    
                  }
      return returnURL;   
      }
      catch(Exception ex){
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No record type permission is  assigned for  this User!'+ex.getMessage())); 
          return null; 
       }
    }  
  public static string getdefRecordType(){
  List<Schema.RecordTypeInfo> infos = Schema.SObjectType.Account.RecordTypeInfos;
  Id defaultRecordTypeId;
  for (Schema.RecordTypeInfo info : infos){
   system.debug('for loop run');
    if (info.DefaultRecordTypeMapping){
     if(!(info.isMaster()))
      defaultRecordTypeId = info.RecordTypeId;
      else
      defaultRecordTypeId=null;    
    } 
  }
  return defaultRecordTypeId; 
   }      
  }