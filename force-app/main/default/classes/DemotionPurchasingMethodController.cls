public Class DemotionPurchasingMethodController {

    public ID accountID ;
    
    public Contact contactDetails{get;set;}
    public Partner_Location__c partnerLocation{get;set;}

	// Method to fetch the contact and address details of the account to be used in the Email Controller for demotion
    public void getDetails(){
       
       contactDetails= [SELECT ID,Salutation,FirstName,LastName
                            FROM Contact WHERE Accountid = :accountID limit 1];

       partnerLocation = [SELECT ID,Address_Line1__c,Address_Line2__c,City__c,State__c,Postal_code__c,Country1__c
                            FROM Partner_Location__c WHERE Account__c = :accountID limit 1];
                 
                 
   }
    
   // getter method for the account ID to be used in the demotion email controller
   public ID getAccountId() { 
       return accountId; 
   }
    
   // setter method for the account ID to be used in the demotion email controller
   public void setAccountId(ID inputID){
       accountId= inputID;
       getDetails();
   }
    
}