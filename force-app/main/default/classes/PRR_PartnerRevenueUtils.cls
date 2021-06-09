public class PRR_PartnerRevenueUtils{
   // private User userRec = new User();    
   // public string UserRegion {get;set;}
    //public String profileType = 'NonCAM'; // used to differiate between CAM and Non CAM profiles
    //private set < id > accountIds = new set < id > ();  
    //transient set < id > prdAcctIds = new set < id > ();
    
    public PRR_PartnerRevenueUtils(){
                
    }
    public static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
 
        Set<ID> currentRoleIds = new Set<ID>();
        // get all of the roles underneath the passed roles
        for(UserRole userRole :[select Id from UserRole where ParentRoleId IN :roleIds AND ParentRoleID != null ])
            currentRoleIds.add(userRole.Id);
            System.debug('SIZE:'+currentRoleIds.size());
        System.debug('Total Number of records that can be queried  in this apex code context:## ' +  Limits.getLimitDmlRows());
        // go fetch some more rolls!
       if(currentRoleIds.size() > 0)
           currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
     
        return currentRoleIds;
    }
    public static Set<id> accountsAccess() {
        set < id > accountIds = new set < id > ();  
        set < id > prdAcctIds = new set < id > ();
        String profileType = 'NonCAM';
        Set<ID> currentUserIds = new Set<ID>(); 
        set < id > idSet = new set < id > (); 
        User userRec = new User(); 
        userRec = [Select id, Theater__c, ProfileID, UserRoleID, Email from User where id = : Userinfo.getUserId()];
        String UserRegion = UserRec.Theater__c;
        list < CAMProfiles__c > cs = CAMProfiles__c.getAll().values();
        for (CAMProfiles__c cam: cs) {
            if (userRec.ProfileID == cam.Profile_Id__c)
                profileType = 'CAM';
        }
        Set<Id> allSubRoleIds = getAllSubRoleIds(new Set<ID>{userRec.UserRoleID});
        //allSubRoleIds.add(userRec.UserRoleID); commented by ashok       
        System.debug('Total Number of records that can be queried  in this apex code context1: ' +  Limits.getLimitDmlRows());
        // get all of the ids for the users in those roles
        Map<Id,User> users = new Map<Id, User>([Select Id, Name From User where UserRoleId IN :allSubRoleIds limit 50000]);
        // return the ids as a set so you can do what you want with them
        System.debug('Total Number of records that can be queried  in this apex code context2: ' +  Limits.getLimitDmlRows());
        currentUserIds = users.keySet();
        Id userId = userRec.id;
        //currentUserIds.add(userId);
        system.debug('Logged in Users Profile : ' + profileType);
        For(Account prdRecord : [Select id,OwnerId,Partner_Account_Name__c,AccountNumber,Partner_Region__c,Partner_HQ_Country__c,Metal_Level__c,Partner_Membership_Id__c,MPE_Program_Status__c,Annual_Program_Review_Date_APRD__c,type from account where MPE_Program_Status__c = 'Active' and type = 'Partner' and Annual_Program_Review_Date_APRD__c != null Order By Partner_Account_Name__c ASC NULLS LAST limit 50000]){ 
            if(userRec.UserRoleID == '00E30000000gT00' || userRec.Theater__c == 'WORLDWIDE'){
                prdAcctIds.add(prdRecord.id);
            }else{
                if(prdRecord.Partner_Region__c == UserRegion)
                    prdAcctIds.add(prdRecord.id); 
                if(prdRecord.OwnerId == UserRec.id)
                    accountIds.add(prdRecord.id);
                if(currentUserIds.contains(prdRecord.OwnerId))
                    accountIds.add(prdRecord.id);
            }
        }
        
        if (profileType == 'CAM') {
            //set < id > accountIds = new set < id > ();
            List < AccountTeamMember > members = [SELECT Id, AccountId FROM AccountTeamMember WHERE UserId =:userRec.id OR UserId = :currentUserIds];
            for (AccountTeamMember member: members) {
                //accountIds.add(member.AccountId);
                if (prdAcctIds.contains(member.AccountId))
                    idSet.add(member.AccountId);
            }
            idSet.addAll(accountIds);
        } else {
            idSet.addAll(prdAcctIds);
        }
        system.debug('Idset :'+idset.size());
        return idSet;
    } 
}