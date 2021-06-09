/*  
* File Name  : FOPGoldSheetPermissionCheck 
* Description: This Code is the controller class for the Visualforce page "FieldOfPlayGoldSheetLaunch". 
               This class is written to check the permission of the users to view/ edit the Gold Sheet.
* Author     : Vishal Rao Jujaray - Infosys Technologies Limited
* Modification Log 
* ============================================================================= 
* Ver   Date        Author                         Modification 
* -----------------------------------------------------------------------------------------------------------------------------------------
* 1.0   17-Dec-12   Vishal Rao Jujaray              Initial Code
* 
*/
public class FOPGoldSheetPermissionCheck {
    public id userId = UserInfo.getUserId();
    public id currentPgId = ApexPages.currentPage().getParameters().get('id'); 

    public field_of_play__c FieldOfPlayParent=[SELECT Id, account__c FROM field_Of_Play__c WHERE  Id=:currentPgId];
      
    public Account[] accs =[SELECT ID,Name FROM Account WHERE Id = :FieldOfPlayParent.account__c];                    

    public boolean isReadOnlyFlag{
        get{
        if(isReadOnlyFlag == null){
            isReadOnlyFlag= True;
        }
        return isReadOnlyFlag;
        }
        set;
        }                   


    public FOPGoldSheetPermissionCheck (ApexPages.StandardController controller) {
        UserRecordAccess[]  sRecordIDs = [SELECT RecordID,HasReadAccess, HasEditAccess  FROM UserRecordAccess WHERE UserId = :userId and RecordID =:accs[0].id ];
        if(!sRecordIDs.isEmpty()){
        system.debug('user details ::::::::'+sRecordIDs[0]);
            if(sRecordIDs[0].HasEditAccess ==true )
            isReadOnlyFlag= false;
            else 
            isReadOnlyFlag= true;
          }
          else 
            isReadOnlyFlag= true;
    }  
}