/* This SOAP Class provides information to CPQ on whether the User has the access to the opportunity record. The call is expected to send the FederationId and Opportunity
 * Record Id*/

/* Written by Swami Ganesan basis on the request by CPQ team */
/* It looks up the BigMachines__Login field in User and matches the passId against that */

global class CPQSoApCallForOpportunity {

    webservice  static Boolean  GetrecordAccess(String myUser, Id myRecord)
    {
       
        Integer  myUserCount = [SELECT Count() from User where FederationIdentifier = :myUser ];
        if(myUserCount == 0)
        {
            system.debug('User does not exist for '+myUser);
            return FALSE;
        }
        system.debug('User Id = '+myUserCount);
        Id myUserId = [SELECT Id from User where FederationIdentifier = :myUser LIMIT 1].Id;
        String Query = 'SELECT RecordId,MaxAccessLevel   FROM UserRecordAccess WHERE UserId = \''+myUserId+'\' And RecordId = \''+myRecord + '\' LIMIT 1';
        system.debug(Query);
        List<UserRecordAccess> MaxAccessLevel = Database.query(Query);
        
        if(MaxAccessLevel.isEmpty()) 
        {
            system.debug('List is empty');
            return FALSE;
        }
        String Access = MaxAccessLevel[0].MaxAccessLevel;
        system.debug('AccessReturn ='+Access);
        if(Access == 'None')
                return False;
        else
                return TRUE;           
        return FALSE;
    }

}