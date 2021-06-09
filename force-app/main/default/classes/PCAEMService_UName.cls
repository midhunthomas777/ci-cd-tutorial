/*
Name:  PCAEMService_UName
Purpose: Rest service to Get partner users information based on UserName
          
Request URI : /services/apexrest/GetPCUsers?Uemail=cree.stewart=icemt.com@example.com

Request Parameters - 
Uemail = User's email

==========================================================================================
History
-------                                                                                                                  
VERSION        AUTHOR            DATE                 DETAIL                   
  1.0 -     Satish Maddhi      21 Feb 2017       INITIAL DEVELOPMENT       

******************************************************************************************/
    
@RestResource(urlMapping='/GetPCUsers/*')
global class PCAEMService_UName { //main class start
    @HttpGet
    global static List<PCAEMServiceHelper.PCAEMServiceResponse> getPCUsers() { //getPCUsers() method start 
        String usrEmail = RestContext.request.params.get('Uemail');
        //String uEmail = usrEmail.replaceAll('\\n','');
        List<User> usrObjList = getUserDetails(usrEmail);
        Transient List<PCAEMServiceHelper.PCAEMServiceResponse> mainResponseList = new List<PCAEMServiceHelper.PCAEMServiceResponse>();
        if(usrObjList.size() > 0) {
        	mainResponseList = PCAEMService_AccId.getUserResponse(usrObjList);    
        }
        return mainResponseList;
    } //getPCUsers() method end

    /*============================================================================================= 
    Author : Satish
    Description    : This method accepts Users Email and process on User object
    @param1        : Users Email
    @return        : List of Users
    Modification History:   
    ===============================================================================================*/
    public static List<User> getUserDetails(String uEmail) {
        return [SELECT Id, Contact.Account.Id,Contact.Account.Name, Contact.Name, Contact.Primary_Contact_Type__c, Username,
						Contact.Contact_Type__c, Contact.Tag__c, Email, FederationIdentifier, IsActive 
					FROM User 
					WHERE Email = :uEmail
					Order By IsActive DESC];
    }
} //main class end