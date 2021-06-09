/*
Modification Log
* =============================================================================
*   Ver     Date         Author      Ticket           Modification
*------------------------------------------------------------------------------
*   1.1   20-july-16   Sai Harish   INC0932671        Randiomization partner contact assignment changed 
*/
public class  LM_PartnerLeadManagementHelper {

    public LM_PartnerLeadManagementHelper(){
    }
    
    /*
    public Map<ID,List<User>> getLeadContactsForSharing(List<ID> accountIDs){
    //Added by Hairsh as a part of INC0932671
    List<String> RandomSortList = new List<String>();
    
    RandomSortList.add('ID');
    RandomSortList.add('Name');
    RandomSortList.add('ContactID');
    RandomSortList.add('Email');
    RandomSortList.add('AccountID');
    RandomSortList.add('FirstName');
    RandomSortList.add('lastName');
    RandomSortList.add('CommunityNickname');
    RandomSortList.add('Core_ID__c'); 
    RandomSortList.add('ProfileId'); 
    RandomSortList.add('UserRoleId'); 
    RandomSortList.add('Email'); 
    RandomSortList.add('Username'); 
     
    
   Double d = math.random() * RandomSortList.size();
   Integer RndmIndx = d.intValue();
   String RndmString = RandomSortList[RndmIndx];
   //Added by Harish as a part of INC0932671
   System.Debug('Harish Harish RndmString RndmString '+RndmString );
   String FinalQuery ='SELECT ID, Name, ContactID, Email, AccountID FROM User WHERE AccountID IN :accountIDs and isActive=true'+' Order by '+RndmString;
   
    
    Set<ID> portalEnabledContacts=new Set<ID>();
    
    Map<ID,List<User>> contactToUserMap= new Map<ID,List<User>>();
    
    if(accountIDs!=null && accountIDs.size()>0){
    
       /* existing comment List<User> UsersToChek = new List<User>([
                                             SELECT ID, Name, ContactID, Email, AccountID
                                             FROM User
                                             WHERE AccountID IN :accountIDs 
                                             and isActive=true 
                                             ]);   */
     /*      List<Sobject> UsersToChekDup = Database.query(FinalQuery);  
           System.Debug('Harish Harish UsersToChekDup UsersToChekDup '+UsersToChekDup );
           List<User> UsersToChek = (List<User>)UsersToChekDup;                        
          System.Debug('Harish Harish UsersToChek UsersToChek '+UsersToChek);
          
         Set<ID> tempPortalContacts=getLeadContacts(accountIDs).keySet();
         Set<ID> portalContacts=tempPortalContacts.clone();
            for(User userRecord :UsersToChek ){
                if(!portalContacts.add(userRecord.ContactID)){
                    if(contactToUserMap.get(userRecord.AccountID)==null){
                         contactToUserMap.put(userRecord.AccountID,new List<User>());
                         contactToUserMap.get(userRecord.AccountID).add(userRecord);
                    }else{
                         contactToUserMap.get(userRecord.AccountID).add(userRecord);
                    }
                   
                }
            }
    
    }
  
     return contactToUserMap;
    
    }
    */
    /*
   public  Map<ID,Contact>  getLeadContacts(List<ID> accountIDs){
    
        Map<ID,Contact> contactIDToCon = new Map<ID,Contact>();
        
        if(accountIDs!=null && accountIDs.size()>0){
            
          contactIDToCon = new Map<ID,Contact>([
                                           SELECT ID, name, Contact_Type__c, AccountID, Email,Tag__c
                                           FROM Contact
                                           WHERE Radio_Lead_Contact__c='true'                                            
                                           AND ID IN ( SELECT ContactID from user where AccountID IN :accountIDs and isActive=true )
                                           ]);
     
     
        }
     
        return contactIDToCon;

    }
     */
    /*
    public Map<ID,List<User>> getLeadToPortalUserMap(List<ID> accountIDs,Map<ID,ID> leadToAccMap){
    
       Map<ID,List<User>> leadToUserMap= new Map<ID,List<User>>();
        
       Map<ID,List<User>> accountToUserMap = getLeadContactsForSharing(accountIDs);
       
       for(ID leadID : leadToAccMap.keySet()){
           if(leadToUserMap.get(leadID)==null && accountToUserMap.get(leadToAccMap.get(leadID))!=null ){
               leadToUserMap.put(leadID,accountToUserMap.get(leadToAccMap.get(leadID)));
           }
       }
       
       return leadToUserMap;
    
    }
*/
    //Modified this existing method for giving sharing to partner conatacts by Vineela as a part of SF-1101
  /*  public List<LeadShare> createSharingFOrLeadContacts(Set<ID> leadIDs,List<User> portalLeadContacts){
        List<LeadShare> createLeadSharingList = new List<LeadShare>();
        for(Id eachleadId : leadIDs ) {
            for(User userRecord : portalLeadContacts ){
                LeadShare PartnerUserShare = new LeadShare(); 
                PartnerUserShare.LeadId = eachleadId;
                PartnerUserShare.UserOrGroupId = userRecord.ID;
                PartnerUserShare.LeadAccessLevel = 'Edit';
                createLeadSharingList.add(PartnerUserShare);
            }
        }
        return createLeadSharingList;
    }
*/
    //Added by Vineela as a part of 1199
    //This Method is for giving Read/Write access to partnerexecutive of Account
  /*  public List<LeadShare> createSharing(Map<ID,List<User>> leadToUserMap) {
        Map<Id,Id> roleGrpMap=new Map<Id,Id>();
        List<UserRole> UserRoleList = new List<UserRole>(); 
        List<LeadShare> createLeadSharingList = new List<LeadShare>();
        Set<Id> AccIds = new Set<Id>();
        for(ID eachleadID :leadToUserMap.keySet()) {
            if(leadToUserMap.get(eachleadID)!=null && leadToUserMap.get(eachleadID).size()>0 ) {
                for(User userRecord : leadToUserMap.get(eachleadID)) {
                    AccIds.add(userRecord.AccountId);
                } 
            }
        }
        UserRoleList = [SELECT Id,Name,PortalRole,PortalAccountId
                        FROM UserRole 
                        WHERE PortalAccountId IN :AccIds 
                        AND PortalAccountId!=null
                        AND DeveloperName LIKE '%PartnerExecutive%'];
        //List<Group> groupList = [SELECT Id,Type,RelatedId FROM Group WHERE type IN ('RoleAndSubordinates','Role') AND RelatedId in :UserRoleList];
        for(Group GL : [SELECT Id,Type,RelatedId FROM Group 
                        WHERE Type = 'Role' 
                        AND RelatedId IN :UserRoleList 
                        AND DeveloperName LIKE '%PartnerExecutive%']) { 
                            roleGrpMap.put(GL.RelatedId,GL.Id);
                        }
        
        for(ID eachleadID :leadToUserMap.keySet()) {
            if(leadToUserMap.get(eachleadID)!=null && leadToUserMap.get(eachleadID).size()>0 ){
                for(User userRecord : leadToUserMap.get(eachleadID) ) {
                    for(UserRole UR:UserRoleList) {
                        if(UR.PortalRole == 'Executive') {
                            LeadShare PartnerUserShare = new LeadShare();
                            PartnerUserShare.LeadId = eachleadID; 
                            PartnerUserShare.UserOrGroupId = RoleGrpMap.get(UR.Id) ; 
                            PartnerUserShare.LeadAccessLevel = 'Edit';
                            createLeadSharingList.add(PartnerUserShare);
                        }  
                    }  
                } 
            }
        }
        return createLeadSharingList;
        
    }
	*/
    //Ended by Vineela as a part of 1199
    /*
    public List<LeadShare> removeSharingSettings(Set<ID> modifiedOrRessignedLeads){
    
         List<LeadShare> existingSharings = new List<LeadShare>([SELECT LeadId, Id, UserOrGroupId, LeadAccessLevel, RowCause
                                                              FROM LeadShare
                                                              WHERE (LeadID IN :modifiedOrRessignedLeads)
                                                              AND RowCause = 'Manual']);
         
        return existingSharings ;                                                  
    
    }*/
    //Modified by Sujata for Google Analytics
    public Map<String,String> decodeGoogleAnalyticsURL(String url){
         Map<String,String> decodedURLMap=new Map<String,String>();
         try{
                 String decoded = '';
                 URL decodedURL;
                 String urlQuery = '';
                 
                if(url != null && url.length() > 0) {
                    decoded = EncodingUtil.urldecode(url, 'UTF-8');
                    system.debug('decoded URL $$$ '+decoded);
                    }
                if(decoded != null && decoded.length() > 0) {
                    decodedURL = new URL(decoded);
                    system.debug('decodedURL URL ### '+decodedURL);
                    }
                if(decodedURL != null && decoded.length() > 0) {
                    urlQuery = decodedURL.getQuery();
                    system.debug('urlQuery URL *** '+urlQuery);
                    }
                if(urlQuery != null && urlQuery.length() > 0) {
                    String[] param = urlQuery.split('&'); 
                    system.debug('URL param*** '+param);
                    if(param!=null && param.size()>0){
                        String [] key = new String[param.size()];
                        String [] value = new String[param.size()];
                        system.debug('Suj param strinf array*** '+param);   
                            for(integer i=0;i<=param.size()-1;i++) {
                                key[i] = param[i].split('=')[0] == null ? '' : param[i].split('=')[0];
                                value[i] =param[i].split('=')[1] == null ? '' : param[i].split('=')[1];          
                                decodedURLMap.put(key[i],value[i]);           
                            }
                    }
        
                }  
         }catch(Exception ex){
             system.debug('Decode Google Analytics URL EXCEPTION OCCURRED ');
         }
     
        return decodedURLMap;
    }
    /* 
    public boolean isFederalEmailDomain(String strLeadEmail){
    
            return (strLeadEmail.endsWith('.mil') || strLeadEmail.contains('aafes.com') ||
                        strLeadEmail.contains('ameslab.gov') || strLeadEmail.contains('anl.gov') ||
                        strLeadEmail.contains('aoc.gov') || strLeadEmail.contains('atf.gov') ||
                        strLeadEmail.contains('az1dmat.com') || strLeadEmail.contains('bia.edu') ||
                        strLeadEmail.contains('bldrdoc.gov') || strLeadEmail.contains('blm.gov') ||
                        strLeadEmail.contains('bnl.gov') || strLeadEmail.contains('bop.gov') ||
                        strLeadEmail.contains('boeing.com') || strLeadEmail.contains('gtsi.com') ||
                        strLeadEmail.contains('campnavajo.com') || strLeadEmail.contains('cap.gov') ||
                        strLeadEmail.contains('cdc.gov') || strLeadEmail.contains('daytondmat.com') || strLeadEmail.contains('csc.com') ||
                        strLeadEmail.contains('dhs.gov') || strLeadEmail.contains('doc.gov') ||
                        strLeadEmail.contains('doe.gov') || strLeadEmail.contains('doeal.gov') ||
                        strLeadEmail.contains('doi.gov') || strLeadEmail.contains('dol.gov') ||
                        strLeadEmail.contains('dot.gov') || strLeadEmail.contains('ed.gov') ||
                        strLeadEmail.contains('epa.gov') ||
                        strLeadEmail.contains('faa.gov') || strLeadEmail.contains('fbi.gov') ||
                        strLeadEmail.contains('fbiacademy.edu') ||
                        strLeadEmail.contains('fcc.gov') || strLeadEmail.contains('fda.gov') ||
                        strLeadEmail.contains('fed.us') || strLeadEmail.contains('fema.gov') ||
                        strLeadEmail.contains('fnal.gov') || strLeadEmail.contains('fortlauderdalecap.org') ||
                        strLeadEmail.contains('frb.gov') ||
                        strLeadEmail.contains('fws.gov') || strLeadEmail.contains('gsa.gov') ||
                        strLeadEmail.contains('hhs.gov') || strLeadEmail.contains('hudoig.gov') ||
                        strLeadEmail.contains('ibb.gov') || strLeadEmail.contains('ihs.gov') ||
                        strLeadEmail.contains('inel.gov') || strLeadEmail.contains('irs.gov') ||
                        strLeadEmail.contains('jobcorps.org') ||
                        strLeadEmail.contains('l-3com.com') || strLeadEmail.contains('chcsii.com') ||
                        strLeadEmail.contains('lafbi.com') || strLeadEmail.contains('lanl.gov') ||
                        strLeadEmail.contains('lbl.gov') || strLeadEmail.contains('leo.gov') ||
                        strLeadEmail.contains('llnl.gov') || strLeadEmail.contains('memphisfbi.com') ||
                        strLeadEmail.contains('mst48.org') || strLeadEmail.contains('nasa.gov') ||
                        strLeadEmail.contains('nga.gov') || strLeadEmail.contains('nih.gov') ||
                        strLeadEmail.contains('nist.gov') || strLeadEmail.contains('nj1dmat.org') ||
                        strLeadEmail.contains('nmsc.gov') || strLeadEmail.contains('noaa.gov') ||
                        strLeadEmail.contains('nps.edu') ||
                        strLeadEmail.contains('nps.gov') || strLeadEmail.contains('nrc.gov') ||
                        strLeadEmail.contains('nrel.gov') || strLeadEmail.contains('nsf.gov') ||
                        strLeadEmail.contains('ofda.gov') || strLeadEmail.contains('ofda.net') ||
                        strLeadEmail.contains('opm.gov') || strLeadEmail.contains('ornl.gov') ||
                        strLeadEmail.contains('osmre.gov') || strLeadEmail.contains('osti.gov') ||
                        strLeadEmail.contains('peacecorps.gov') || strLeadEmail.contains('pnl.gov') ||
                        strLeadEmail.contains('rl.gov') || strLeadEmail.contains('sandia.gov') ||
                        strLeadEmail.contains('sc-us.gov') || strLeadEmail.contains('sec.gov') ||
                        strLeadEmail.contains('senate.gov') || strLeadEmail.contains('smbcga.org') ||
                        strLeadEmail.contains('saic.com') || strLeadEmail.contains('srs.gov') ||
                        strLeadEmail.contains('ssa.gov') || strLeadEmail.contains('state.gov') ||
                        strLeadEmail.contains('supremecourt.gov') || strLeadEmail.contains('swpa.gov') ||
                        strLeadEmail.contains('treas.gov') || strLeadEmail.contains('tsc.gov') ||
                        strLeadEmail.contains('tva.gov') || strLeadEmail.contains('uncw.edu') ||
                        strLeadEmail.contains('unicor.gov') || strLeadEmail.contains('usaid.gov') ||
                        strLeadEmail.contains('usap.gov') || strLeadEmail.contains('usbr.gov') ||
                        strLeadEmail.contains('uscga.us') || strLeadEmail.contains('uscg-aux.us') ||
                        strLeadEmail.contains('uscourts.gov') || strLeadEmail.contains('usda.gov') ||
                        strLeadEmail.contains('usdoj.gov') || strLeadEmail.contains('usgs.gov') ||
                        strLeadEmail.contains('usgs.gov') || strLeadEmail.contains('usma.edu') ||
                        strLeadEmail.contains('usmc-mccs.org') ||
                        strLeadEmail.contains('usna.edu') || strLeadEmail.contains('uspis.gov') ||
                        strLeadEmail.contains('usps.gov') || strLeadEmail.contains('uspsoig.gov') ||
                        strLeadEmail.contains('wapa.gov') ||
                        strLeadEmail.contains('ngc.com') || strLeadEmail.contains('xetron.com') ||
                        strLeadEmail.contains('emainc.com') || strLeadEmail.contains('saic.com') ||
                        strLeadEmail.contains('unisys.com') || strLeadEmail.contains('caci.com') ||
                        strLeadEmail.contains('itt.com') || strLeadEmail.contains('si-intl.com') ||
                        strLeadEmail.contains('telos.com') || strLeadEmail.contains('gd-ais.com') ||
                        strLeadEmail.contains('gdc4s.com') || strLeadEmail.contains('gd-decisionsystems.com') ||
                        strLeadEmail.contains('gdds.com') || strLeadEmail.contains('gdeb.com') ||
                        strLeadEmail.contains('anteon.com') || strLeadEmail.contains('gdit.com') ||
                        strLeadEmail.contains('gd-ns.com') || strLeadEmail.contains('lmco.com') ||
                        strLeadEmail.contains('savi.com') || strLeadEmail.contains('raytheon.com') ||
                        strLeadEmail.contains('jps.com') || strLeadEmail.contains('ornl.gov')
                        );
    } */ 
    
}