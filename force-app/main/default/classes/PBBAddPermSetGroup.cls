public with sharing class PBBAddPermSetGroup {
	
	@InvocableMethod(label='Add Permission Set Group to User')
	public static void AddPermSetGroup(list<AddPermSetGrpRequest> requests) {

		list<string> output = new list<string>();

		for (AddPermSetGrpRequest request:dedupe(requests)){
			//system.debug(request);
			//future methods can only accept primitives, so we serialize to a list of string
			output.add(JSON.serialize(request));
		}

		AddPermsLater(output);

	}

	//what Process Builder/Flow Builder can reference for the input variables
	public class AddPermSetGrpRequest {
		@InvocableVariable(required=true label='Permission Set Group Id')
		public Id PermissionSetGroupId;

		@InvocableVariable(required=true label='User Id')
		public Id UserId;
	}

	public static list<AddPermSetGrpRequest> dedupe(list<AddPermSetGrpRequest> input){
		set<AddPermSetGrpRequest> temp = new set<AddPermSetGrpRequest>(input);
		return new list<AddPermSetGrpRequest>(temp);
	}

	//has to be handled as an @future transaction because the mixed DML issue!
	@future
	public static void AddPermsLater (list<string> requests){
		list<PermissionSetAssignment> PSAs = new list<PermissionSetAssignment>();

		for (string request:requests){
			//turn it back into the request object per Quinton Wall
			//https://developer.salesforce.com/blogs/developer-relations/2013/06/passing-objects-to-future-annotated-methods.html
			AddPermSetGrpRequest APSR = (AddPermSetGrpRequest)JSON.deserialize(request, AddPermSetGrpRequest.class);
			
			PermissionSetAssignment PSA = new PermissionSetAssignment();
			PSA.AssigneeId = APSR.UserId;
			PSA.PermissionSetGroupId = APSR.PermissionSetGroupId;
			PSAs.add(PSA);			
		}
        if(!PSAs.isEmpty()){
            insert PSAs;
        }
		
	}

}