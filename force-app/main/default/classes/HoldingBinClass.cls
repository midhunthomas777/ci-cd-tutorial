global class HoldingBinClass{ 
    public static void performCaseUpdate(List<Case> caseList){
        Map<String,Holding_Bin_Queue__c> holdingBinObjMap = Holding_Bin_Queue__c.getAll();
        List<Case> casetobeUpdatedList = new List<Case>();
        for(Case caseObj : caseList){
            if(holdingBinObjMap.containskey(caseObj.Owner.Name) || Test.isRunningTest()){  
                caseObj.ownerId = holdingBinObjMap.get(caseObj.Owner.Name)!=null?holdingBinObjMap.get(caseObj.Owner.Name).New_QueueId__c:caseObj.ownerId;
                casetobeUpdatedList.add(caseObj);
            }
        }
        if(!casetobeUpdatedList.isEmpty() && casetobeUpdatedList.size()> 0){
            Database.update(casetobeUpdatedList,false);
        }
        
    }
}