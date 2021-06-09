public class NA_Product_Hierarchy_Helper {
    
    public void updateOpportunites(Set<Id> oppIds) {
        
        Map<Id, Opportunity> oppMaptoUpdate = New Map<Id, Opportunity>();
        for(Opportunity opp : [SELECT Id from Opportunity WHERE Id IN : oppIds AND RecordType.DeveloperName != 'Run_Rate'] ){
            oppMaptoUpdate.put(opp.Id, New Opportunity(
                Id = opp.Id,
                Equipment_Amount__c = null,
                SI_Amount__c = null,
                LCS_Amount__c = null,
                SPSS_Amount__c = null,
                FirstNet_Amount__c = null
            ));
        }
        
        for (Opportunity v : [SELECT id,Name,Equipment_Amount__c,SI_Amount__c,LCS_Amount__c,SPSS_Amount__c,(Select Id,TotalPrice,Product2.NA_Alternate_Product_Hierarchy__c  from OpportunityLineItems) FROM Opportunity Where ID IN:oppMaptoUpdate.keySet() AND Owner.UserTheater__c='NA']) {
            
            for (OpportunityLineItem opline: v.OpportunityLineItems) {
                
                if(opline.Product2.NA_Alternate_Product_Hierarchy__c == 'Equipment' && opline.Product2.NA_Alternate_Product_Hierarchy__c != '' ){
                    
                    if(oppMaptoUpdate.get(v.id).Equipment_Amount__c==null )
                        oppMaptoUpdate.get(v.id).Equipment_Amount__c=0;
                    
                    oppMaptoUpdate.get(v.id).Equipment_Amount__c = oppMaptoUpdate.get(v.id).Equipment_Amount__c+opline.TotalPrice;
                }
                else if(opline.Product2.NA_Alternate_Product_Hierarchy__c == 'SI' && opline.Product2.NA_Alternate_Product_Hierarchy__c != ''){
                    if(oppMaptoUpdate.get(v.id).SI_Amount__c==null )
                        oppMaptoUpdate.get(v.id).SI_Amount__c=0;
                    oppMaptoUpdate.get(v.id).SI_Amount__c=  oppMaptoUpdate.get(v.id).SI_Amount__c+opline.TotalPrice;
                }
                else if(opline.Product2.NA_Alternate_Product_Hierarchy__c == 'LCS' && opline.Product2.NA_Alternate_Product_Hierarchy__c != ''){
                    if( oppMaptoUpdate.get(v.id).LCS_Amount__c==null )
                        oppMaptoUpdate.get(v.id).LCS_Amount__c=0;
                    oppMaptoUpdate.get(v.id).LCS_Amount__c=  oppMaptoUpdate.get(v.id).LCS_Amount__c+opline.TotalPrice;
                }
                else if(opline.Product2.NA_Alternate_Product_Hierarchy__c == 'SPSS' && opline.Product2.NA_Alternate_Product_Hierarchy__c != ''){
                    if( oppMaptoUpdate.get(v.id).SPSS_Amount__c==null )
                        oppMaptoUpdate.get(v.id).SPSS_Amount__c=0;
                    oppMaptoUpdate.get(v.id).SPSS_Amount__c=  oppMaptoUpdate.get(v.id).SPSS_Amount__c+opline.TotalPrice;
                }
                else if(opline.Product2.NA_Alternate_Product_Hierarchy__c == 'FirstNet' && opline.Product2.NA_Alternate_Product_Hierarchy__c != ''){
                    if( oppMaptoUpdate.get(v.id).FirstNet_Amount__c==null )
                        oppMaptoUpdate.get(v.id).FirstNet_Amount__c=0;
                    oppMaptoUpdate.get(v.id).FirstNet_Amount__c=  oppMaptoUpdate.get(v.id).FirstNet_Amount__c+opline.TotalPrice;
                }
            }
        }
        update oppMaptoUpdate.values();
    }
}