public class MotoCommunityTabsController {
    
    public class TabsMeta{
        @AuraEnabled
        public String tabName{get;set;}
        @AuraEnabled
        public String icon{get;set;}
        @AuraEnabled
        public String tabDesc{get;set;}
        public TabsMeta(String tabName, String icon, String tabDesc) {
            this.tabName = tabName;
            this.icon = icon;
            this.tabDesc = tabDesc;
        }  
    }
    
    @AuraEnabled
    public static List<TabsMeta> getTabsMetadata(String currentRecId){
        system.debug('####currentRecId####### => ' + currentRecId);
        List<TabsMeta> metas = new List<TabsMeta>();
        /*Id conId = [Select ContactId,AccountId from User where Id =: UserInfo.getUserId()].ContactId;
        system.debug('####conId####### => ' + conId);
        if(String.isNotBlank(currentRecId)) {
            for(AccountContactRelation ACR : [Select Id,Community_User_Permissions__c from AccountContactRelation where AccountId =: currentRecId and ContactId =: conId LIMIT 1]) {
                system.debug('####ACR####### => ' + ACR);
                if(String.isNotEmpty(ACR.Community_User_Permissions__c)) {
                    for(String str : ACR.Community_User_Permissions__c.split(';')) {
                        metas.add(new TabsMeta(
                            str, str, str
                        ));
                    }
                }
            }
        }
        system.debug('####metas####### => ' + metas);*/
        // partner users on the home page won't have an account id to look up an AccountContactRelation 
        // record, add the defaults
        if(metas.isEmpty()) {
            metas.add(new TabsMeta('Orders', 'utility:fulfillment_order', 'Orders'));
            metas.add(new TabsMeta('Cases', 'utility:case', 'Cases'));
            metas.add(new TabsMeta('Contracts', 'utility:work_order_type', 'Contracts'));
        }

        return metas;
    }
}