/*  
* File Name     : ADPController
* Description   : This class is used for New Application Developer Program OnBoarding process via sites.com.
* Modification Log
* =============================================================================
*   Ver     Date         Author                      Modification
*------------------------------------------------------------------------------
*   1.0     06-Oct-16    SriDurgaDevi Sankaran       Initial Creation
    2.0     01-Feb-17    Madhavi Latha Pannala       New Form Changes
*/

    public class ADPController {
    public Boolean HideAccinfo{get;set;}
    public Boolean MarketOther{get;set;}
    public Boolean APILicence{get;set;}
    ADP_Registration__c ADPApp = new ADP_Registration__c();
    public String FileCount {get; set;}   
    public String AppID {get;set;}
    public Boolean existsRel{set; get;}
    public Boolean existsRel1{set; get;}
    public String MPM_ID{set; get;}
    public String TS{set; get;}
    public Boolean eMemSum{set; get;}
    public Boolean showeMemSum{set; get;}
    public List<ID> accountList {get; set;}
    public List<Account> Accs {get; set;}  
    public string temp{set; get;}
    public string getTechseg1{get;set;}
    //public Boolean ASTROFlag{get;set;} 
    public String tech{get;set;}
    public Boolean RelType {get;set;}
    public String exists{get;set;}
    Set<String> tmpString; 
    public Boolean Isattach {get{ return true;} set;} //render boolean for UploadDoc Page
    public String recid {get;set;} //Id of the attachment which has to be removed in UploadDoc Page
    public List<Attachment> att {get;set;}  //List of attachments displayed in UploadDoc Page  
    public List<Attachment> delatt {get;set;} //List of attachment to be removed/deleted in UpladDoc Page
    public Boolean ADPShowAcc{get;set;}//added by sampath 4-11-16
     //included by Madhavi (03-02-2017)
    public Boolean chkBx1{get;set;}
    public Boolean chkBx2{get;set;}
    public Boolean chkBx3{get;set;}
    public Boolean chkBx4{get;set;}
    public Boolean chkBx5{get;set;}
    public Boolean chkBx6{get;set;}
    public Boolean chkBx7{get;set;}
    public Boolean chkBx8{get;set;}
    public Boolean chkBx9{get;set;}
    public Boolean chkBx10{get;set;}
    public Boolean chkBx11{get;set;}
    public Boolean chkBx12{get;set;}
    public Boolean chkBx13{get;set;}
    public Boolean chkBx14{get;set;}
    public Boolean chkBx15{get;set;}
    public Boolean chkBx16{get;set;}
    
    public Attachment attachment {
    get {
      if (attachment == null)
        attachment = new Attachment();
      return attachment;
     }
    set;
    }
 
  
    public PageReference onLoad() {
        
        ADPShowAcc =false;//added by sampath 
        HideAccinfo = false;
        showeMemSum = true;
        string status;
        PageReference p = new PageReference('');
        AppID = ApexPages.currentPage().getParameters().get('id');
        if (AppID != null){
        List <ADP_Registration__c> app = [SELECT Application_Status__c FROM ADP_Registration__c where ID =:AppID]; 
        status = app[0].Application_Status__c;
        }
        if(status == 'Expired'){
            system.debug('Entering into expired loop' );
            p = new PageReference('/apex/ADPRegistrationThankyouPage?EXP=1');
            p.setRedirect(true);
            return p;    
        } else if(status != null && status != 'Pending' && status != 'Expired' && status != 'New'){
            system.debug('Entering into application inprogress loop' );
            p = new PageReference('/apex/ADPRegistrationThankyouPage?AIP=1');
            p.setRedirect(true);
            return p;
        }
        else{
        return null;} 
    }
  
    public List<SelectOption> techSeg
    {
    get
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('None','--None--'));
        Schema.DescribeFieldResult fieldResult = ADP_Registration__c.Technology_Segment_Interest__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for( Schema.PicklistEntry f : ple){
           // options.add(new SelectOption(f.getLabel(), f.getValue()));
           options.add(new SelectOption(f.getValue(), f.getLabel()));
        }
            
        return options;
    }
    }

    public List<SelectOption> techSeg1
    {
    get
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('None','None'));
        options.add(new SelectOption('Application Partner','Application Partner'));
        options.add(new SelectOption('Intelligent Middleware (IMW)','Intelligent Middleware (IMW)'));
        options.add(new SelectOption('MOTOTRBO','MOTOTRBO'));
        return options;
    }
    }

    public ADPController(ApexPages.StandardController controller) {
    
       // techSegs=new list<SelectOption>();
        string AppName;
        //AppID = ADPApp.id; 
        AppID = ApexPages.currentPage().getParameters().get('id');
        if (AppID != null){
        att= new list<Attachment>();
        att= [SELECT Id,Name,Description FROM Attachment where parentId=:AppID]; //ADPApp.Id]; 
        List <ADP_Registration__c> app = [SELECT Applicant_First_Name__c,Application_Status__c,Technology_Segment_Interest__c,Tetra_Systems_List__c,Subscriber_related_developments__c, DIMETRA_IP_Compact_S_W_Release__c,DIMETRA_IP_Micro_or_DIMETRA_LiTE__c,DIMETRA_IP_Scalable_S_W_release__c,Non_Motorola_DIMETRA_IP_S_W_Release__c,Which_APIs_customer_purchase__c,Please_Select_Astro_Radios__c,ASTRO_APX_Radio_Models__c,ASTRO_XTL_Radio_Models__c,ASTRO_XTS_Radio_Models__c,L_Core_Trunking_System_software_release__c,K_Core_Conventional_System_S_W_Release__c,M_Core_System_S_W_Release__c,Astro_Radios__c,ASTRO_P25_S_W_Release_systems__c,Type_of_Product_s_or_End_User_s__c FROM ADP_Registration__c where ID =:AppID]; 
      if(app[0].DIMETRA_IP_Scalable_S_W_release__c!=null)    
        chkBx1= true;    
        else
        chkBx1= false;
        if(app[0].DIMETRA_IP_Compact_S_W_Release__c!=null)
        chkBx2= true;
        else
        chkBx2= false;
        if(app[0].DIMETRA_IP_Micro_or_DIMETRA_LiTE__c!=null)    
        chkBx3= true;    
        else
        chkBx3= false;
        if(app[0].Non_Motorola_DIMETRA_IP_S_W_Release__c!=null)    
        chkBx4= true;    
        else
        chkBx4= false;
        
        if(app[0].L_Core_Trunking_System_software_release__c!=null)    
        chkBx5= true;    
        else
        chkBx5= false;
        if(app[0].K_Core_Conventional_System_S_W_Release__c!=null)
        chkBx6= true;
        else
        chkBx6= false;
        if(app[0].M_Core_System_S_W_Release__c!=null)    
        chkBx7= true;    
        else
        chkBx7= false;
        if(app[0].ASTRO_APX_Radio_Models__c!=null)    
        chkBx8= true;    
        else
        chkBx8= false;
        
        if(app[0].ASTRO_XTS_Radio_Models__c!=null)    
        chkBx9= true;    
        else
        chkBx9= false;
        if(app[0].ASTRO_XTL_Radio_Models__c!=null)    
        chkBx10= true;    
        else
        chkBx10= false;
        if(app[0].Subscriber_related_developments__c!=null)  
        chkBx16= true; 
        else
        chkBx16= false;
        if(app[0].Please_Select_Astro_Radios__c !=null)
        {
        if(app[0].Please_Select_Astro_Radios__c.contains( 'Direct or Tactical Mode' ) ) 
        chkBx11= true;    
        else
        chkBx11= false;
         if(app[0].Please_Select_Astro_Radios__c.contains( 'Repeater Mode' ) ) 
        chkBx12= true;    
        else
        chkBx12= false;
         if(app[0].Please_Select_Astro_Radios__c.contains( 'Fixed Network Equipment (FNE) Mode' ) ) 
        chkBx13= true;    
        else
        chkBx13= false;
         if(app[0].Please_Select_Astro_Radios__c.contains( 'Smartnet & Mixed Mode 4.1' ) ) 
        chkBx14= true;    
        else
        chkBx14= false;
         if(app[0].Please_Select_Astro_Radios__c.contains( 'ASTRO IV&D or ASTRO P25 Trunking' ) ) 
        chkBx15= true;    
        else
        chkBx15= false;
        
        }
        
    }

  }
  
      public ADP_Registration__c getADP(){
 
          AppID = ApexPages.currentPage().getParameters().get('id');
          if (ADPApp.Id == null && AppID != null){ 
            ADPApp = [Select Id,Name,Product_Application_Name__c,Product_Description__c ,Company_Telephone_Number__c,Partner_Account__r.ADP_Technology_Segment__c, Applicant_First_Name__c, Applicant_Last_Name__c,
                  Applicant_Phone_Number__c,Purpose_of_the_Product_Application__c , Fax__c, Applicant_Email_Address__c, Region_Requested__c,Has_Existing_Relationship__c,Are_you_working_for_Radio_Dealer__c,
                  Company_Name__c,Product_Feature_and_Functionalities__c , Street_Address_1__c, Company_Registration_Number__c, Address_Line_2__c,How_did_you_hear_about_the_program__c,
                  VAT_Number__c, City_Town__c, Country__c,Regions_you_will_be_positioning_products__c ,Name_Signatory_Person__c,Title_of_Contact__c,Contact_Telephone_Number__c,Contact_Name__c,
                  Applicant_State_Province__c,Zipcode__c,Company_Website__c,Technology_Segment_Interest__c,If_Others_please_provide_details__c,Title_Signatory_Person__c,
                  Have_any_current_customer_opportunities__c,Please_describe_the_scope_of_opportunity__c,Corporate_Name_of_Channel_Partner__c,Dealer_Contact_E_mail_Address__c,
                  List_of_countries_planning_to_sell__c,Language_s_supported_by_the_Product_App__c,Is_this_a_new_or_existing_product__c,Applicant_Job_Title__c, 
                  Intended_PDT_Appl_offered_to_endcustomer__c,How_your_appl_will_influence_the_sales__c,Explanation_about_application__c,Estimated_no_of_appl_sales_per_year__c,
                  Vertical_markets__c,Vertical_market_detail__c,Other_Vertical_Markets_if_any__c,Application_Status__c,What_pre_sale_support_will_be_offered_to__c,What_post_sale_support_will_be_offered__c,What_installation_support_will_be_offere__c,What_MOTOTRBO_systems_that_you_intend__c,What_project_s_the_application_will_be__c,Who_will_be_running_the_application__c,Subscriber_related_developments__c,DIMETRA_IP_Compact_S_W_Release__c,DIMETRA_IP_Micro_or_DIMETRA_LiTE__c,DIMETRA_IP_Scalable_S_W_release__c,Non_Motorola_DIMETRA_IP_S_W_Release__c,Which_APIs_customer_purchase__c,Please_Select_Astro_Radios__c,ASTRO_APX_Radio_Models__c,ASTRO_XTL_Radio_Models__c,ASTRO_XTS_Radio_Models__c,L_Core_Trunking_System_software_release__c,K_Core_Conventional_System_S_W_Release__c,M_Core_System_S_W_Release__c,Astro_Radios__c,ASTRO_P25_S_W_Release_systems__c,Type_of_Product_s_or_End_User_s__c From ADP_Registration__c where Id=:AppID];
                       
          }
     
          return ADPApp;
 
      }
    
    public void VerticalMarketOther(){
        //List<String> MarketValues = new List<String>();
        System.debug('++++++++++++++++++++++++'+ADPApp.Vertical_markets__c);
        if(ADPApp.Vertical_markets__c  == null || ADPApp.Vertical_markets__c == '' ){
        MarketOther= false;
    }

    }
    
    public PageReference nextPage1() {
    
    // Include by Madhavi to fix Membership id issue
    
    if(existsRel==false)
    {
    MPM_ID='';
    ADPApp.Has_Existing_Relationship__c=false;
    }
    String appID;
    ID accId;
    
    ADP_Registration__c app = new ADP_Registration__c();
    
    
    List<ADP_Registration__c> ADPAppList = [Select Id,Application_Status__c from ADP_Registration__c where Partner_Account__r.Partner_Membership_Id__c =: MPM_ID and Partner_Account__r.Partner_Membership_Id__c!='' order by createddate desc];
   
    
     accountList = new List<ID>();        
        
      accountList = SearchForDuplicates.findAccount(MPM_ID);  
      
      system.debug('Account list is ' +accountList);
      
      if(accountList.size() == 0 && existsRel && MPM_ID != null){
          ADPShowAcc = false; // included by madhavi to fix the Account information display issue
          showeMemSum = false;
          HideAccinfo = false;// included by madhavi to fix the Account information display issue
          ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'PartnerEmpower ID is not valid'));
          return null;
      }
       if(accountList.size() > 1 && existsRel && MPM_ID != null){
            HideAccinfo = false;// included by madhavi to fix the Account information display issue
            ADPShowAcc = false; // included by madhavi to fix the Account information display issue
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'More than one account is present for the given Partner Membership ID'));
            return null;
      }
     // included by madhavi to avoid display of inactive accounts
    if(existsRel==true)
    {
    List<Account> accList1 = [Select Id,MPE_Program_Status_New__c,Partner_Membership_Id__c from Account where Partner_Membership_Id__c =: MPM_ID and recordtype.name='Partner' and MPE_Program_Status_New__c='Active' order by createddate desc];
    if(accList1.size()==0)
    {
    ADPShowAcc = false; 
    showeMemSum = false;
    HideAccinfo = false;
    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'PartnerEmpower Account is not Active'));
    return null;
    
    }
   } 
     if(accountList.size() == 1 && existsRel && MPM_ID != null && ADPShowAcc == false )
      
      {
            
            HideAccinfo = true;
            eMemSum = true;
            showeMemSum = true;
            Accs = [SELECT Id, Name,Partner_Account_Name__c, ParentId,Partner_Region__c, Partner_Distributor_email__c FROM Account Where Id = :accountList];
            system.debug('eMemSum ' +eMemSum);
            ADPShowAcc = true;
           
           return null;          
      }  
      
    if(TS == 'None'){
         ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please choose any one of the API Licenses'));
          return null;
    }
    
    if(this.ADPApp.Region_Requested__c== null || this.ADPApp.Region_Requested__c.trim()== '')
        {
            this.ADPApp.Region_Requested__c.addError(System.Label.ADP_Error);
            return null;
        } 

        system.debug('Entering into exitsRel loop');
        
        ADPApp.Application_Status__c = 'New';
        ADPApp.Application_Create_Date__c = date.today();
        ADPApp.Technology_Segment_Interest__c = TS;
        
        if(MPM_ID != null){
        list<Account> acc = [Select Id, Name, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode, 
                             Website, Phone, Fax, ADP_Global_Account_Name1__c from Account where Partner_Membership_Id__c = :MPM_ID];
        if(acc.size() > 0){
        system.debug('Entering into account value map');
        ADPApp.Existing_Partner_Membership_ID__c = MPM_ID;
        ADPApp.Partner_Account__c = acc[0].id;
        ADPApp.Has_Existing_Relationship__c = True;
        ADPApp.Company_Name__c = acc[0].Name;
        ADPApp.Street_Address_1__c = acc[0].BillingStreet;
        ADPApp.City_Town__c = acc[0].BillingCity;
        ADPApp.Country__c = acc[0].BillingCountry;
        ADPApp.Applicant_State_Province__c = acc[0].BillingState;
        ADPApp.Zipcode__c = acc[0].BillingPostalCode;
        ADPApp.Company_Website__c = acc[0].Website;
        ADPApp.Company_Telephone_Number__c = acc[0].Phone;
        ADPApp.ADP_Global_Account_Name1__c = acc[0].ADP_Global_Account_Name1__c;
        }       
        }
        
        insert ADPApp;
        appID = ADPApp.Id;
        
        system.debug('ADP App inserted successfully '+appID);
         
        list<ADP_Lead_Mapping__c> adpLead = new list<ADP_Lead_Mapping__c>();
        adpLead = [select UserID__c from ADP_Lead_Mapping__c where Region__c =:ADPApp.Region_Requested__c and 
                                       Technology__c = :ADPApp.Technology_Segment_Interest__c];                             
        if(adpLead.size() > 0) {
            ADPApp.ADP_Lead__c = adpLead[0].UserID__c;
            update ADPApp;
        }      
  
      
       PageReference p = new PageReference('');
       p = new PageReference('/apex/ADPApplicantInfo?id='+appID+'&skip='+existsRel);
       p.setRedirect(true);
       return p;
       
       
   
   }   
    
    public PageReference nextPage2() {
        
        PageReference p = new PageReference('');
        Partner_Profiles__c pp = new Partner_Profiles__c(); 
        string skippage = ApexPages.currentPage().getParameters().get('skip');
        system.debug('skippage skippage '+skippage );
        
        if(existsRel <> true){
        system.debug('Entering into exitsRel loop'+appID );
        }
        
               
        if(this.ADPApp.Applicant_First_Name__c == null || this.ADPApp.Applicant_First_Name__c.trim()== '')
        {
            this.ADPApp.Applicant_First_Name__c.addError(System.Label.ADP_Error);
            return null;
        }
        else if(this.ADPApp.Applicant_Last_Name__c == null || this.ADPApp.Applicant_Last_Name__c.trim()== '')
        {
            this.ADPApp.Applicant_Last_Name__c.addError(System.Label.ADP_Error);
            return null;
        }
        else if(this.ADPApp.Applicant_Job_Title__c== null || this.ADPApp.Applicant_Job_Title__c.trim()== '')
        {
            
            this.ADPApp.Applicant_Job_Title__c.addError(System.Label.ADP_Error);
            return null;
        }
        else if(this.ADPApp.Applicant_Phone_Number__c== null || this.ADPApp.Applicant_Phone_Number__c.trim()== '')
        {
            this.ADPApp.Applicant_Phone_Number__c.addError(System.Label.ADP_Error);
            return null;
        } 
        else if(this.ADPApp.Applicant_Email_Address__c== null || this.ADPApp.Applicant_Email_Address__c.trim()== '')
        {
            this.ADPApp.Applicant_Email_Address__c.addError(System.Label.ADP_Error);
            return null;
        }
        else
        {   
            string ids=ApexPages.currentPage().getParameters().get('id'); 
            system.debug('starttttttttsssggggvvvvvccc'+ids);
            
            ADPContact__c[] thecont = [select ID, Applicant_First_Name__c, Applicant_Last_Name__c, Applicant_Email_Address__c, Applicant_Primary_Role__c,
                                       Applicant_Phone_Number__c from ADPContact__c where ADP_App_id__c = :ids ];
                                    
             if(thecont.size() == 0 && ADPApp.Applicant_Email_Address__c != null){
             system.debug('Entering into contact insert');
             ADPContact__c cont = new ADPContact__c(); 
             cont.Applicant_First_Name__c = ADPApp.Applicant_First_Name__c;
             cont.Applicant_Last_Name__c = ADPApp.Applicant_Last_Name__c;
             cont.Applicant_Email_Address__c = ADPApp.Applicant_Email_Address__c;
             cont.Applicant_Job_Title__c = ADPApp.Applicant_Job_Title__c;
             cont.Applicant_Phone_Number__c = ADPApp.Applicant_Phone_Number__c;
            // cont.Applicant_Primary_Role__c = 'Executive';
             cont.ADP_App_id__c = ids;
             
             insert cont;
             }
             if(thecont.size() > 0){
                 system.debug('Entering into contact second time update');
                 ADPContact__c cont = new ADPContact__c();
                 cont.id = thecont[0].id;
                 cont.Applicant_First_Name__c = ADPApp.Applicant_First_Name__c;
                 cont.Applicant_Last_Name__c = ADPApp.Applicant_Last_Name__c;
                 cont.Applicant_Email_Address__c = ADPApp.Applicant_Email_Address__c;
                 cont.Applicant_Job_Title__c = ADPApp.Applicant_Job_Title__c;
                 cont.Applicant_Phone_Number__c = ADPApp.Applicant_Phone_Number__c;
                 cont.ADP_App_id__c = ids;
                 
                 update cont;
             }
             
        try {
            upsert ADPApp;
            system.debug('applicant name is '+ADPApp.Applicant_First_Name__c);
            system.debug('applicant detail is '+ADPApp);
            }
            
            catch (System.DmlException e) {
                this.ADPApp.addError(e.getMessage());
                return null;            
            } 
             
        id recordids = ApexPages.currentPage().getParameters().get('id');
         
            p = new PageReference('/apex/ADPCompanyInfo?id='+recordids+'&skip='+skippage); 
            p.setRedirect(true); //durga
            return p;
        }            
    }
    
    
    public PageReference nextPage3() {
    
        string skippage = ApexPages.currentPage().getParameters().get('skip');
        
        if(ADPApp.Has_Existing_Relationship__c == false && (this.ADPApp.Company_Name__c== null || this.ADPApp.Company_Name__c.trim()== ''))
        {
            this.ADPApp.Company_Name__c.addError(System.Label.ADP_Error);
            return null;
        }
        else if(ADPApp.Has_Existing_Relationship__c == false && (this.ADPApp.Company_Website__c== null || this.ADPApp.Company_Website__c.trim()== ''))
        {
            this.ADPApp.Company_Website__c.addError(System.Label.ADP_Error);
            return null;
        }
         else if(ADPApp.Has_Existing_Relationship__c == false && this.ADPApp.Company_Telephone_Number__c== null )
        {
            this.ADPApp.Company_Telephone_Number__c.addError(System.Label.ADP_Error);
            return null;
        }
        else if(ADPApp.Has_Existing_Relationship__c == false && (this.ADPApp.Street_Address_1__c == null || this.ADPApp.Street_Address_1__c.trim()== ''))
        {
            this.ADPApp.Street_Address_1__c.addError(System.Label.ADP_Error);
            return null;
        }
        else if(ADPApp.Has_Existing_Relationship__c == false && (this.ADPApp.Country__c== null || this.ADPApp.Country__c.trim()== ''))
        {
            this.ADPApp.Country__c.addError(System.Label.ADP_Error);
            return null;
        }
        else if(ADPApp.Has_Existing_Relationship__c == false && (this.ADPApp.City_Town__c == null || this.ADPApp.City_Town__c.trim()== ''))
        {
            this.ADPApp.City_Town__c.addError(System.Label.ADP_Error);
            return null;
        }
        else if(ADPApp.Has_Existing_Relationship__c == false && (this.ADPApp.Applicant_State_Province__c== null && (this.ADPApp.Country__c == 'United States' || this.ADPApp.Country__c =='Canada')))
        {
            this.ADPApp.Applicant_State_Province__c.addError(System.Label.ADP_Error);
            return null;
        }
        else if(ADPApp.Has_Existing_Relationship__c == false && this.ADPApp.Zipcode__c== null)
        {
            this.ADPApp.Zipcode__c.addError(System.Label.ADP_Error);
            return null;
        }      
        
        try {
            ADPApp.Application_Status__c = 'New';
            upsert ADPApp;
            
        } catch (System.DmlException e) {
              this.ADPApp.addError(e.getMessage());
              return null;            
        }  
        system.debug('Tech segment is ' +ADPApp.Technology_Segment_Interest__c);
        
        PageReference GeneralInfopage = new PageReference('/apex/ADPGeneralInfo?id='+ApexPages.currentPage().getParameters().get('id')+'&skip='+skippage);
        GeneralInfopage.setRedirect(true);
        return GeneralInfopage;   
    }
    
    public PageReference nextPage4() {
    
        string skippage = ApexPages.currentPage().getParameters().get('skip');
        
         if(this.ADPApp.How_did_you_hear_about_the_program__c== null || this.ADPApp.How_did_you_hear_about_the_program__c.trim()== '')
        {
            this.ADPApp.How_did_you_hear_about_the_program__c.addError(System.Label.ADP_Error);
            return null;
        }  
         else if(this.ADPApp.Have_any_current_customer_opportunities__c== null || this.ADPApp.Have_any_current_customer_opportunities__c.trim()== '')
        {
            this.ADPApp.Have_any_current_customer_opportunities__c.addError(System.Label.ADP_Error);
            return null;
        }
        else if(this.ADPApp.Have_any_current_customer_opportunities__c== 'Yes') 
        {
            if(this.ADPApp.Please_describe_the_scope_of_opportunity__c== null || this.ADPApp.Please_describe_the_scope_of_opportunity__c.trim()== ''){
            this.ADPApp.Please_describe_the_scope_of_opportunity__c.addError(System.Label.ADP_Error);
            return null;
            }
        }
        else if(this.ADPApp.Are_you_working_for_Radio_Dealer__c == null || this.ADPApp.Are_you_working_for_Radio_Dealer__c .trim()== '')
        {
            this.ADPApp.Are_you_working_for_Radio_Dealer__c.addError(System.Label.ADP_Error);
            return null;
        }
        else if(this.ADPApp.Are_you_working_for_Radio_Dealer__c == 'Yes' && (this.ADPApp.Corporate_Name_of_Channel_Partner__c== null||this.ADPApp.Corporate_Name_of_Channel_Partner__c==''))
        {
            this.ADPApp.Corporate_Name_of_Channel_Partner__c.addError(System.Label.ADP_Error);
            return null;
        } 
        else if(this.ADPApp.Are_you_working_for_Radio_Dealer__c == 'Yes' && (this.ADPApp.Contact_Name__c== null || this.ADPApp.Contact_Name__c.trim()== ''))
        {
            this.ADPApp.Contact_Name__c.addError(System.Label.ADP_Error);
            return null;
        } 
        else if(this.ADPApp.Are_you_working_for_Radio_Dealer__c == 'Yes' && (this.ADPApp.Title_of_Contact__c== null || this.ADPApp.Title_of_Contact__c.trim()== ''))
        {
            this.ADPApp.Title_of_Contact__c.addError(System.Label.ADP_Error);
            return null;
        }
        else if(this.ADPApp.Are_you_working_for_Radio_Dealer__c == 'Yes' && (this.ADPApp.Dealer_Contact_E_mail_Address__c== null || this.ADPApp.Dealer_Contact_E_mail_Address__c.trim()== ''))
        {
            this.ADPApp.Dealer_Contact_E_mail_Address__c.addError(System.Label.ADP_Error);
            return null;
        }
        else if(this.ADPApp.Are_you_working_for_Radio_Dealer__c == 'Yes' && (this.ADPApp.Contact_Telephone_Number__c== null || this.ADPApp.Contact_Telephone_Number__c.trim()== ''))
        {
            this.ADPApp.Contact_Telephone_Number__c.addError(System.Label.ADP_Error);
            return null;
        }
        // Included by madhavi to fix General form issues  (13-03-2017)
        if(ADPApp.Have_any_current_customer_opportunities__c=='No' && ADPApp.Please_describe_the_scope_of_opportunity__c!=null)
        ADPApp.Please_describe_the_scope_of_opportunity__c='';
        if(ADPApp.Are_you_working_for_Radio_Dealer__c=='No')
        {
        ADPApp.Contact_Telephone_Number__c='';
        ADPApp.Dealer_Contact_E_mail_Address__c='';
        ADPApp.Title_of_Contact__c='';
        ADPApp.Contact_Name__c='';
        ADPApp.Corporate_Name_of_Channel_Partner__c='';
        }
        
        try {
            ADPApp.Application_Status__c = 'New';
            upsert ADPApp;
            
        } catch (System.DmlException e) {
            this.ADPApp.addError(e.getMessage());
          return null;            
        }  
        
        system.debug('Tech segment is ' +ADPApp.Technology_Segment_Interest__c);
        PageReference ProductApplpage = new PageReference('/apex/ADPProductApplication?id='+ApexPages.currentPage().getParameters().get('id')+'&skip='+skippage);
        ProductApplpage.setredirect(true);
        return ProductApplpage;
        
    } 
    
    public PageReference nextPage5() {
    
        string skippage = ApexPages.currentPage().getParameters().get('skip');
    
        if(this.ADPApp.Product_Application_Name__c== null || this.ADPApp.Product_Application_Name__c.trim()== '')
        {
            this.ADPApp.Product_Application_Name__c.addError(System.Label.ADP_Error);
            return null;
        }
        else if(this.ADPApp.Is_this_a_new_or_existing_product__c== null || this.ADPApp.Is_this_a_new_or_existing_product__c.trim()== '')
        {
            this.ADPApp.Is_this_a_new_or_existing_product__c.addError(System.Label.ADP_Error);
            return null;
        }
        else if(this.ADPApp.Product_Description__c== null || this.ADPApp.Product_Description__c.trim()== '')
        {
            this.ADPApp.Product_Description__c.addError(System.Label.ADP_Error);
            return null;
        }
        else if(this.ADPApp.Purpose_of_the_Product_Application__c== null || this.ADPApp.Purpose_of_the_Product_Application__c.trim()== '')
        {
            this.ADPApp.Purpose_of_the_Product_Application__c.addError(System.Label.ADP_Error);
            return null;
        }
        else if(this.ADPApp.Product_Feature_and_Functionalities__c== null || this.ADPApp.Product_Feature_and_Functionalities__c.trim()== '')
        {
            this.ADPApp.Product_Feature_and_Functionalities__c.addError(System.Label.ADP_Error);
            return null;
        }
        else if(this.ADPApp.Language_s_supported_by_the_Product_App__c== null || this.ADPApp.Language_s_supported_by_the_Product_App__c.trim()== '')
        {
            this.ADPApp.Language_s_supported_by_the_Product_App__c.addError(System.Label.ADP_Error);
            return null;
        }

        try {
            ADPApp.Application_Status__c = 'New';
            upsert ADPApp;
            
        } catch (System.DmlException e) {
            this.ADPApp.addError(e.getMessage());
          return null;            
        }  
        
        PageReference ADPProductSalespage = new PageReference('/apex/ADPProductPositionSales?id='+ADPApp.id+'&skip='+skippage);
        ADPProductSalespage.setRedirect(true);
        return ADPProductSalespage;
    }
        
    
    public PageReference nextPage6() {
    
        string skippage = ApexPages.currentPage().getParameters().get('skip');
    
        if(this.ADPApp.Regions_you_will_be_positioning_products__c== null || this.ADPApp.Regions_you_will_be_positioning_products__c.trim()== '')
        {
            this.ADPApp.Regions_you_will_be_positioning_products__c.addError(System.Label.ADP_Error);
            return null;
        }
        else if(this.ADPApp.Vertical_markets__c== null || this.ADPApp.Vertical_markets__c.trim()== '')
        {
            this.ADPApp.Vertical_markets__c.addError(System.Label.ADP_Error);
            return null;
        }
        else if(this.ADPApp.Vertical_markets__c.contains('Other') && (this.ADPApp.Other_Vertical_Markets_if_any__c == null || this.ADPApp.Other_Vertical_Markets_if_any__c == ''))
        {
            system.debug('Entering into contains other loop');
            this.ADPApp.Other_Vertical_Markets_if_any__c.addError(System.Label.ADP_Error);
            return null;
        } 
        else if(this.ADPApp.Vertical_market_detail__c== null || this.ADPApp.Vertical_market_detail__c.trim()== '')
        {
            this.ADPApp.Vertical_market_detail__c.addError(System.Label.ADP_Error);
            return null;
        }
        else if(this.ADPApp.Intended_PDT_Appl_offered_to_endcustomer__c== null || this.ADPApp.Intended_PDT_Appl_offered_to_endcustomer__c.trim()== '')
        {
            this.ADPApp.Intended_PDT_Appl_offered_to_endcustomer__c.addError(System.Label.ADP_Error);
            return null;
        }
        else if(this.ADPApp.Explanation_about_application__c== null || this.ADPApp.Explanation_about_application__c.trim()== '')
        {
            this.ADPApp.Explanation_about_application__c.addError(System.Label.ADP_Error);
            return null;
        }
        else if(this.ADPApp.How_your_appl_will_influence_the_sales__c== null || this.ADPApp.How_your_appl_will_influence_the_sales__c.trim()== '')
        {
            this.ADPApp.How_your_appl_will_influence_the_sales__c.addError(System.Label.ADP_Error);
            return null;
        }
        else if(this.ADPApp.Vertical_markets__c!= null){
           tmpString = new Set<String> (this.ADPApp.Vertical_markets__c.split(';'));
           system.debug('selection is ' +tmpString);
           system.debug('count of selection is ' +tmpString.size());
           if(tmpString.size()>3){
                this.ADPApp.Vertical_markets__c.addError('Choose only three main vertical markets');
            return null;
            }
        }
      //Included by madhavi to fix Product Position sales form issues  (13-03-2017)
      if(ADPApp.Vertical_markets__c!=null && (!ADPApp.Vertical_markets__c.contains('Other')) && ADPApp.Other_Vertical_Markets_if_any__c!=null)
        {
        ADPApp.Other_Vertical_Markets_if_any__c='';
        }
      
       
       //Added by madhavi to include new form changes (03-02-2017)        
     
        
        try {
            upsert ADPApp;
            
        } catch (System.DmlException e) {
            this.ADPApp.addError(e.getMessage());
          return null;            
        }  
     
      if(ADPApp.Technology_Segment_Interest__c=='MOTOTRBO') 
      {
       
      PageReference pg= new PageReference('/apex/ADPProductMototrboDetails?id='+ADPApp.id+'&skip='+skippage);
      pg.setRedirect(true);
      return pg;
      }
      if(ADPApp.Technology_Segment_Interest__c=='DIMETRA') 
      {
      PageReference pg= new PageReference('/apex/ADPProductDimetraDetails?id='+ADPApp.id+'&skip='+skippage);
      pg.setRedirect(true);
      return pg;
      }
       if(ADPApp.Technology_Segment_Interest__c=='ASTRO') 
      {
      PageReference pg= new PageReference('/apex/ADPProductAstroDetails?id='+ADPApp.id+'&skip='+skippage);
      pg.setRedirect(true);
      return pg;
      }
      else
       {
        ADPApp.Application_Status__c = 'Submit';
        update ADPApp; 
        PageReference SubmitPage = new PageReference('/apex/ADPRegistrationThankyouPage?AppThankyou=1&id='+ApexPages.currentPage().getParameters().get('id')+'&skip='+skippage);
        SubmitPage.setRedirect(true);
        
       return SubmitPage;
       
       
       }
        
    }
    
    //Added by madhavi to include new form changes (03-02-2017)  
     public PageReference nextPage7() {
    
        string skippage = ApexPages.currentPage().getParameters().get('skip');
        if(this.ADPApp.What_MOTOTRBO_systems_that_you_intend__c== null || this.ADPApp.What_MOTOTRBO_systems_that_you_intend__c.trim()== '')
        {
            this.ADPApp.What_MOTOTRBO_systems_that_you_intend__c.addError(System.Label.ADP_Error);
            return null;
        }
         else if(this.ADPApp.What_pre_sale_support_will_be_offered_to__c== null || this.ADPApp.What_pre_sale_support_will_be_offered_to__c.trim()== '')
        {
            this.ADPApp.What_pre_sale_support_will_be_offered_to__c.addError(System.Label.ADP_Error);
            return null;
        } 
        
        else if(this.ADPApp.What_installation_support_will_be_offere__c== null || this.ADPApp.What_installation_support_will_be_offere__c.trim()== '')
        {
            this.ADPApp.What_installation_support_will_be_offere__c.addError(System.Label.ADP_Error);
            return null;
        }
        else if(this.ADPApp.What_post_sale_support_will_be_offered__c== null || this.ADPApp.What_post_sale_support_will_be_offered__c.trim()== '')
        {
            this.ADPApp.What_post_sale_support_will_be_offered__c.addError(System.Label.ADP_Error);
            return null;
        }   
        
        ADPApp.Application_Status__c = 'Submit';
        
        try {
            upsert ADPApp;
            
        } catch (System.DmlException e) {
            this.ADPApp.addError(e.getMessage());
          return null;            
        }  
        
        PageReference SubmitPage = new PageReference('/apex/ADPRegistrationThankyouPage?AppThankyou=1&id='+ApexPages.currentPage().getParameters().get('id')+'&skip='+skippage);
        SubmitPage.setRedirect(true);
        return SubmitPage;
        
    }
    
    //Added by madhavi to include new form changes (03-02-2017)  
     public PageReference nextPage8() {
    
        string skippage = ApexPages.currentPage().getParameters().get('skip');
       if(this.ADPApp.Type_of_Product_s_or_End_User_s__c== null || this.ADPApp.Type_of_Product_s_or_End_User_s__c.trim()== '')
        {
            this.ADPApp.Type_of_Product_s_or_End_User_s__c.addError(System.Label.ADP_Error);
            return null;
        }   
      
      else if(this.ADPApp.Type_of_Product_s_or_End_User_s__c=='Project' && (this.ADPApp.What_project_s_the_application_will_be__c== null || this.ADPApp.What_project_s_the_application_will_be__c.trim()== ''))
        {
            this.ADPApp.What_project_s_the_application_will_be__c.addError(System.Label.ADP_Error);
            return null;
        }
         else if(this.ADPApp.Type_of_Product_s_or_End_User_s__c=='End User' && (this.ADPApp.Who_will_be_running_the_application__c== null || this.ADPApp.Who_will_be_running_the_application__c.trim()== ''))
        {
            this.ADPApp.Who_will_be_running_the_application__c.addError(System.Label.ADP_Error);
            return null;
        }
       
        ADPApp.Tetra_Systems_List__c='';
     if(chkBx1==false && chkBx2==false && chkBx3==false && chkBx4==false &&  chkBx16==false)
     {
       ADPApp.Tetra_Systems_List__c='';
       ADPApp.DIMETRA_IP_Scalable_S_W_release__c='';    
       ADPApp.DIMETRA_IP_Compact_S_W_Release__c='';
       ADPApp.DIMETRA_IP_Micro_or_DIMETRA_LiTE__c='';  
       ADPApp.Non_Motorola_DIMETRA_IP_S_W_Release__c=''; 
       ADPApp.Subscriber_related_developments__c='';
     }
     if(chkBx1==true)
     {
     
     system.debug('test1'+ADPApp.Tetra_Systems_List__c);
        
     ADPApp.Tetra_Systems_List__c='DIMETRA IP Scalable System';
     }
     else if(chkBx1==false)
     {
     ADPApp.Tetra_Systems_List__c='';
     ADPApp.DIMETRA_IP_Scalable_S_W_release__c='';
     }
     if(chkBx2==true && ADPApp.Tetra_Systems_List__c !=null)
     {
     system.debug('test2'+ADPApp.Tetra_Systems_List__c);
     ADPApp.Tetra_Systems_List__c=ADPApp.Tetra_Systems_List__c+';'+'DIMETRA IP Compact';
     }
     else if(chkBx2==true && ADPApp.Tetra_Systems_List__c ==null)
     ADPApp.Tetra_Systems_List__c='DIMETRA IP Compact';
     else if(chkBx2==false)
     {
     ADPApp.Tetra_Systems_List__c=ADPApp.Tetra_Systems_List__c;
     ADPApp.DIMETRA_IP_Compact_S_W_Release__c='';
     }
     if(chkBx3==true && ADPApp.Tetra_Systems_List__c !=null)
     {
     system.debug('test3'+ADPApp.Tetra_Systems_List__c);
     ADPApp.Tetra_Systems_List__c=ADPApp.Tetra_Systems_List__c+';'+'DIMETRA IP Micro or DIMETRA LiTE';
     }
     else if(chkBx3==true && ADPApp.Tetra_Systems_List__c ==null)
     ADPApp.Tetra_Systems_List__c='DIMETRA IP Micro or DIMETRA LiTE';
     else if(chkBx3==false)
     {
     ADPApp.Tetra_Systems_List__c=ADPApp.Tetra_Systems_List__c;
     ADPApp.DIMETRA_IP_Micro_or_DIMETRA_LiTE__c='';
     }
     if(chkBx4==true && ADPApp.Tetra_Systems_List__c !=null)
     {
     system.debug('test4'+ADPApp.Tetra_Systems_List__c);
     ADPApp.Tetra_Systems_List__c=ADPApp.Tetra_Systems_List__c+';'+'Non-Motorola DIMETRA IP system';
     }
     else if(chkBx4==true && ADPApp.Tetra_Systems_List__c ==null)
     ADPApp.Tetra_Systems_List__c='Non-Motorola DIMETRA IP system';
     else if(chkBx4==false)
     {
     ADPApp.Tetra_Systems_List__c=ADPApp.Tetra_Systems_List__c;
     ADPApp.Non_Motorola_DIMETRA_IP_S_W_Release__c='';
     }    
     if(chkBx16==true && ADPApp.Tetra_Systems_List__c !=null)
     {
     
     ADPApp.Tetra_Systems_List__c=ADPApp.Tetra_Systems_List__c+';'+'Not Applicable';
     }
     else if(chkBx16==true && ADPApp.Tetra_Systems_List__c ==null)
     ADPApp.Tetra_Systems_List__c='Not Applicable';
     else if(chkBx16==false)
     {
     ADPApp.Tetra_Systems_List__c=ADPApp.Tetra_Systems_List__c;
     ADPApp.Subscriber_related_developments__c='';
     }    
     
     if(ADPApp.Type_of_Product_s_or_End_User_s__c=='Project')
        ADPApp.Who_will_be_running_the_application__c='';
        
     if(ADPApp.Type_of_Product_s_or_End_User_s__c=='End User')
        ADPApp.What_project_s_the_application_will_be__c='';
     
     ADPApp.Application_Status__c = 'Submit';   
        
        try {
             
            upsert ADPApp;
            
            
        } catch (System.DmlException e) {
            this.ADPApp.addError(e.getMessage());
          return null;            
        }  
        
       PageReference SubmitPage = new PageReference('/apex/ADPRegistrationThankyouPage?AppThankyou=1&id='+ApexPages.currentPage().getParameters().get('id')+'&skip='+skippage);
        SubmitPage.setRedirect(true);
        return SubmitPage; 
        
    }
    //Added by madhavi to include new form changes (03-02-2017) 
    public PageReference nextPage9() {
    
        string skippage = ApexPages.currentPage().getParameters().get('skip');
      
        if(this.ADPApp.Which_APIs_customer_purchase__c== null || this.ADPApp.Which_APIs_customer_purchase__c.trim()== '')
        {
            this.ADPApp.Which_APIs_customer_purchase__c.addError(System.Label.ADP_Error);
            return null;
        }
          
        ADPApp.ASTRO_P25_S_W_Release_systems__c='';
        if(chkBx5==false && chkBx6==false && chkBx7==false)
     {
       ADPApp.ASTRO_P25_S_W_Release_systems__c='';
       ADPApp.L_Core_Trunking_System_software_release__c='';    
       ADPApp.K_Core_Conventional_System_S_W_Release__c='';
       ADPApp.M_Core_System_S_W_Release__c='';  
        
     }
     if(chkBx5==true)
     {
     
     
        
     ADPApp.ASTRO_P25_S_W_Release_systems__c='L Core Trunking System';
     }
     else if(chkBx5==false)
     {
     ADPApp.ASTRO_P25_S_W_Release_systems__c='';
     ADPApp.L_Core_Trunking_System_software_release__c='';
     }
     if(chkBx6==true && ADPApp.ASTRO_P25_S_W_Release_systems__c !=null)
     {
     system.debug('test2'+ADPApp.ASTRO_P25_S_W_Release_systems__c);
     ADPApp.ASTRO_P25_S_W_Release_systems__c=ADPApp.ASTRO_P25_S_W_Release_systems__c+';'+'K Core Conventional System';
     }
     else if(chkBx6==true && ADPApp.ASTRO_P25_S_W_Release_systems__c ==null)
     ADPApp.ASTRO_P25_S_W_Release_systems__c='K Core Conventional System';
     else if(chkBx6==false)
     {
     ADPApp.ASTRO_P25_S_W_Release_systems__c=ADPApp.ASTRO_P25_S_W_Release_systems__c;
     ADPApp.K_Core_Conventional_System_S_W_Release__c='';
     }
     if(chkBx7==true && ADPApp.ASTRO_P25_S_W_Release_systems__c !=null)
     {
     system.debug('test3'+ADPApp.ASTRO_P25_S_W_Release_systems__c);
     ADPApp.ASTRO_P25_S_W_Release_systems__c=ADPApp.ASTRO_P25_S_W_Release_systems__c+';'+'M Core System';
     }
     else if(chkBx7==true && ADPApp.ASTRO_P25_S_W_Release_systems__c ==null)
     ADPApp.ASTRO_P25_S_W_Release_systems__c='M Core System';
     else if(chkBx7==false)
     {
     ADPApp.ASTRO_P25_S_W_Release_systems__c=ADPApp.ASTRO_P25_S_W_Release_systems__c;
     ADPApp.M_Core_System_S_W_Release__c='';
     }
        
          ADPApp.Astro_Radios__c='';
       
        if(chkBx8==false && chkBx9==false && chkBx10==false)
     {
       ADPApp.Astro_Radios__c='';
       ADPApp.ASTRO_APX_Radio_Models__c='';    
       ADPApp.ASTRO_XTS_Radio_Models__c='';
       ADPApp.ASTRO_XTL_Radio_Models__c='';  
        
     }
     if(chkBx8==true)
     {
      
     ADPApp.Astro_Radios__c='ASTRO APX Radio';
     }
     else if(chkBx8==false)
     {
     ADPApp.Astro_Radios__c='';
     ADPApp.ASTRO_APX_Radio_Models__c='';
     }
     if(chkBx9==true && ADPApp.Astro_Radios__c !=null)
     {
     system.debug('test2'+ADPApp.Astro_Radios__c);
     ADPApp.Astro_Radios__c=ADPApp.Astro_Radios__c+';'+'ASTRO XTS Radio';
     }
     else if(chkBx9==true && ADPApp.Astro_Radios__c ==null)
     ADPApp.Astro_Radios__c='ASTRO XTS Radio';
     else if(chkBx9==false)
     {
     ADPApp.Astro_Radios__c=ADPApp.Astro_Radios__c;
     ADPApp.ASTRO_XTS_Radio_Models__c='';
     }
     if(chkBx10==true && ADPApp.Astro_Radios__c !=null)
     {
     system.debug('test3'+ADPApp.Astro_Radios__c);
     ADPApp.Astro_Radios__c=ADPApp.Astro_Radios__c+';'+'ASTRO XTL Radio';
     }
     else if(chkBx10==true && ADPApp.Astro_Radios__c ==null)
     ADPApp.Astro_Radios__c='ASTRO XTL Radio';
     else if(chkBx10==false)
     {
     ADPApp.Astro_Radios__c=ADPApp.Astro_Radios__c;
     ADPApp.ASTRO_XTL_Radio_Models__c='';
     } 
     
     
    // logic for Please_Select_Astro_Radios__c multi select picklist (13-02-2017))
    
     ADPApp.Please_Select_Astro_Radios__c='';
      if(chkBx11==false && chkBx12==false && chkBx13==false && chkBx14==false && chkBx15==false)
     {
      ADPApp.Please_Select_Astro_Radios__c='';
     }
     if(chkBx11==true)
     {
      ADPApp.Please_Select_Astro_Radios__c='Direct or Tactical Mode';
     }
     else if(chkBx11==false)
     {
     ADPApp.Please_Select_Astro_Radios__c='';
     }
     if(chkBx12==true && ADPApp.Please_Select_Astro_Radios__c !=null)
     {
     ADPApp.Please_Select_Astro_Radios__c=ADPApp.Please_Select_Astro_Radios__c+';'+'Repeater Mode';
     }
     else if(chkBx12==true && ADPApp.Please_Select_Astro_Radios__c ==null)
     ADPApp.Please_Select_Astro_Radios__c='Repeater Mode';
     else if(chkBx12==false)
     {
     ADPApp.Please_Select_Astro_Radios__c=ADPApp.Please_Select_Astro_Radios__c;
     }
     if(chkBx13==true && ADPApp.Please_Select_Astro_Radios__c !=null)
     {
     ADPApp.Please_Select_Astro_Radios__c=ADPApp.Please_Select_Astro_Radios__c+';'+'Fixed Network Equipment (FNE) Mode';
     }
     else if(chkBx13==true && ADPApp.Please_Select_Astro_Radios__c ==null)
     ADPApp.Please_Select_Astro_Radios__c='Fixed Network Equipment (FNE) Mode';
     else if(chkBx13==false)
     {
     ADPApp.Please_Select_Astro_Radios__c=ADPApp.Please_Select_Astro_Radios__c;
     }
     if(chkBx14==true && ADPApp.Please_Select_Astro_Radios__c !=null)
     {
     ADPApp.Please_Select_Astro_Radios__c=ADPApp.Please_Select_Astro_Radios__c+';'+'Smartnet & Mixed Mode 4.1';
     }
     else if(chkBx14==true && ADPApp.Please_Select_Astro_Radios__c ==null)
     ADPApp.Please_Select_Astro_Radios__c='Smartnet & Mixed Mode 4.1';
     else if(chkBx14==false)
     {
     ADPApp.Please_Select_Astro_Radios__c=ADPApp.Please_Select_Astro_Radios__c;
     }
     if(chkBx15==true && ADPApp.Please_Select_Astro_Radios__c !=null)
     {
     ADPApp.Please_Select_Astro_Radios__c=ADPApp.Please_Select_Astro_Radios__c+';'+'ASTRO IV&D or ASTRO P25 Trunking';
     }
     else if(chkBx15==true && ADPApp.Please_Select_Astro_Radios__c ==null)
     ADPApp.Please_Select_Astro_Radios__c='ASTRO IV&D or ASTRO P25 Trunking';
     else if(chkBx15==false)
     {
     ADPApp.ASTRO_P25_S_W_Release_systems__c=ADPApp.ASTRO_P25_S_W_Release_systems__c;
     }
     
     ADPApp.Application_Status__c = 'Submit';
        
        
        try {
            update ADPApp;
            
            
        } catch (System.DmlException e) {
            this.ADPApp.addError(e.getMessage());
          return null;            
        }  
        
      PageReference SubmitPage = new PageReference('/apex/ADPRegistrationThankyouPage?AppThankyou=1&id='+ApexPages.currentPage().getParameters().get('id')+'&skip='+skippage);
        SubmitPage.setRedirect(true);
        return SubmitPage;  
        
    }
    

    
    public PageReference prevpage1() {
        upsert ADPApp;
        return Page.ADPExistingRelationship;
    }
    public PageReference prevpage2() {
        upsert ADPApp;
        return Page.ADPApplicantInfo;
    }
    public PageReference prevpage3()
    {
         // Included by madhavi to fix General form issues  (13-03-2017)
        if(ADPApp.Have_any_current_customer_opportunities__c=='No' && ADPApp.Please_describe_the_scope_of_opportunity__c!=null)
        ADPApp.Please_describe_the_scope_of_opportunity__c='';
        if(ADPApp.Are_you_working_for_Radio_Dealer__c=='No')
        {
        ADPApp.Contact_Telephone_Number__c='';
        ADPApp.Dealer_Contact_E_mail_Address__c='';
        ADPApp.Title_of_Contact__c='';
        ADPApp.Contact_Name__c='';
        ADPApp.Corporate_Name_of_Channel_Partner__c='';
        }
         upsert ADPApp;
         PageReference p = new PageReference('');
         string skippage = ApexPages.currentPage().getParameters().get('skip');
         id recordids = ApexPages.currentPage().getParameters().get('id');
       /*  if(skippage == 'false')
         {system.debug('existsRel existsRel '+skippage );           
          p = new PageReference('/apex/ADPCompanyInfo?id='+recordids+'&skip='+skippage); 
         }else{system.debug('existsRel existsRel '+existsRel );         
          p = new PageReference('/apex/ADPApplicantInfo?id='+recordids+'&skip='+skippage);
         } */
        p = new PageReference('/apex/ADPCompanyInfo?id='+recordids+'&skip='+skippage); 
        system.debug('Company name is '+ADPApp.Company_Name__c);        
        p.setRedirect(true);
        return p;
        
        
    }
    
    public PageReference prevpage4() {
        upsert ADPApp;
        system.debug('Product app name is '+ADPApp.Product_Application_Name__c);
        return Page.ADPGeneralInfo;
    }

    public PageReference prevpage5() {
        //Included by madhavi to fix Product Position sales form issues  (13-03-2017)
        if(ADPApp.Vertical_markets__c!=null && (!ADPApp.Vertical_markets__c.contains('Other')) && ADPApp.Other_Vertical_Markets_if_any__c!=null)
        {
        ADPApp.Other_Vertical_Markets_if_any__c='';
        }
        upsert ADPApp;
        return Page.ADPProductApplication;
    } 
    
    //Added by madhavi to include new form changes (03-02-2017) 
     public PageReference prevpage6() {
        upsert ADPApp;
        return Page.ADPProductPositionSales;
    }     
    
    //Added by madhavi to include new form changes (03-02-2017)
    public PageReference prevpage7() {
    if(ADPApp.Type_of_Product_s_or_End_User_s__c=='Project')
        ADPApp.Who_will_be_running_the_application__c='';
        
        if(ADPApp.Type_of_Product_s_or_End_User_s__c=='End User')
        ADPApp.What_project_s_the_application_will_be__c='';
        
        ADPApp.Tetra_Systems_List__c='';
        if(chkBx1==false && chkBx2==false && chkBx3==false && chkBx4==false &&  chkBx16==false)
     {
       ADPApp.Tetra_Systems_List__c='';
       ADPApp.DIMETRA_IP_Scalable_S_W_release__c='';    
       ADPApp.DIMETRA_IP_Compact_S_W_Release__c='';
       ADPApp.DIMETRA_IP_Micro_or_DIMETRA_LiTE__c='';  
       ADPApp.Non_Motorola_DIMETRA_IP_S_W_Release__c=''; 
       ADPApp.Subscriber_related_developments__c='';
     }
     if(chkBx1==true)
     {
     
     system.debug('test1'+ADPApp.Tetra_Systems_List__c);
        
     ADPApp.Tetra_Systems_List__c='DIMETRA IP Scalable System';
     }
     else if(chkBx1==false)
     {
     ADPApp.Tetra_Systems_List__c='';
     ADPApp.DIMETRA_IP_Scalable_S_W_release__c='';
     }
     if(chkBx2==true && ADPApp.Tetra_Systems_List__c !=null)
     {
     system.debug('test2'+ADPApp.Tetra_Systems_List__c);
     ADPApp.Tetra_Systems_List__c=ADPApp.Tetra_Systems_List__c+';'+'DIMETRA IP Compact';
     }
     else if(chkBx2==true && ADPApp.Tetra_Systems_List__c ==null)
     ADPApp.Tetra_Systems_List__c='DIMETRA IP Compact';
     else if(chkBx2==false)
     {
     ADPApp.Tetra_Systems_List__c=ADPApp.Tetra_Systems_List__c;
     ADPApp.DIMETRA_IP_Compact_S_W_Release__c='';
     }
     if(chkBx3==true && ADPApp.Tetra_Systems_List__c !=null)
     {
     system.debug('test3'+ADPApp.Tetra_Systems_List__c);
     ADPApp.Tetra_Systems_List__c=ADPApp.Tetra_Systems_List__c+';'+'DIMETRA IP Micro or DIMETRA LiTE';
     }
     else if(chkBx3==true && ADPApp.Tetra_Systems_List__c ==null)
     ADPApp.Tetra_Systems_List__c='DIMETRA IP Micro or DIMETRA LiTE';
     else if(chkBx3==false)
     {
     ADPApp.Tetra_Systems_List__c=ADPApp.Tetra_Systems_List__c;
     ADPApp.DIMETRA_IP_Micro_or_DIMETRA_LiTE__c='';
     }
     if(chkBx4==true && ADPApp.Tetra_Systems_List__c !=null)
     {
     system.debug('test4'+ADPApp.Tetra_Systems_List__c);
     ADPApp.Tetra_Systems_List__c=ADPApp.Tetra_Systems_List__c+';'+'Non-Motorola DIMETRA IP system';
     }
     else if(chkBx4==true && ADPApp.Tetra_Systems_List__c ==null)
     ADPApp.Tetra_Systems_List__c='Non-Motorola DIMETRA IP system';
     else if(chkBx4==false)
     {
     ADPApp.Tetra_Systems_List__c=ADPApp.Tetra_Systems_List__c;
     ADPApp.Non_Motorola_DIMETRA_IP_S_W_Release__c='';
     } 
     if(chkBx16==true && ADPApp.Tetra_Systems_List__c !=null)
     {
     
     ADPApp.Tetra_Systems_List__c=ADPApp.Tetra_Systems_List__c+';'+'Not Applicable';
     }
     else if(chkBx16==true && ADPApp.Tetra_Systems_List__c ==null)
     ADPApp.Tetra_Systems_List__c='Not Applicable';
     else if(chkBx16==false)
     {
     ADPApp.Tetra_Systems_List__c=ADPApp.Tetra_Systems_List__c;
     ADPApp.Subscriber_related_developments__c='';
     }      
        upsert ADPApp;
        return Page.ADPProductPositionSales;
    }
   
  
    //Added by madhavi to include new form changes (03-02-2017)
  public PageReference prevpage8() {
  
  
  ADPApp.ASTRO_P25_S_W_Release_systems__c='';
        if(chkBx5==false && chkBx6==false && chkBx7==false)
     {
       ADPApp.ASTRO_P25_S_W_Release_systems__c='';
       ADPApp.L_Core_Trunking_System_software_release__c='';    
       ADPApp.K_Core_Conventional_System_S_W_Release__c='';
       ADPApp.M_Core_System_S_W_Release__c='';  
        
     }
     if(chkBx5==true)
     {
     
     
        
     ADPApp.ASTRO_P25_S_W_Release_systems__c='L Core Trunking System';
     }
     else if(chkBx5==false)
     {
     ADPApp.ASTRO_P25_S_W_Release_systems__c='';
     ADPApp.L_Core_Trunking_System_software_release__c='';
     }
     if(chkBx6==true && ADPApp.ASTRO_P25_S_W_Release_systems__c !=null)
     {
     system.debug('test2'+ADPApp.ASTRO_P25_S_W_Release_systems__c);
     ADPApp.ASTRO_P25_S_W_Release_systems__c=ADPApp.ASTRO_P25_S_W_Release_systems__c+';'+'K Core Conventional System';
     }
     else if(chkBx6==true && ADPApp.ASTRO_P25_S_W_Release_systems__c ==null)
     ADPApp.ASTRO_P25_S_W_Release_systems__c='K Core Conventional System';
     else if(chkBx6==false)
     {
     ADPApp.ASTRO_P25_S_W_Release_systems__c=ADPApp.ASTRO_P25_S_W_Release_systems__c;
     ADPApp.K_Core_Conventional_System_S_W_Release__c='';
     }
     if(chkBx7==true && ADPApp.ASTRO_P25_S_W_Release_systems__c !=null)
     {
     system.debug('test3'+ADPApp.ASTRO_P25_S_W_Release_systems__c);
     ADPApp.ASTRO_P25_S_W_Release_systems__c=ADPApp.ASTRO_P25_S_W_Release_systems__c+';'+'M Core System';
     }
     else if(chkBx7==true && ADPApp.ASTRO_P25_S_W_Release_systems__c ==null)
     ADPApp.ASTRO_P25_S_W_Release_systems__c='M Core System';
     else if(chkBx7==false)
     {
     ADPApp.ASTRO_P25_S_W_Release_systems__c=ADPApp.ASTRO_P25_S_W_Release_systems__c;
     ADPApp.M_Core_System_S_W_Release__c='';
     }
     
         
         
          ADPApp.Astro_Radios__c='';
       
       
       
        if(chkBx8==false && chkBx9==false && chkBx10==false)
     {
       ADPApp.Astro_Radios__c='';
       ADPApp.ASTRO_APX_Radio_Models__c='';    
       ADPApp.ASTRO_XTS_Radio_Models__c='';
       ADPApp.ASTRO_XTL_Radio_Models__c='';  
        
     }
     if(chkBx8==true)
     {
     
     
        
     ADPApp.Astro_Radios__c='ASTRO APX Radio';
     }
     else if(chkBx8==false)
     {
     ADPApp.Astro_Radios__c='';
     ADPApp.ASTRO_APX_Radio_Models__c='';
     }
     if(chkBx9==true && ADPApp.Astro_Radios__c !=null)
     {
     system.debug('test2'+ADPApp.Astro_Radios__c);
     ADPApp.Astro_Radios__c=ADPApp.Astro_Radios__c+';'+'ASTRO XTS Radio';
     }
     else if(chkBx9==true && ADPApp.Astro_Radios__c ==null)
     ADPApp.Astro_Radios__c='ASTRO XTS Radio';
     else if(chkBx9==false)
     {
     ADPApp.Astro_Radios__c=ADPApp.Astro_Radios__c;
     ADPApp.ASTRO_XTS_Radio_Models__c='';
     }
     if(chkBx10==true && ADPApp.Astro_Radios__c !=null)
     {
     system.debug('test3'+ADPApp.Astro_Radios__c);
     ADPApp.Astro_Radios__c=ADPApp.Astro_Radios__c+';'+'ASTRO XTL Radio';
     }
     else if(chkBx10==true && ADPApp.Astro_Radios__c ==null)
     ADPApp.Astro_Radios__c='ASTRO XTL Radio';
     else if(chkBx10==false)
     {
     ADPApp.Astro_Radios__c=ADPApp.Astro_Radios__c;
     ADPApp.ASTRO_XTL_Radio_Models__c='';
     } 
     
     // changes included for Please_Select_Astro_Radios__c picklist on 13-02-2017
     
     ADPApp.Please_Select_Astro_Radios__c='';
      if(chkBx11==false && chkBx12==false && chkBx13==false && chkBx14==false && chkBx15==false)
     {
      ADPApp.Please_Select_Astro_Radios__c='';
     }
     if(chkBx11==true)
     {
      ADPApp.Please_Select_Astro_Radios__c='Direct or Tactical Mode';
     }
     else if(chkBx11==false)
     {
     ADPApp.Please_Select_Astro_Radios__c='';
     }
     if(chkBx12==true && ADPApp.Please_Select_Astro_Radios__c !=null)
     {
     ADPApp.Please_Select_Astro_Radios__c=ADPApp.Please_Select_Astro_Radios__c+';'+'Repeater Mode';
     }
     else if(chkBx12==true && ADPApp.Please_Select_Astro_Radios__c ==null)
     ADPApp.Please_Select_Astro_Radios__c='Repeater Mode';
     else if(chkBx12==false)
     {
     ADPApp.Please_Select_Astro_Radios__c=ADPApp.Please_Select_Astro_Radios__c;
     }
     if(chkBx13==true && ADPApp.Please_Select_Astro_Radios__c !=null)
     {
     ADPApp.Please_Select_Astro_Radios__c=ADPApp.Please_Select_Astro_Radios__c+';'+'Fixed Network Equipment (FNE) Mode';
     }
     else if(chkBx13==true && ADPApp.Please_Select_Astro_Radios__c ==null)
     ADPApp.Please_Select_Astro_Radios__c='Fixed Network Equipment (FNE) Mode';
     else if(chkBx13==false)
     {
     ADPApp.Please_Select_Astro_Radios__c=ADPApp.Please_Select_Astro_Radios__c;
     }
     if(chkBx14==true && ADPApp.Please_Select_Astro_Radios__c !=null)
     {
     ADPApp.Please_Select_Astro_Radios__c=ADPApp.Please_Select_Astro_Radios__c+';'+'Smartnet & Mixed Mode 4.1';
     }
     else if(chkBx14==true && ADPApp.Please_Select_Astro_Radios__c ==null)
     ADPApp.Please_Select_Astro_Radios__c='Smartnet & Mixed Mode 4.1';
     else if(chkBx14==false)
     {
     ADPApp.Please_Select_Astro_Radios__c=ADPApp.Please_Select_Astro_Radios__c;
     }
     if(chkBx15==true && ADPApp.Please_Select_Astro_Radios__c !=null)
     {
     ADPApp.Please_Select_Astro_Radios__c=ADPApp.Please_Select_Astro_Radios__c+';'+'ASTRO IV&D or ASTRO P25 Trunking';
     }
     else if(chkBx15==true && ADPApp.Please_Select_Astro_Radios__c ==null)
     ADPApp.Please_Select_Astro_Radios__c='ASTRO IV&D or ASTRO P25 Trunking';
     else if(chkBx15==false)
     {
     ADPApp.ASTRO_P25_S_W_Release_systems__c=ADPApp.ASTRO_P25_S_W_Release_systems__c;
     }
  
  upsert ADPApp;
        return Page.ADPProductPositionSales;
  }
     
   
   public PageReference FinishLater() {
        // Included by madhavi to fix General form issues  (13-03-2017)
        if(ADPApp.Have_any_current_customer_opportunities__c=='No' && ADPApp.Please_describe_the_scope_of_opportunity__c!=null)
        ADPApp.Please_describe_the_scope_of_opportunity__c='';
        if(ADPApp.Are_you_working_for_Radio_Dealer__c=='No')
        {
        ADPApp.Contact_Telephone_Number__c='';
        ADPApp.Dealer_Contact_E_mail_Address__c='';
        ADPApp.Title_of_Contact__c='';
        ADPApp.Contact_Name__c='';
        ADPApp.Corporate_Name_of_Channel_Partner__c='';
        }
        //Included by madhavi to fix Product Position sales form issues  (13-03-2017)
        if(ADPApp.Vertical_markets__c!=null && (!ADPApp.Vertical_markets__c.contains('Other')) && ADPApp.Other_Vertical_Markets_if_any__c!=null)
        {
        ADPApp.Other_Vertical_Markets_if_any__c='';
        } 
        ADPApp.Application_Status__c = 'Pending';
        try {
            upsert ADPApp;
        
        } catch (Exception e) 
          {
            String objectName ='ADP Regitration-'+ADPApp.Id;
            String userName=userInfo.getName();
            datetime myDateTime = datetime.now();
            CreateErrorLog.createErrorRecord(e.getmessage(),objectName,e.getStackTraceString(),userName,myDateTime,e.getTypeName());
            ApexPages.addMessages(e);
            return null;
          }
        
        PageReference FinishLaterPage = new PageReference('/apex/ADPRegistrationThankyouPage?AppFinishLater=1&id='+ADPApp.id);
        FinishLaterPage.setRedirect(true);
        return FinishLaterPage;
        
    }
   
   public PageReference FinishLaterCon()
   {
    system.debug('startttttttt'+ApexPages.currentPage().getParameters().get('id'));
     
        if(this.ADPApp.Applicant_First_Name__c == null || this.ADPApp.Applicant_First_Name__c.trim()== '')
        {
            this.ADPApp.Applicant_First_Name__c.addError(System.Label.ADP_Error);
            return null;
        }else if( this.ADPApp.Applicant_Last_Name__c== ''||this.ADPApp.Applicant_Last_Name__c== null)
        {
            this.ADPApp.Applicant_Last_Name__c.addError(System.Label.ADP_Error);
            return null;
        }else if(this.ADPApp.Applicant_Job_Title__c== null || this.ADPApp.Applicant_Job_Title__c.trim()== '')
        {
            this.ADPApp.Applicant_Job_Title__c.addError(System.Label.ADP_Error);
            return null;
        }else if(this.ADPApp.Applicant_Phone_Number__c== null || this.ADPApp.Applicant_Phone_Number__c.trim()== '')
        {
            this.ADPApp.Applicant_Phone_Number__c.addError(System.Label.ADP_Error);
            return null;
        }
        else if(this.ADPApp.Applicant_Email_Address__c== null || this.ADPApp.Applicant_Email_Address__c.trim()== '')
        {
            this.ADPApp.Applicant_Email_Address__c.addError(System.Label.ADP_Error);
            return null;
        }else
        {  
             string ids=ApexPages.currentPage().getParameters().get('id');  
             
             system.debug('starttttttttsssggggvvvvvccc'+ids);
             ADPContact__c[] thecont= [select ID, Applicant_First_Name__c, Applicant_Last_Name__c, Applicant_Email_Address__c, Applicant_Primary_Role__c,
                                Applicant_Phone_Number__c from ADPContact__c where ADP_App_id__c = :ids ];
                                
             system.debug('thecont is '+thecont);                   
             if(thecont.size() == 0 && ADPApp.Applicant_Email_Address__c != null){
             system.debug('Entering into contact insert');
             ADPContact__c cont = new ADPContact__c(); 
             cont.Applicant_First_Name__c = ADPApp.Applicant_First_Name__c;
             cont.Applicant_Last_Name__c = ADPApp.Applicant_Last_Name__c;
             cont.Applicant_Email_Address__c = ADPApp.Applicant_Email_Address__c;
             cont.Applicant_Job_Title__c = ADPApp.Applicant_Job_Title__c;
             cont.Applicant_Phone_Number__c = ADPApp.Applicant_Phone_Number__c;
             cont.ADP_App_id__c = ids;
             
             insert cont;
             }
        try {
            upsert ADPApp;
            system.debug('Entering into second update');
            
            } catch (System.DmlException e) {
            this.ADPApp.addError(e.getMessage());
              return null;            
            }
        }    
         
        return FinishLater();
    }
    
    public PageReference FinishLaterCompany()
    {
        system.debug('startttttttt'+ApexPages.currentPage().getParameters().get('id'));
        if(ADPApp.Has_Existing_Relationship__c == false && (this.ADPApp.Company_Name__c== null || this.ADPApp.Company_Name__c.trim()== ''))
        {
            this.ADPApp.Company_Name__c.addError(System.Label.ADP_Error);
            return null;
        }
        else if(ADPApp.Has_Existing_Relationship__c == false && (this.ADPApp.Company_Website__c== null || this.ADPApp.Company_Website__c.trim()== ''))
        {
            this.ADPApp.Company_Website__c.addError(System.Label.ADP_Error);
            return null;
        }
         else if(ADPApp.Has_Existing_Relationship__c == false && this.ADPApp.Company_Telephone_Number__c== null )
        {
            this.ADPApp.Company_Telephone_Number__c.addError(System.Label.ADP_Error);
            return null;
        }
        else if(ADPApp.Has_Existing_Relationship__c == false && (this.ADPApp.Street_Address_1__c == null || this.ADPApp.Street_Address_1__c.trim()== ''))
        {
            this.ADPApp.Street_Address_1__c.addError(System.Label.ADP_Error);
            return null;
        }
        else if(ADPApp.Has_Existing_Relationship__c == false && (this.ADPApp.Country__c== null || this.ADPApp.Country__c.trim()== ''))
        {
            this.ADPApp.Country__c.addError(System.Label.ADP_Error);
            return null;
        }
        else if(ADPApp.Has_Existing_Relationship__c == false && (this.ADPApp.City_Town__c == null || this.ADPApp.City_Town__c.trim()== ''))
        {
            this.ADPApp.City_Town__c.addError(System.Label.ADP_Error);
            return null;
        }
        else if(ADPApp.Has_Existing_Relationship__c == false && (this.ADPApp.Applicant_State_Province__c== null && (this.ADPApp.Country__c == 'United States' || this.ADPApp.Country__c =='Canada')))
        {
            this.ADPApp.Applicant_State_Province__c.addError(System.Label.ADP_Error);
            return null;
        }
        else if(ADPApp.Has_Existing_Relationship__c == false && this.ADPApp.Zipcode__c== null)
        {
            this.ADPApp.Zipcode__c.addError(System.Label.ADP_Error);
            return null;
        }
        return FinishLater();
        
    }
    
    
    
    //Added by madhavi to include new form changes (03-02-2017)
    
    public PageReference FinishLaterDimetra() {
  
        ADPApp.Application_Status__c = 'Pending';
        if(ADPApp.Type_of_Product_s_or_End_User_s__c=='Project')
        ADPApp.Who_will_be_running_the_application__c='';
        
        if(ADPApp.Type_of_Product_s_or_End_User_s__c=='End User')
        ADPApp.What_project_s_the_application_will_be__c='';
        
        if(ADPApp.Technology_Segment_Interest__c=='DIMETRA') 
        {
           ADPApp.Tetra_Systems_List__c='';
           if(chkBx1==false && chkBx2==false && chkBx3==false && chkBx4==false &&  chkBx16==false)
     {
       ADPApp.Tetra_Systems_List__c='';
       ADPApp.DIMETRA_IP_Scalable_S_W_release__c='';    
       ADPApp.DIMETRA_IP_Compact_S_W_Release__c='';
       ADPApp.DIMETRA_IP_Micro_or_DIMETRA_LiTE__c='';  
       ADPApp.Non_Motorola_DIMETRA_IP_S_W_Release__c=''; 
       ADPApp.Subscriber_related_developments__c='';
     }
     if(chkBx1==true)
     {
     
     system.debug('test1'+ADPApp.Tetra_Systems_List__c);
        
     ADPApp.Tetra_Systems_List__c='DIMETRA IP Scalable System';
     }
     else if(chkBx1==false)
     {
     ADPApp.Tetra_Systems_List__c='';
     ADPApp.DIMETRA_IP_Scalable_S_W_release__c='';
     }
     if(chkBx2==true && ADPApp.Tetra_Systems_List__c !=null)
     {
     system.debug('test2'+ADPApp.Tetra_Systems_List__c);
     ADPApp.Tetra_Systems_List__c=ADPApp.Tetra_Systems_List__c+';'+'DIMETRA IP Compact';
     }
     else if(chkBx2==true && ADPApp.Tetra_Systems_List__c ==null)
     ADPApp.Tetra_Systems_List__c='DIMETRA IP Compact';
     else if(chkBx2==false)
     {
     ADPApp.Tetra_Systems_List__c=ADPApp.Tetra_Systems_List__c;
     ADPApp.DIMETRA_IP_Compact_S_W_Release__c='';
     }
     if(chkBx3==true && ADPApp.Tetra_Systems_List__c !=null)
     {
     system.debug('test3'+ADPApp.Tetra_Systems_List__c);
     ADPApp.Tetra_Systems_List__c=ADPApp.Tetra_Systems_List__c+';'+'DIMETRA IP Micro or DIMETRA LiTE';
     }
     else if(chkBx3==true && ADPApp.Tetra_Systems_List__c ==null)
     ADPApp.Tetra_Systems_List__c='DIMETRA IP Micro or DIMETRA LiTE';
     else if(chkBx3==false)
     {
     ADPApp.Tetra_Systems_List__c=ADPApp.Tetra_Systems_List__c;
     ADPApp.DIMETRA_IP_Micro_or_DIMETRA_LiTE__c='';
     }
     if(chkBx4==true && ADPApp.Tetra_Systems_List__c !=null)
     {
     system.debug('test4'+ADPApp.Tetra_Systems_List__c);
     ADPApp.Tetra_Systems_List__c=ADPApp.Tetra_Systems_List__c+';'+'Non-Motorola DIMETRA IP system';
     }
     else if(chkBx4==true && ADPApp.Tetra_Systems_List__c ==null)
     ADPApp.Tetra_Systems_List__c='Non-Motorola DIMETRA IP system';
     else if(chkBx4==false)
     {
     ADPApp.Tetra_Systems_List__c=ADPApp.Tetra_Systems_List__c;
     ADPApp.Non_Motorola_DIMETRA_IP_S_W_Release__c='';
     }    
     if(chkBx16==true && ADPApp.Tetra_Systems_List__c !=null)
     {
     
     ADPApp.Tetra_Systems_List__c=ADPApp.Tetra_Systems_List__c+';'+'Not Applicable';
     }
     else if(chkBx16==true && ADPApp.Tetra_Systems_List__c ==null)
     ADPApp.Tetra_Systems_List__c='Not Applicable';
     else if(chkBx16==false)
     {
     ADPApp.Tetra_Systems_List__c=ADPApp.Tetra_Systems_List__c;
     ADPApp.Subscriber_related_developments__c='';
     }   
            
            
         }   
            
        
        
        try {
            
            upsert ADPApp;
        
        } 
        
        catch (Exception e) 
          {
            String objectName ='ADP Regitration-'+ADPApp.Id;
            String userName=userInfo.getName();
            datetime myDateTime = datetime.now();
            CreateErrorLog.createErrorRecord(e.getmessage(),objectName,e.getStackTraceString(),userName,myDateTime,e.getTypeName());
            ApexPages.addMessages(e);
            return null;
          }
        
        PageReference FinishLaterPage = new PageReference('/apex/ADPRegistrationThankyouPage?AppFinishLater=1&id='+ADPApp.id);
        FinishLaterPage.setRedirect(true);
        return FinishLaterPage;
        
    }
    
     //Added by madhavi to include new form changes (03-02-2017)
    public PageReference FinishLaterAstro() {
    
        ADPApp.Application_Status__c = 'Pending';
        ADPApp.ASTRO_P25_S_W_Release_systems__c='';
        if(chkBx5==false && chkBx6==false && chkBx7==false)
     {
       ADPApp.ASTRO_P25_S_W_Release_systems__c='';
       ADPApp.L_Core_Trunking_System_software_release__c='';    
       ADPApp.K_Core_Conventional_System_S_W_Release__c='';
       ADPApp.M_Core_System_S_W_Release__c='';  
        
     }
     if(chkBx5==true)
     {
     
     
        
     ADPApp.ASTRO_P25_S_W_Release_systems__c='L Core Trunking System';
     }
     else if(chkBx5==false)
     {
     ADPApp.ASTRO_P25_S_W_Release_systems__c='';
     ADPApp.L_Core_Trunking_System_software_release__c='';
     }
     if(chkBx6==true && ADPApp.ASTRO_P25_S_W_Release_systems__c !=null)
     {
     system.debug('test2'+ADPApp.ASTRO_P25_S_W_Release_systems__c);
     ADPApp.ASTRO_P25_S_W_Release_systems__c=ADPApp.ASTRO_P25_S_W_Release_systems__c+';'+'K Core Conventional System';
     }
     else if(chkBx6==true && ADPApp.ASTRO_P25_S_W_Release_systems__c ==null)
     ADPApp.ASTRO_P25_S_W_Release_systems__c='K Core Conventional System';
     else if(chkBx6==false)
     {
     ADPApp.ASTRO_P25_S_W_Release_systems__c=ADPApp.ASTRO_P25_S_W_Release_systems__c;
     ADPApp.K_Core_Conventional_System_S_W_Release__c='';
     }
     if(chkBx7==true && ADPApp.ASTRO_P25_S_W_Release_systems__c !=null)
     {
     system.debug('test3'+ADPApp.ASTRO_P25_S_W_Release_systems__c);
     ADPApp.ASTRO_P25_S_W_Release_systems__c=ADPApp.ASTRO_P25_S_W_Release_systems__c+';'+'M Core System';
     }
     else if(chkBx7==true && ADPApp.ASTRO_P25_S_W_Release_systems__c ==null)
     ADPApp.ASTRO_P25_S_W_Release_systems__c='M Core System';
     else if(chkBx7==false)
     {
     ADPApp.ASTRO_P25_S_W_Release_systems__c=ADPApp.ASTRO_P25_S_W_Release_systems__c;
     ADPApp.M_Core_System_S_W_Release__c='';
     }
     
         
         
          ADPApp.Astro_Radios__c='';
       
       
       
        if(chkBx8==false && chkBx9==false && chkBx10==false)
     {
       ADPApp.Astro_Radios__c='';
       ADPApp.ASTRO_APX_Radio_Models__c='';    
       ADPApp.ASTRO_XTS_Radio_Models__c='';
       ADPApp.ASTRO_XTL_Radio_Models__c='';  
        
     }
     if(chkBx8==true)
     {
     
     
        
     ADPApp.Astro_Radios__c='ASTRO APX Radio';
     }
     else if(chkBx8==false)
     {
     ADPApp.Astro_Radios__c='';
     ADPApp.ASTRO_APX_Radio_Models__c='';
     }
     if(chkBx9==true && ADPApp.Astro_Radios__c !=null)
     {
     system.debug('test2'+ADPApp.Astro_Radios__c);
     ADPApp.Astro_Radios__c=ADPApp.Astro_Radios__c+';'+'ASTRO XTS Radio';
     }
     else if(chkBx9==true && ADPApp.Astro_Radios__c ==null)
     ADPApp.Astro_Radios__c='ASTRO XTS Radio';
     else if(chkBx9==false)
     {
     ADPApp.Astro_Radios__c=ADPApp.Astro_Radios__c;
     ADPApp.ASTRO_XTS_Radio_Models__c='';
     }
     if(chkBx10==true && ADPApp.Astro_Radios__c !=null)
     {
     system.debug('test3'+ADPApp.Astro_Radios__c);
     ADPApp.Astro_Radios__c=ADPApp.Astro_Radios__c+';'+'ASTRO XTL Radio';
     }
     else if(chkBx10==true && ADPApp.Astro_Radios__c ==null)
     ADPApp.Astro_Radios__c='ASTRO XTL Radio';
     else if(chkBx10==false)
     {
     ADPApp.Astro_Radios__c=ADPApp.Astro_Radios__c;
     ADPApp.ASTRO_XTL_Radio_Models__c='';
     } 
     
       // changes included for Please_Select_Astro_Radios__c picklist on 13-02-2017
     
     ADPApp.Please_Select_Astro_Radios__c='';
      if(chkBx11==false && chkBx12==false && chkBx13==false && chkBx14==false && chkBx15==false)
     {
      ADPApp.Please_Select_Astro_Radios__c='';
     }
     if(chkBx11==true)
     {
      ADPApp.Please_Select_Astro_Radios__c='Direct or Tactical Mode';
     }
     else if(chkBx11==false)
     {
     ADPApp.Please_Select_Astro_Radios__c='';
     }
     if(chkBx12==true && ADPApp.Please_Select_Astro_Radios__c !=null)
     {
     ADPApp.Please_Select_Astro_Radios__c=ADPApp.Please_Select_Astro_Radios__c+';'+'Repeater Mode';
     }
     else if(chkBx12==true && ADPApp.Please_Select_Astro_Radios__c ==null)
     ADPApp.Please_Select_Astro_Radios__c='Repeater Mode';
     else if(chkBx12==false)
     {
     ADPApp.Please_Select_Astro_Radios__c=ADPApp.Please_Select_Astro_Radios__c;
     }
     if(chkBx13==true && ADPApp.Please_Select_Astro_Radios__c !=null)
     {
     ADPApp.Please_Select_Astro_Radios__c=ADPApp.Please_Select_Astro_Radios__c+';'+'Fixed Network Equipment (FNE) Mode';
     }
     else if(chkBx13==true && ADPApp.Please_Select_Astro_Radios__c ==null)
     ADPApp.Please_Select_Astro_Radios__c='Fixed Network Equipment (FNE) Mode';
     else if(chkBx13==false)
     {
     ADPApp.Please_Select_Astro_Radios__c=ADPApp.Please_Select_Astro_Radios__c;
     }
     if(chkBx14==true && ADPApp.Please_Select_Astro_Radios__c !=null)
     {
     ADPApp.Please_Select_Astro_Radios__c=ADPApp.Please_Select_Astro_Radios__c+';'+'Smartnet & Mixed Mode 4.1';
     }
     else if(chkBx14==true && ADPApp.Please_Select_Astro_Radios__c ==null)
     ADPApp.Please_Select_Astro_Radios__c='Smartnet & Mixed Mode 4.1';
     else if(chkBx14==false)
     {
     ADPApp.Please_Select_Astro_Radios__c=ADPApp.Please_Select_Astro_Radios__c;
     }
     if(chkBx15==true && ADPApp.Please_Select_Astro_Radios__c !=null)
     {
     ADPApp.Please_Select_Astro_Radios__c=ADPApp.Please_Select_Astro_Radios__c+';'+'ASTRO IV&D or ASTRO P25 Trunking';
     }
     else if(chkBx15==true && ADPApp.Please_Select_Astro_Radios__c ==null)
     ADPApp.Please_Select_Astro_Radios__c='ASTRO IV&D or ASTRO P25 Trunking';
     else if(chkBx15==false)
     {
     ADPApp.ASTRO_P25_S_W_Release_systems__c=ADPApp.ASTRO_P25_S_W_Release_systems__c;
     }
        
    try {
            
            upsert ADPApp;
        
        } 
        
        catch (Exception e) 
          {
            String objectName ='ADP Regitration-'+ADPApp.Id;
            String userName=userInfo.getName();
            datetime myDateTime = datetime.now();
            CreateErrorLog.createErrorRecord(e.getmessage(),objectName,e.getStackTraceString(),userName,myDateTime,e.getTypeName());
            ApexPages.addMessages(e);
            return null;
          }
        
        PageReference FinishLaterPage = new PageReference('/apex/ADPRegistrationThankyouPage?AppFinishLater=1&id='+ADPApp.id);
        FinishLaterPage.setRedirect(true);
        return FinishLaterPage;
        
    }
    
    public PageReference attach() {
        system.debug('attachmentattachment111'+ApexPages.currentPage().getParameters().get('id'));
       
        
        if(attachment.BodyLength >0)
        {
            attachment.OwnerId = UserInfo.getUserId();
            attachment.ParentId = ApexPages.currentPage().getParameters().get('id');   
            
               try {  
                   if(attachment.BodyLength >= 5242880) { 
                   System.debug(' size > 5mb');       
                // throw new CustomException('File size is larger than 5 MB');
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'The size of the file you are trying to upload is '+attachment.BodyLength +' bytes. Please select another file with size < 5MB.'));
                
                 } else{
                       insert attachment;
                       system.debug('attachmentattachment'+attachment);
                       ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, attachment.name + ' File is uploaded Successfully! The size is '+attachment.BodyLength+' bytes'));
                       Isattach = true;
                    }
                    }catch (DMLException e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING, e.getMessage()));
                 // ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error in uploading attachment'));
                  return null;
                } finally {
                      attachment = new Attachment(); 
                }
               Isattach = true;      
        }  
        
         att= new list<Attachment>();
        att= [SELECT Id,Name,Body FROM Attachment where parentId=:ApexPages.currentPage().getParameters().get('id')];
         
    return null;
  }
    
    public PageReference doRemove() {
    //List the attachment which needs to be deleted
        delatt= new list<Attachment>();
        delatt= [SELECT Id,Name,OwnerId,IsPrivate,Body,Description FROM Attachment where Id=:recid];
        delete delatt;
    //Diplay the list of attachments in the pageblocktable section of UploadDoc Page
        att= new list<Attachment>();
        att= [SELECT Id,Name FROM Attachment where parentId=:ADPApp.id];
        return null;
   } 
    
    public void clearid()
    {
        MPM_ID='';
        HideAccinfo=false;
        ADPShowAcc = false;
    }
  
      
}