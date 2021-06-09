public class AccountDupeCheckerExtension {

    Public String aid;
    public Account[] finalResults {get;set;}
    public Contact[] matchEmail {get;set;}
    public Empower_Application__c selectedApplication {get;set;}
    public List<aAccount> accountList {get; set;}
    public String em {get; set;}
    public Boolean noResults {get;set;}
    public Boolean notApproved {get;set;}
    public Boolean wasTruncated {get;set;}
    public boolean errormsg=false;
    public boolean approvalmsg=false;
    
    public AccountDupeCheckerExtension(ApexPages.StandardController controller) {
        
        aid=System.currentPageReference().getParameters().get('id');
        
        //Application fields to that we show on the Duplicate search page
        selectedApplication = [Select Applicant_First_Name__c, Applicant_Last_Name__c, Applicant_Email_Address__c,
        						  	  Company_Legal_Name__c, Motorola_Reseller_Id__c, Application_Status__c
        					 	 from Empower_Application__c
        						where Id = :aid];
        
        matchEmail = [Select Id, AccountId from Contact where email = :selectedApplication.Applicant_Email_Address__c];
        
        if(selectedApplication.Application_Status__c == 'Approved')
            notApproved = true;
        else
            notApproved = false;
        
        //finalResults = SearchForDuplicates.getAccounts(controller.getRecord().Id);
        finalResults = SearchForDuplicates.getAccounts(aid);
        accountList = new List<aAccount>();
        em = 'False';
        for(Account a : finalResults)
	    {
	       
	       for(Contact c : matchEmail)
	       {
	       	 if(c.AccountId == a.Id)
	       	 {
	       	 	em = 'True';
	       	 }
	       }
	       
	       accountList.add(new aAccount(a, em));
	       
	       em = 'False';
	    }
        
        //selected = false;
        
        if(finalResults.size()==0)
            noResults = true;
        else
            noResults = false;

        if(finalResults.size()>100){
        
            wasTruncated = true;
            
            for(Integer y=finalResults.size()-1; y>99; y--){
                finalResults.remove(y);
            }
        }
        else{
            wasTruncated = false;   
        }
        
    }   
    
    public List<aAccount> getresults()
	{
	
	 return accountList;
	
	}
    
    public boolean geterrormsg()
	{
	 return errormsg;
	}
	
	public boolean getapprovalmsg()
	{
	 return approvalmsg;
	}
    
    public PageReference AssociateAccountInfo() { 
    	
      List<Account> selectedAccount = new List<Account>();
      
      if (accountList!= null)
	  {
	     for(aAccount aAcc : getresults()){
	        if(aAcc.selected == true){
	             selectedAccount.add(aAcc.acc);
	         }
	     }
	
	  }
	  
	  if (selectedAccount.size() > 1)
	   {
	     errormsg=true;
	     return null;
	   }
	  
	  if (selectedAccount.size() == 1)
	   {
	     errormsg=false;
	     approvalmsg=false;
	     
		 Empower_Application__c sObj = new Empower_Application__c();
		 sObj = [Select Id, Application_Status__c, Partner_Account__c from Empower_Application__c where Id = :aid];
		 system.debug('Application_Status = ' +sObj.Application_Status__c);
		 if (sObj.Application_Status__c == 'Approved'){
			 for (Integer i=0;i<selectedAccount.size();i++) {
			 	sObj.Partner_Account__c = selectedAccount.get(i).Id;
			 }
			 
			 try{
			   update sObj;
			 }
			 catch(Exception x){
	           ApexPages.addMessages(x);
	           return Page.Exception;
	         }
	         
	         Pagereference a = new Pagereference('/'+sObj.Partner_Account__c);
	    	 return a;
		 }
		 else{
		 	approvalmsg=true;
		 	return null;
		 }
		 
	   }
     return null;	
    }
    
	public class aAccount
	{
	 public Account acc {get; set;}
	 public Boolean selected {get; set;}
	 public String matched {get; set;}
	
	 public aAccount(Account a, String b)
	 {
	     acc = a;
	     selected = false;
	     matched = b;
	 }
	 
	}
    
    public Pagereference Cancel()
	{
	    Pagereference p = new Pagereference('/'+aid);
	    return p;
	}
	
	public Pagereference CreateAccount()
	{
	    PageReference pageRef = new PageReference('/apex/CreateEmpowerPartner'+'?id='+aid);
		System.Debug('pageRef='+pageRef);
	    return pageRef;
	}

}