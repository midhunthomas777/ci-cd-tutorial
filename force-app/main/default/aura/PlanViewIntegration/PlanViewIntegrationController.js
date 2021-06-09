({
    updatedRecord : function(component, event, helper) {
        var planViewResponse = [];
        var planViewStatus=null;
        var planViewMessage=null;
        var successMessage = $A.get("{!$Label.c.Planview_Success_Message}");
        var planviewPRRCheck = $A.get("{!$Label.c.Planview_PRR_Message}");
        var planiewFieldValidation = $A.get("{!$Label.c.Planview_Field_Validation}");
        var planviewRFXValidation = $A.get("{!$Label.c.Planview_RFX_Propsal_Due_Date_Message}");
        var opportunityRecord = component.get("v.opportunityRecord");        
        var todayDate =  $A.localizationService.formatDate(new Date(),"YYYY-MM-DD");
        var today = new Date();
        today.setDate(today.getDate() + 180);
        var result = $A.localizationService.formatDate(today,"YYYY-MM-DD");
            if(opportunityRecord.RFx_Proposal_Due_Date__c >= todayDate && opportunityRecord.RFx_Proposal_Due_Date__c <= result && opportunityRecord.RFx_Proposal_Due_Date__c!=null){
                if(opportunityRecord.Count_Of_PSRR__c>0 && opportunityRecord.PlanviewSynched__c==false && opportunityRecord.Opportunity_Reference__c!=null && opportunityRecord.Planview_Business_Segment__c!=null && opportunityRecord.Planview_Sub_Territory__c!=null ){
                    helper.getPlanviewResponse(component, event, helper);                               
                }else if(opportunityRecord.PlanviewSynched__c==true){
                    component.set("v.showSpinner",false);
                    component.set("v.errorMsg",successMessage); 
                }else if(opportunityRecord.Count_Of_PSRR__c==0){
                    component.set("v.showSpinner",false);
                    component.set("v.errorMsg",planviewPRRCheck); 
                }else{
                    component.set("v.showSpinner",false);
                    component.set("v.errorMsg",planiewFieldValidation); 
                }
            }else{
                component.set("v.showSpinner",false);
                component.set("v.errorMsg",planviewRFXValidation); 
            }
        }
})