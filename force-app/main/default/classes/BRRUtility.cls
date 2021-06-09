public class BRRUtility {
    public static List<Briefing_Room_Report__c> getCurrentWeekBRR(){
        List<Briefing_Room_Report__c> lstBRR = [SELECT Id,This_Week_BRR__c,Past_Week__c,Next_Week_s_BRR__c 
                                                FROM Briefing_Room_Report__c WHERE This_Week_BRR__c = TRUE
                                                LIMIT 1];
        return lstBRR;
    }
    public static Map<Id,Briefing_Room_Report__c> getBRR(Set<Id> BRRIds){
        Map<Id,Briefing_Room_Report__c> mapBRRInfo = new Map<Id,Briefing_Room_Report__c>([
            SELECT Id,This_Week_BRR__c,Past_Week__c,Previous_Week_s_BRR__c, Next_Week_s_BRR__c
            FROM Briefing_Room_Report__c WHERE Id IN :BRRIds]);
        return mapBRRInfo;
    }
    public static Map<String,Integer> getDayTextToNumMap(){
        Map<String,Integer> dayTextToNumMap = new Map<String,Integer>{'Sunday' =>1,'Monday'=> 2,'Tuesday'=>3 ,
            'Wednesday'=>4,'Thursday'=>5,'Friday'=>6,'Saturday'=>7};    
                return dayTextToNumMap;
    }
    public static Integer getDayOfWeekNum(){
        Map<String,Integer> dayTextToNumMap = getDayTextToNumMap();
        DateTime now = DateTime.now();
        String dayOfWeek = now.format('EEEE');
        //system.debug('dayOfWeek'+dayOfWeek);
        Integer dayOfWeekNum = dayTextToNumMap.get(dayOfWeek);
        //system.debug('dayOfWeekNum*****'+dayOfWeekNum);
        return dayOfWeekNum;
    }
    public static Map<String,MR_Digitization_Settings__mdt> getLockdownDayByTerritory(List<String> lstTerritory){
        Integer lockdownDay ;
        Map<String,Integer> dayTextToNumMap = getDayTextToNumMap();
        Map<String,MR_Digitization_Settings__mdt> mapTerritoryBRRMeta = new Map<String,MR_Digitization_Settings__mdt>();
        for(MR_Digitization_Settings__mdt brrMeta :[SELECT Id,MasterLabel,Values__c,Number_16_2__c FROM MR_Digitization_Settings__mdt 
                                                    WHERE Category__c = 'BRR_Lockdown' AND Number_16_2__c != NULL AND Values__c != NULL AND MasterLabel IN : lstTerritory]){
            mapTerritoryBRRMeta.put(brrMeta.MasterLabel, brrMeta);            
        }
        return mapTerritoryBRRMeta;
    }
    public static Boolean isOutsideLockingPeriod(Map<String,MR_Digitization_Settings__mdt> mapTerritoryBRRMeta , String territory){
        Map<String,Integer> dayTextToNumMap = BRRUtility.getDayTextToNumMap();
        Integer dayOfWeekNum = BRRUtility.getDayOfWeekNum();
        Integer userCurrentHour = System.now().hour();
        Integer userCurrentMinute = System.now().minute();
        system.debug('mapTerritoryBRRMeta'+mapTerritoryBRRMeta);
        system.debug('dayTextToNumMap Terr**'+dayTextToNumMap.get(mapTerritoryBRRMeta.get(territory).Values__c) ); 
        system.debug('dayOfWeekNum current**'+dayOfWeekNum ); 
        if(mapTerritoryBRRMeta.containsKey(territory) && dayTextToNumMap.get(mapTerritoryBRRMeta.get(territory).Values__c) == dayOfWeekNum ){
            Decimal timingOfLockDownDay = mapTerritoryBRRMeta.get(territory).Number_16_2__c; 
            Integer terrLockingHour  = Integer.valueOf(timingOfLockDownDay);
            String s = String.valueOf(timingOfLockDownDay); // assuming you meant to use d here
            Integer terrLockingMinute = Integer.valueOf(s.substringAfter('.'));
            //system.debug('userCurrentHour'+userCurrentHour);
            //system.debug('userCurrentMinute'+userCurrentMinute);
            //system.debug('terrLockingHour'+terrLockingHour);
            //system.debug('terrLockingMinute'+terrLockingMinute);
            if((userCurrentHour > terrLockingHour)  ||  (userCurrentHour == terrLockingHour && userCurrentMinute > terrLockingMinute) ){
                system.debug('in locking');
                return true;
            }
        }else if(mapTerritoryBRRMeta.containsKey(territory) && dayTextToNumMap.get(mapTerritoryBRRMeta.get(territory).Values__c) < dayOfWeekNum ){
            return true;
        }
        return false;
    }
}