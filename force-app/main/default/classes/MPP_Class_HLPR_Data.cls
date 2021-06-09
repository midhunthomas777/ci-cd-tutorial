public class MPP_Class_HLPR_Data {
	public enum OpperationType {INSERT_RECS, UPDATE_RECS, DELETE_RECS}
	
	public static Boolean commitToDB(OpperationType op, List<sObject> objList){
		try{
			if(op === OpperationType.INSERT_RECS){
				insert objList;
			}			
			if(op == OpperationType.UPDATE_RECS){
				update objList;
			}
			if(op == OpperationType.DELETE_RECS){
				delete objList;
			}
			return true;
		}catch(Exception e){
			System.debug('exception in commitToDB:  ' + e);
			return false;
		}
	} 
	 
	//Null or blank where clause returns everything
	public static List<sObject> selectAllFrom(String objName, String whereClause){
		List<sObject> sobjList;
		try{
			Map<String, SObjectField> objFields = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
			if(objFields != null){
				String query = 'SELECT ';
				for(String f : objFields.keySet()){
					query += ' ' + f + ',';				
				}
				//remove the last comma
				query = query.substring(0, query.length() - 1);
				query += ' FROM ' + objName; 
				
				if(whereClause != null && whereClause != ''){
					query += ' ' + whereClause;
				}
				
				sobjList = Database.query(query);
			}
		}catch(Exception e){
			System.debug('error in generating the query:  ' + e);
		}

		return (sobjList == null || sobjList.isEmpty())?new List<sObject>():sobjList;		
	}	
}