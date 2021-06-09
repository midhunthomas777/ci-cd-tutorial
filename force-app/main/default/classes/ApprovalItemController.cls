public class ApprovalItemController {
public String relatedRecordId {get;set;}

public List<Apttus_Approval__Approval_Request__c> getAllApprovalStep() {

List<Apttus_Approval__Approval_Request__c> lstApprovalStep = new List<Apttus_Approval__Approval_Request__c>();

lstApprovalStep = [ Select Apttus_Approval__StepSequence__c,Apttus_Approval__PrevAssignedToName__c,Apttus_Approval__Approval_Status__c,Apttus_Approval__Approver_Comments__c,Apttus_Approval__Assigned_To_Name__c,Apttus_Approval__Date__c,Apttus_Approval__DependsOn__c,Apttus_Approval__Step_Name__c,Apttus_Approval__ActualApproverName__c FROM Apttus_Approval__Approval_Request__c WHERE  Apttus_Approval__Related_Agreement__c = :relatedRecordId AND Apttus_Approval__Approval_Status__c != 'Pending Approval' AND Apttus_Approval__Approval_Status__c != 'Approval Required' ORDER BY Apttus_Approval__StepSequence__c ASC NULLS FIRST LIMIT 100];


return lstApprovalStep;

}
}