/*
* File Name  : cloneRedirectExtension
* Description: NA
* Author     :  NA
* Modification Log 
* ============================================================================= 
* Ver   Date        Author                         Modification 
* -----------------------------------------------------------------------------------------------------------------------------------------
* 1.0  19-02-2018  Sravan                    SF-525- Removed hardcoded references of opportunity record types apart from "Registration"
*                       & "Project".
*
* 
*
*/  
public with sharing class OpportunityActivityLastModifiedDate {

    public static Boolean didRun = false;
    public static String oppPrefix =  Opportunity.sObjectType.getDescribe().getKeyPrefix();

    /*
    * Takes a set of opportunity IDs, queries those opportunities, and updates the activity last modified date whenever any Activities made against it
    */
    public static void updateOpportunityField(Set<ID> oppIds) {

        if (didRun == false) { //We only want this operation to run once per transaction.
            didRun = true;

            //Query all the opportunites, including the tasks child relationships
            List<Opportunity> opps = [SELECT ID, Activity_Last_Modified_Date__c,RecordTypeid, (SELECT ID FROM Tasks), (SELECT ID FROM Events) FROM Opportunity WHERE ID IN :oppIds];
            List<Opportunity> updateOpps = new List<Opportunity>();

            for (Opportunity o : opps) {
                o.Activity_Last_Modified_Date__c = datetime.now();
                updateOpps.add(o); 
            }

            //Update the appropriate opportunities
            try {
                update updateOpps;
            } catch (Exception e) {
                //This is controversial. Anything could happen when updating the opportunity..validation rule, security, etc. The key is we don't
                //want the event update to fail...so we put a try catch around the opp update to make sure we don't stop that from happening.
            }
        }
    }
}