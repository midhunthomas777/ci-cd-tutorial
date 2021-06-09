/*  
* Class Name  : ContactPermissionsTriggerHelper
* Description:  This class is used in Contact Permissions with MCNs
*/

public class ContactPermissionsTriggerHelper {
    
    public void validateMCN(List<Contact_Permissions__c> incoming) {
        
        Map<String,String> uniqueStrings = new Map<String,String>();
        for(Contact_Permissions__c CP : incoming) {
            if(String.isNotBlank(CP.MCN_Account__c)) {
                uniqueStrings.put(CP.Parent_Account__c+'#'+CP.MCN_Account__c, CP.Id);
            }
        }
        system.debug('#######uniqueStrings########## => ' + uniqueStrings);
        
        Map<String,MCN_Permission__c> parentPermissions = new Map<String,MCN_Permission__c>();
        for(MCN_Permission__c mcnAccount : [Select Enterprise_MCN_Unique__c,Permissions__c,Customer_OR_Partner_Account__c 
                                            from MCN_Permission__c where Enterprise_MCN_Unique__c IN : uniqueStrings.keySet()]){
                                                parentPermissions.put(mcnAccount.Enterprise_MCN_Unique__c, mcnAccount);
                                            }
        system.debug('#######parentPermissions########## => ' + parentPermissions);
        for(Contact_Permissions__c CP : incoming) {
            if(String.isNotBlank(CP.MCN_Account__c)) {
                MCN_Permission__c MCNP = parentPermissions.get(CP.Parent_Account__c+'#'+CP.MCN_Account__c);
                if(MCNP != NULL) {
                    CP.MCN_Permission__c = MCNP.Id;
                    List<String> parentPermissionList = new List<String>();
                    If(String.isNotBlank(MCNP.Permissions__c)){
                        parentPermissionList = MCNP.Permissions__c.split(';');
                    }
                    List<String> userPermissionList = new List<String>();
                    If(String.isNotBlank(CP.Permissions__c)){
                        userPermissionList = CP.Permissions__c.split(';');
                    }
                    String errors = 'These Permissions (';
                    Boolean tempFlag = false;
                    for(String userPermission : userPermissionList) {
                        if(!parentPermissionList.contains(userPermission)) {
                            errors = errors + userPermission + ',';
                            tempFlag = true;
                        }
                    }
                    errors = errors.removeEnd(',');
                    if(tempFlag) {
                        CP.addError(errors + ') are not entitled to the Enterprise of this User');
                    }
                } else {
                    //CP.addError('Selected MCN and Parent don\'t have relationship in MCN Permissions, without this Contact can\'t be added.');
                }
            }
        }
    }
    
}