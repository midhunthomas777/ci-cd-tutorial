/*  
* File Name     : ADPFindDuplicatesExtension
* Description   : This class is used for Creating or Associating Partner Account to the ADP Application during PIC Approval.
* Modification Log
* =============================================================================
*   Ver     Date         Author                      Modification
*------------------------------------------------------------------------------
*   1.0     1-Nov-16    Saiharish Thammana       Initial Creation
*   2.0     11-Nov-16   Poongodi V               Updated the Associate Account and Create New Account Methods 
*   3.0     23-Nov-16   Poongodi V               Updated the new Field API Name of ADP Registration and Account objects
*   4.0     13-Feb-17   Poongodi V               Added Dave's comments on 'Create New account'
*/
public class ADPFindDuplicatesExtension {
    
    Public List<Account> DuplicateAccounts;
    Public List<ADPFindDupAccWrapper> DisplayList{get;set;}
    Public List<ADPFindDupAccWrapper> TempList{get;set;}
    public List<ADPFindDupAccWrapper> lstSetController{get;set;}
    
    Public Boolean PartAccExist{get;set;}
    Public Boolean ApprovalFlag{get;set;}
    Public Boolean TrueFlag{
        get{
            return true;
        }
        set;
    }
    Public Boolean AccountCreatedFlag{get;set;}
    Public Boolean CreateButtonFlag{get;set;}
    Public Boolean NoDupeExists{get;set;}
    Public Boolean AssociateCancelButtonFlag{get;set;}
    Public final ADP_Registration__C ADPReg;
    Public ADP_Registration__C ADPReg1{get;set;}
    Public Account TAcc;
    Public List<Account> finalResults = new List<Account>();
    
    Public String SelGrpName{get;set;}
    Public String OrgGrpName{get;set;}
    Public String AccRegion{get;set;}
    
    
    Public String ProgramDetail_Community_Type =Label.ADPFDProgDetCommunityType; // 'Application Developer'
    Public String ProgramDetail_Partner_Category=Label.ADPFDProgDetPartnerCategory; // 'Application Developer';
    Public String ProgramDetail_Type=Label.ADPFDProgDetType; //'Application';
    
    public String RegionNAMR=Label.ADP_NAMR;
    public String RegionLACR=Label.ADP_LACR;
    public String RegionEMEA=Label.ADP_EMEA;
    public String RegionAPAC=Label.ADP_APAC;
    public String ADPNewAccOwner=Label.ADPNewAccOwner; //User ID of Michael Ruscitti
    
    //Added for pagination
    ADPFindDupCustomIterable obj;
    
    private Map<Id, ADPFindDupAccWrapper> accountToWrapper_cached = new Map<Id, ADPFindDupAccWrapper>();
    
    
    public ADPFindDuplicatesExtension (ApexPages.StandardController stdController)
    {
        
        DisplayList= new List<ADPFindDupAccWrapper>();
        TempList=new List<ADPFindDupAccWrapper>();
        
        ADPReg= (ADP_Registration__C)stdController.getRecord();
        ADPReg1=[Select id,Applicant_First_Name__c,Applicant_Last_Name__c,Company_Name__c,Company_Website__c,Technology_Segment_Interest__c,Company_Registration_Number__c,ADP_Global_Account_Name1__c,Partner_Account__c,Application_Status__c,Existing_Partner_Membership_ID__c,City_Town__c,Country__c,zipcode__c,Applicant_State_Province__c,Street_Address_1__c,Address_Line_2__c,Company_Telephone_Number__c,Fax__c,Dealer_Contact_E_mail_Address__c,Has_Existing_Relationship__c,Region_Requested__c,Is_New_Account_Created__c from ADP_Registration__C where Id=:this.ADPReg.Id];
        System.debug('*****ADP Records*****' +ADPReg1);
        //To fetch Matching records
        DuplicateAccounts=fetchMatchingAccounts(ADPReg1);  
        
        PartAccExist=String.isBlank(ADPReg1.Partner_Account__c);
        
        if(ADPReg1.Application_Status__c=='Approved - ADP Lead')
            ApprovalFlag=true;         
        else
            ApprovalFlag=false;  
        
        if(ADPReg1.Is_New_Account_Created__c == true)
            AccountCreatedFlag=true;
        else
            AccountCreatedFlag=false;    
        
        if(ApprovalFlag==false ||AccountCreatedFlag==true)
            CreateButtonFlag=true; 
        else
            CreateButtonFlag=false;
        
        if(DuplicateAccounts.size()>0)
            NoDupeExists=false;
        else
            NoDupeExists=true;
        
        if(NoDupeExists==false && ApprovalFlag==true)
            AssociateCancelButtonFlag=false;
        else
            AssociateCancelButtonFlag=true;      
        
        //Mapping for the Region field in Account
        if(ADPReg1.Region_Requested__c.equals(RegionNAMR))
            AccRegion='NAMR';
        else if(ADPReg1.Region_Requested__c.equals(RegionLACR))
            AccRegion='LACR';
        else if(ADPReg1.Region_Requested__c.equals(RegionEMEA))
            AccRegion='EMEA';
        else if(ADPReg1.Region_Requested__c.equals(RegionAPAC))
            AccRegion='APAC';
        //To list of Partner accounts using the Wrapper class
        getDuplicateRecords();
       System.debug('***CreateButtonFlag***' +CreateButtonFlag);
    }
    
    //Method to fetch Matching records    
    public List<Account> fetchMatchingAccounts(ADP_Registration__c ADPRecord){
        String CompanyName=ADPRecord.Company_Name__c;
        
        RecordType theRecordType = [Select Id from RecordType where Name='Partner' and SobjectType='Account' limit 1];
        
        if(ADPRecord.Company_Name__c != null){
            List<String> StringSplit = new List<String>();
            List<String> StringSplitCompName = new List<String>();
            CompanyName= CompanyName.trim();
            String companyNameEscape = String.escapeSingleQuotes(CompanyName);
            StringSplit = companyNameEscape.split(' ');
            
            String searchstringBeginning = '';
            String searchstringMiddle = '';
            String searchstringEnd = '';
            String searchStringFullname='';
            finalResults = new List<Account>();
            if(StringSplit.size()==1){
                if(StringSplit[0].equalsignorecase('The') || StringSplit[0].equalsignorecase('An') || StringSplit[0].equalsignorecase('A')){ 
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please provide valid Company Name on ADP Application'));
                }else{
                    searchstringBeginning = StringSplit[0]+' %';
                    searchstringMiddle = '% '+StringSplit[0]+' %';
                    searchstringEnd = '% '+StringSplit[0]; 
                    searchStringFullname = StringSplit[0];                 
                }    
            }else{ 
                for(string cn: StringSplit){
                    searchStringFullname=searchStringFullname+'%'+cn;
                }  
                if(StringSplit[0].equalsignorecase('The') || StringSplit[0].equalsignorecase('An') || StringSplit[0].equalsignorecase('A')){ 
                    searchstringBeginning = StringSplit[1]+' %';
                    searchstringMiddle = '% '+StringSplit[1]+' %';
                    searchstringEnd = '% '+StringSplit[1]; 
                }else{
                    searchstringBeginning = StringSplit[0]+' %';
                    searchstringMiddle = '% '+StringSplit[0]+' %';
                    searchstringEnd = '% '+StringSplit[0]; 
                }         
            }
            finalResults = [Select Id,Name,Owner.Name,ADP_Global_Account_Name1__c,Company_Tax_Registration_ID__c,Partner_Membership_Id__c,Partner_Region__c,BillingStreet, BillingCity, BillingState, BillingPostalCode,BillingCountry,ADP_Technology_Segment__c,ADP_Partner__c from Account where Hierarchy_Placement__c !=:'ERP Account' and (name like :searchstringBeginning or name like :searchstringMiddle or name like :searchstringEnd or name like :searchStringFullname or ADP_Global_Account_Name1__r.Name like :searchstringBeginning) and MPE_Program_Status_New__c=:'Active' and recordtypeId=:theRecordType.Id limit 900];
            System.Debug('@@@@@finalResults is'+finalResults);
            
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please provide Company Name on ADP Application'));
        }
        
        
        return finalResults;    
        
    }
    
    //Displays the list of Partner accounts using the Wrapper class
    Public void getDuplicateRecords()
    {
        DisplayList= new List<ADPFindDupAccWrapper>();
        
        if(DisplayList.size()==0)
        {
            for(Account A:DuplicateAccounts)
            {
                ADPFindDupAccWrapper AWP= new ADPFindDupAccWrapper();
                AWP.GroupName=ADPReg1.ADP_Global_Account_Name1__c;
                AWP.Acc=A;
                TempList.add(AWP);
            }
        }           
        
        obj = new ADPFindDupCustomIterable(TempList); 
        obj.setPageSize = 100;
        next();   
    } 
    
    
    //Method to Associate selected account    
    Public PageReference AttachAccount()
    {    
        Integer Count=0;
        for(ADPFindDupAccWrapper AccWrap:lstSetController )
        {
            if(AccWrap.SelectedAcc==true){
                Count++;  
            }         
        }
        if(Count==0)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please choose an account before associating account'));
            return null;
        }
        else if(Count>1)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please choose only one account before associating account'));
            return null;
        }
        else if(count==1)
        {
            Id AccId;
            
            for(ADPFindDupAccWrapper AccWrap:lstSetController){
                if(AccWrap.SelectedAcc==true){
                    AccId= AccWrap.Acc.Id;
                }
            }
            
            ADPReg1.Partner_Account__c =AccId;
            Database.UpsertResult srList = Database.upsert(ADPReg1,false); // Modified by from upsert to Database.upsert Harish for SF-1477
            
            /*Added by Harish for SF-1477 to display error message in user readable format*/
            // Operation failed, so get all errors                
            for(Database.Error err : srList.getErrors()) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,err.getMessage()));
                return null;
            }
            /*Added by Harish for SF-1477 to display error message in user readable format*/
            
            Pagereference p= new Pagereference('/'+ADPReg.Id);
            return p;
        }    
        return null;
    }
    
    //Method to Create New Account for the ADP Application
    Public PageReference CreateNewAccount(){
        if(ADPReg1.Is_New_Account_Created__c==true){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'An Account has been created for this application already..Hence, could not create New account again..'));
        }else{
            RecordType theRecordType = [Select Id from RecordType where Name='Partner' and SobjectType='Account' limit 1];
            Account NewAcc=new Account();
            NewAcc.recordtypeId=theRecordType.Id;
            NewAcc.Type = 'Partner'; //Added as a part of SF-1500(INC1957227)
            NewAcc.Name=ADPReg1.Company_Name__c;
            NewAcc.ADP_Global_Account_Name1__c=ADPReg1.ADP_Global_Account_Name1__c;
            NewAcc.Company_Tax_Registration_ID__c=ADPReg1.Company_Registration_Number__c;
            if(string.isblank(ADPReg1.Address_Line_2__c) ==true){
                NewAcc.BillingStreet=ADPReg1.Street_Address_1__c;
                system.debug('####NewAcc.BillingStreet: '+NewAcc.BillingStreet);
            }else{
                String str = ADPReg1.Street_Address_1__c;
                str = str.removeEnd(',');
                system.debug('Value is ' + str);
                NewAcc.BillingStreet=str+','+ADPReg1.Address_Line_2__c;
                system.debug('####NewAcc.BillingStreet: '+NewAcc.BillingStreet);
            }
            NewAcc.BillingCity=ADPReg1.City_Town__c;
            NewAcc.BillingState=ADPReg1.Applicant_State_Province__c;
            NewAcc.BillingCountry =ADPReg1.Country__c;
            NewAcc.BillingPostalCode=String.Valueof(ADPReg1.zipcode__c);
            NewAcc.Hierarchy_Placement__c='Regional Account';
            NewAcc.MPE_Program_Status_New__c='Active';
            NewAcc.ADP_Partner__c=true;
            NewAcc.Partner_Region__c=AccRegion;
            //Added Account Owner, Phone, Website, Fax, Distributors Email as per Dave's comments
            NewAcc.OwnerId = ADPNewAccOwner;
            NewAcc.Phone =ADPReg1.Company_Telephone_Number__c; 
            NewAcc.Website=ADPReg1.Company_Website__c;
            NewAcc.Fax=String.Valueof(ADPReg1.Fax__c);
            NewAcc.Partner_Distributor_email__c =ADPReg1.Dealer_Contact_E_mail_Address__c; 
            //Added as per Business request to avail LMS Courses
            NewAcc.Metal_Level__c='Registered';
            Insert NewAcc;
            
            System.debug('NewAcc:'+NewAcc);
            
            
            //Added Partner Location as per Dave's comment
            Partner_Location__c PartnerLoc=new Partner_Location__c();
            PartnerLoc.Account__c=NewAcc.Id;
            PartnerLoc.Address_Line1__c=ADPReg1.Street_Address_1__c;
            if(string.isblank(ADPReg1.Address_Line_2__c) ==false)
                PartnerLoc.Address_Line2__c=ADPReg1.Address_Line_2__c;
            PartnerLoc.Phone__c =ADPReg1.Company_Telephone_Number__c;
            PartnerLoc.Fax__c =String.Valueof(ADPReg1.Fax__c);
            PartnerLoc.City__c =ADPReg1.City_Town__c;
            PartnerLoc.Country1__c = ADPReg1.Country__c;
            PartnerLoc.Postal_code__c=ADPReg1.Zipcode__c;
            PartnerLoc.State__c=ADPReg1.Applicant_State_Province__c;
            PartnerLoc.Address_Type__c='HQ';
            Insert PartnerLoc;
            
            ADPReg1.Partner_Account__c =NewAcc.Id;
            ADPReg1.Is_New_Account_Created__c=true;
            Update ADPReg1;
            
            Pagereference p= new Pagereference('/'+ADPReg.Id);
            return p;
        }
        return null;
    }
    
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
    
    //Iterator class for the pagination
    public class  ADPFindDupCustomIterable  implements Iterator<list<ADPFindDupAccWrapper>>{ 
        list<ADPFindDupAccWrapper> InnerList{get; set;}
        list<ADPFindDupAccWrapper> ListRequested{get; set;}
        Integer i {get; set;} 
        public Integer setPageSize {get; set;} 
        
        public ADPFindDupCustomIterable (List<ADPFindDupAccWrapper> lstAccWr){
            InnerList = new list<ADPFindDupAccWrapper>(); 
            ListRequested = new list<ADPFindDupAccWrapper>();     
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
        
        public list<ADPFindDupAccWrapper> next(){       
            ListRequested = new list<ADPFindDupAccWrapper>(); 
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
        
        public list<ADPFindDupAccWrapper> previous(){      
            ListRequested = new list<ADPFindDupAccWrapper>(); 
            integer size = InnerList.size(); 
            if(hasprevious()){
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
                    ListRequested.add(InnerList[start]);
                } 
            }
            return ListRequested;
        }   
        
    }
    
    //Wrapper Class    
    Public Class ADPFindDupAccWrapper{
        Public boolean SelectedAcc{get;set;}
        Public Account Acc{get;set;}
        Public String GroupName{get;set;}
        
        public ADPFindDupAccWrapper(boolean SelectedAcc,Account Acc,String GroupName){
            this.SelectedAcc= SelectedAcc;
            this.Acc= Acc;
            this.GroupName=GroupName;
        }
        public ADPFindDupAccWrapper(){
        }
    }
    
    
}