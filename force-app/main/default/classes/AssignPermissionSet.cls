Global class AssignPermissionSet {

  @future 
  public static void AssignPermissionSetToUsers (map<Id,id> usersId,map<Id,String> usersVal) {
    // Perform long-running code
	List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
	map<id,id> permsionsetMap=new map<id,id>();
    for(PermissionSetAssignment permsionset:[SELECT Id, AssigneeId, Assignee.Name,PermissionSetId , PermissionSet.IsOwnedByProfile
    FROM PermissionSetAssignment where AssigneeId in :usersId.values()]){
        System.debug('permsionset========'+permsionset);
        permsionsetMap.put(permsionset.AssigneeId,permsionset.PermissionSetId);
        
    }
     System.debug('permsionsetMap==='+permsionsetMap);
	for(id conlist:usersId.keyset()){
        String abc=usersVal.get(conlist);
        System.debug('abc==='+abc);
        for(String ids:usersVal.get(conlist).split(',')){
        if(permsionsetMap.get(conlist)!= ids){
		PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ids ,AssigneeId = usersId.get(conlist));
		 System.debug('psa==='+psa);
		permissionSetList.add(psa);
        }
	}
	}
      try{
          upsert permissionSetList;
      } catch(Exception exp){
          System.debug('Error found '+exp.getMessage());
      }
  }
    @future 
  	public static void removepermission(map<Id,id> usersId,map<Id,String> usersVal){
	   List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
	   list<string> aId=new list<String>();
      for(id conlist:usersId.keyset()){
            for(String ids:usersVal.get(conlist).split(',')){
                aId.add(ids);
        	}

	   }
	   System.debug('====aId======'+aId);
          permissionSetList=[SELECT Id FROM PermissionSetAssignment WHERE AssigneeId IN : usersId.values() AND PermissionSetId = :aId];
            System.debug('====permissionSetList======'+permissionSetList);
        try{
        	delete permissionSetList;
        }catch(Exception exp){
            System.debug('Exception found '+exp.getMessage());
        }
        

	    
	}
}