public with sharing class PBBRemovePermSetGroup {
    
    @InvocableMethod(label='Remove Permission Set Group to User')
    public static void RemovePermSetGroup(list<RemovePermSetGrpRequest> requests) {
        
        list<string> output = new list<string>();
        
        for (RemovePermSetGrpRequest request:dedupe(requests)){
            //system.debug(request);
            //future methods can only accept primitives, so we serialize to a list of string
            output.add(JSON.serialize(request));
        }
        
        AddPermsLater(output);
        
    }
    
    //what Process Builder/Flow Builder can reference for the input variables
    public class RemovePermSetGrpRequest {
        @InvocableVariable(required=true label='Permission Set Group Id')
        public Id PermissionSetGroupId;
        
        @InvocableVariable(required=true label='User Id')
        public Id UserId;
        
    }
    
    public static list<RemovePermSetGrpRequest> dedupe(list<RemovePermSetGrpRequest> input){
        set<RemovePermSetGrpRequest> temp = new set<RemovePermSetGrpRequest>(input);
        return new list<RemovePermSetGrpRequest>(temp);
    }
    
    //has to be handled as an @future transaction because the mixed DML issue!
    @future
    public static void AddPermsLater (list<string> requests){
        list<PermissionSetAssignment> removePSAs = new list<PermissionSetAssignment>();
        for (string request:requests){
            //turn it back into the request object per Quinton Wall
            //https://developer.salesforce.com/blogs/developer-relations/2013/06/passing-objects-to-future-annotated-methods.html
            RemovePermSetGrpRequest APSR = (RemovePermSetGrpRequest)JSON.deserialize(request, RemovePermSetGrpRequest.class);
            removePSAs = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =: APSR.UserId AND PermissionSetGroupId =: APSR.PermissionSetGroupId];
        }
        if(!removePSAs.isEmpty()){
            delete removePSAs;
        }
        
    }
    
}