/*******************************************************************************
 * Class Name : PSRRTriggerHandler
 * Description : Handler class for PSRRTrigger
 * Author : Vineela N
 * Date : 7th Dec 2017
 *******************************************************************************/
public class PSRRTriggerHandler {
    public PSRRTriggerHandler(){}
    Public Map<Opportunity,List<Presales__c>> DMLOperationsONOpp(List<String> opplist) {
        Map<Opportunity,List<Presales__c>> oppPresaleMap = new Map<Opportunity,List<Presales__c>>();
        for(opportunity eachOpp : [SELECT id,PRR_Proposal_Type__c,
                                   (SELECT ID, Proposal_Type_N__c,createddate FROM Presales__r  ORDER BY Createddate DESC LIMIT 1) 
                                   FROM Opportunity WHERE ID IN : opplist]) {               
                                       for(Presales__c PRR1 : eachOpp.Presales__r) {
                                           if(eachOpp.Presales__r.size()>0)
                                               eachOpp.PRR_Proposal_Type__c = PRR1.Proposal_Type_N__c;
                                       }  
                                       oppPresaleMap.put(eachOpp,eachOpp.Presales__r);
                                   }
        return oppPresaleMap;
    }
}