public class FiscalMetadataTriggerHandler implements ITriggerHandler {
    public static Boolean triggerDisabled = false;
    
    public void BeforeInsert(List<SObject> newItems){
        List<Fiscal_Metadata__c> listFiscalMeta = new List<Fiscal_Metadata__c>();
        if(newItems != null) listFiscalMeta = (List<Fiscal_Metadata__c>) newItems;
        
        Set<Integer> setFiscalYears  = new Set<Integer>();
        Map<Date,String> mapStartDateMonth = new Map<Date,String>();
        Map<Map<Date,Date>,String> mapStartEndMonth = new Map<Map<Date,Date>,String>();
        
        for(Fiscal_Metadata__c fiscalMeta : listFiscalMeta){
            setFiscalYears.add(Integer.valueOf(fiscalMeta.Year__c));
        }
        for(Period period : [SELECT PeriodLabel, Type, StartDate, EndDate FROM Period WHERE Type = 'Month' and Calendar_year(StartDate) IN : setFiscalYears]){
            Map<Date,Date> mapStartEndDates = new Map<Date,Date>();
            mapStartEndDates.put(period.StartDate,period.EndDate);
            mapStartEndMonth.put(mapStartEndDates, period.PeriodLabel);
        }
        for(Fiscal_Metadata__c fiscalMeta : listFiscalMeta){
            for(Map<Date,Date>  monthStartEndDate : mapStartEndMonth.keyset() ){
                for(Date startDate : monthStartEndDate.keySet()){
                    if(fiscalMeta.Week_Start_Date__c >= startDate && fiscalMeta.Week_End_Date__c <= monthStartEndDate.get(startDate)){
                        fiscalMeta.Fiscal_Period__c = mapStartEndMonth.get(monthStartEndDate);
                        break;
                    }
                }
            } 
        }
    }
    
    public void AfterInsert(Map<Id, SObject> newItems) {
        Map<Id,Fiscal_Metadata__c> mapRRDs = new Map<Id,Fiscal_Metadata__c>();
        if(newItems != null) mapRRDs = (Map<Id,Fiscal_Metadata__c>) newItems;
        List<Fiscal_Metadata__c> listTobeUpdated = new List<Fiscal_Metadata__c>();
        for(Fiscal_Metadata__c fiscalMeta : [Select Fiscal_Quarter__c from Fiscal_Metadata__c where ID IN : mapRRDs.keySet()]){
            fiscalMeta.Fiscal_Quarter_Text__c = fiscalMeta.Fiscal_Quarter__c;
            listTobeUpdated.add(fiscalMeta);
        }
        if(!listTobeUpdated.isEmpty()){
            try{
              update listTobeUpdated;
            }catch(Exception ex){
                CreateErrorLog.createErrorRecord(ex.getMessage(), 'Fiscal_Metadata__c', String.valueOf(ex.getCause()), userInfo.getUserName(), System.now(), ex.getTypeName());
            }
        }
    }
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        
        Map<Id,Fiscal_Metadata__c> oldFiscalMap = new Map<Id,Fiscal_Metadata__c>();
        Map<Id,Fiscal_Metadata__c> newFicalMap = new Map<Id,Fiscal_Metadata__c>();
        if(oldItems != null) oldFiscalMap = (Map<Id,Fiscal_Metadata__c>) oldItems;
        if(newItems != null) newFicalMap = (Map<Id,Fiscal_Metadata__c>) newItems;
        
        Set<Integer> setFiscalYears  = new Set<Integer>();
        Map<Date,String> mapStartDateMonth = new Map<Date,String>();
        Map<Map<Date,Date>,String> mapStartEndMonth = new Map<Map<Date,Date>,String>();
        
        for(Fiscal_Metadata__c fiscalMeta : newFicalMap.values()){
            setFiscalYears.add(Integer.valueOf(fiscalMeta.Year__c));
        }
        for(Period period : [SELECT PeriodLabel, Type, StartDate, EndDate FROM Period WHERE Type = 'Month' and Calendar_year(StartDate) IN : setFiscalYears]){
            Map<Date,Date> mapStartEndDates = new Map<Date,Date>();
            mapStartEndDates.put(period.StartDate,period.EndDate);
            mapStartEndMonth.put(mapStartEndDates, period.PeriodLabel);
        }
        for(Fiscal_Metadata__c fiscalMeta : newFicalMap.values()){
            for(Map<Date,Date>  monthStartEndDate : mapStartEndMonth.keyset() ){
                for(Date startDate : monthStartEndDate.keySet()){
                    if(fiscalMeta.Week_Start_Date__c >= startDate && fiscalMeta.Week_End_Date__c <= monthStartEndDate.get(startDate)){
                        fiscalMeta.Fiscal_Period__c = mapStartEndMonth.get(monthStartEndDate);
                        break;
                    }
                }
            } 
        }
        
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    public void BeforeDelete(Map<Id, SObject> oldItems){}
    public void AfterDelete(Map<Id, SObject> oldItems){}
    public void AfterUndelete(Map<Id, SObject> oldItems){}
    public Boolean isDisabled(){
        if (TriggerSettings__c.getValues('FiscalMetadataTriggerDisabled').IsActive__c){
            return true;
        } else{
            return TriggerDisabled;
        }
    }
}