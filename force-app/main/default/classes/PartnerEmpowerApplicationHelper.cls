public class PartnerEmpowerApplicationHelper {
    public void validateRejectedReason(List<Empower_Application__c> lstNewApp,Map<Id,Empower_Application__c> oldItems){
        Map<Id, Empower_Application__c> mapRejectedStatements = new Map<Id, Empower_Application__c>{};
            for(Empower_Application__c newApp:lstNewApp){
                Empower_Application__c oldApp = (Empower_Application__c)oldItems.get(newApp.Id);
                if (oldApp.Partner_Application_Status__c != 'Denied' && newApp.Partner_Application_Status__c == 'Denied'){ 
                    mapRejectedStatements.put(newApp.Id, newApp);  
                }
            }
        if (!mapRejectedStatements.isEmpty()){
            GlobalUtility.approvalProcessRejectionCmtsMandatory(mapRejectedStatements);
        }
        
    }
    
    public void populateSignatoryEmail(List<Empower_Application__c> newApplnList){
        for(Empower_Application__c empowerAppln:newApplnList){
            if(empowerAppln.Applicant_Email_Address__c != empowerAppln.Company_Signature_Authority_Email__c){
                empowerAppln.Signatory_Email_Final__c = empowerAppln.Company_Signature_Authority_Email__c;
            } else {
                empowerAppln.Signatory_Email_Final__c = empowerAppln.Company_Signature_Authority_Email__c;
            }  
        }
    }
    
    public void populateApprovedData(List<Empower_Application__c> newApplnList){
        if(Recursionblocker.flag){
            for(Empower_Application__c empower : newApplnList){
                if(empower.Partner_Application_Status__c == 'Approved'){
                    empower.Approved_Partner_Community_Type__c=empower.Partner_Community_Type__c;
                    empower.Approved_Partner_Technology_Segment__c=empower.Partner_Technology_Segment__c;
                    empower.Approved_Partner_Technology_Sub_Segment__c=empower.Technology_Sub_Segment__c;
                }
            }
        } 
    }
}