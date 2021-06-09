/************************************************************************************************
* Description : This class is used to show/hide "ADD/Remove Prduct Family" button on Opportunity layout on community.
* Author : Afzal Wasi
* Date :  3rd Sep 2018
**********************************************************************************************/

public class MRCPQ_OpportunityBtnPanelController {
    @AuraEnabled
    public static boolean showAddRemoveFamilybtn(String recordID) {
        // To check if record type of opportunity is Project or not
        List<Opportunity> isProjectOpp =[SELECT RecordType.name FROM Opportunity Where id=:recordID 
                                         AND RecordType.DeveloperName ='Government_Standard' Limit 1]; 
        system.debug('accesscheck'+Schema.sObjectType.Opportunity.isUpdateable());
        return Schema.sObjectType.Opportunity.isUpdateable() && isProjectOpp.size() > 0;
    }
}