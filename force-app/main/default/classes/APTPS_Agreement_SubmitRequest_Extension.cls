public class APTPS_Agreement_SubmitRequest_Extension {
        private final Apttus__APTS_Agreement__c agreement;
        private ApexPages.StandardController stdController;
        
    public APTPS_Agreement_SubmitRequest_Extension (ApexPages.StandardController controller) {
            stdController = controller;
            this.agreement = (Apttus__APTS_Agreement__c) stdController.getRecord();
    }

/**
 * Name: autoRun
 * Input: None.
 * Output: Current page reference.
 * Description: This function will set the Submit Request to YES 
 * when the Ready for Submit checkbox is checked. 
 */
   public PageReference autoRun() {
  //String theId = ApexPages.currentPage().getParameters().get('id');
  List<Apttus__APTS_Agreement__c> agreementsList = new List<Apttus__APTS_Agreement__c>();

try{
List<Apttus__APTS_Agreement__c> apt_agmnt = [
                                             Select id, 
                                             Hidden_Record_Type_Name__c,
                                             Submit_Request__c,
                                             Ready_For_Submission__c,
                                             Reason_for_Cancellation__c,
                                             Apttus__Status__c,
                                             Apttus__Status_Category__c
                                             from Apttus__APTS_Agreement__c 
                                             where ID =: agreement.id ];

for(Apttus__APTS_Agreement__c agmnts: apt_agmnt) {

    if( agmnts.Ready_For_Submission__c) {
    	    	
    	//If the record type is Procurement then set the Reason For Cancellation/Award Status 
    	//field to "Contract Awarded."
    	system.debug('Record Type Name: = ' + agmnts.Hidden_Record_Type_Name__c);
    	
    	if ((agmnts.Hidden_Record_Type_Name__c).equalsignorecase('Procurement')) {
    	agmnts.Reason_for_Cancellation__c = 'Contract Awarded';
    	  	
    	system.debug('Record Type is Procurement');
    	}
    		
       agmnts.Submit_Request__c = 'YES';
       agmnts.Apttus__Status_Category__c = 'Request';
       agmnts.Apttus__Status__c = 'Submitted Request';
       
      
    }
   // else agmnts.Position_Submitted__c = 'NO';

    agreementsList.add(agmnts);
}
    update agreementsList;
    
    system.debug('Agreement Record ID = ' + agreementsList.get(0) + 'updated sucessfully');

}
catch (Exception E) {
    ApexPages.addmessages(E);
    return ApexPages.currentPage();
    }

 // Redirect the user back to the original page
        //PageReference pageRef = new PageReference('/' + theId);
        //pageRef.setRedirect(true);
        //return pageRef;
        
// Redirect the user back to the original page
        return stdController.view().setRedirect(true);
    }
}