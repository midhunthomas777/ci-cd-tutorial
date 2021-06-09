public class MPP_Class_CTRL_AddGroupsToUser {
	public Attribute_Group_Mapping__c agm{get;set;}
	public String groupSearch{get;set;}
	public Boolean hasSearched{get;set;}
	public Boolean hasGroups{get;set;}
	public Boolean isNew{get;set;}
	public List<CustomGroup> groupList{get;set;}
	public String idOfGroup {get;set;}
	public Map<Id, String> groupMap = new Map<Id, String>();
	
	public MPP_Class_CTRL_AddGroupsToUser(ApexPages.StandardController ctrl){
		agm = new Attribute_Group_Mapping__c();
		groupList = new List<CustomGroup>();
		hasSearched = false;
		hasGroups = false;
		groupSearch = ''; 
		idOfGroup = '';
		isNew = true;
		Attribute_Group_Mapping__c tempAGM = (Attribute_Group_Mapping__c)ctrl.getRecord();
		if(tempAGM != null){
			for(Attribute_Group_Mapping__c a : [Select Technology_Specialization__c, Technology_Specialization_Level__c, SystemModstamp, Role__c, Region__c, Purchasing_Method__c, Program_Level__c, OwnerId, Name, Market_Specialization__c, Market_Specialization_Level__c, LastModifiedDate, LastModifiedById, Language__c, IsDeleted, Id, Group__c, GroupId__c, CurrencyIsoCode, CreatedDate, CreatedById, Country__c, ConnectionSentId, ConnectionReceivedId, Community__c, Application_Specialization__c, Application_Specialization_Level__c
												From Attribute_Group_Mapping__c
												WHERE Id = :tempAGM.Id]){
				agm = a;
				isNew = false;
			}
		} 
	}
	
	public PageReference save(){
		String theId = '';
		if(!validateForm()){
			return null;
		}else{
			try{
				if(isNew){
					insert agm;
					theId = agm.Id;
				}else{
					Attribute_Group_Mapping__c agm2 = new Attribute_Group_Mapping__c();
					agm2 = agm.clone(false);
					delete agm;
					insert agm2;
					theId = agm2.Id;
				}
			}catch(Exception e){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error saving the record -- ' + e.getMessage()));
				return null;
			}
		}
		return new PageReference('/' + theId);
	}
	
	public PageReference cancel(){
		return (ApexPages.currentPage().getParameters().get('retURL') == null)?new PageReference('/'):new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
	} 
	
	public PageReference searchGroups(){
		groupList.clear();
		groupMap.clear();
		String tempName = 'PC-%' + groupSearch + '%';
		for(Group g : [Select Id, Name FROM Group WHERE Name LIKE :tempName LIMIT 200]){
			System.debug('g.Name:  ' + g.Name);
			groupList.add(new CustomGroup(g.Id, g.Name));
			groupMap.put(g.Id, g.Name);
		}
		hasGroups = (groupList.isEmpty())?false:true;
		hasSearched = true;
		System.debug('hasGroups: ' + hasGroups);
		System.debug('hasSearched:  ' + hasSearched);
		return null;
	}
	
	public PageReference selectGroup(){
		agm.GroupId__c = idOfGroup;
		agm.Group__c = groupMap.get(idOfGroup);
		return null;
	}
	
	public Boolean validateForm(){
		Boolean isError = false;
		if(agm.Technology_Specialization__c == null &&
		   agm.Technology_Specialization_Level__c == null &&
		   agm.Region__c == null &&
		   agm.Purchasing_Method__c == null &&
		   agm.Program_Level__c == null &&
		   agm.Market_Specialization__c == null &&
		   agm.Market_Specialization_Level__c == null &&
		   agm.Language__c == null &&
		   agm.Country__c == null &&
		   agm.Community__c == null &&
		   agm.Application_Specialization__c == null &&
		   agm.Application_Specialization_Level__c == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select at least one option'));
			isError = true;
		}
		if(agm.Technology_Specialization__c != null && agm.Technology_Specialization_Level__c == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select a Technology Specialization Level if a Technology Specialization is selected'));
			isError = true;
		}
		if(agm.Technology_Specialization__c == null && agm.Technology_Specialization_Level__c != null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select a Technology Specialization if a Technology Specialization Level is selected'));
			isError = true;
		}
		if(agm.Market_Specialization__c != null && agm.Market_Specialization_Level__c == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select a Market Specialization Level if a Market Specialization is selected'));
			isError = true;
		}
		if(agm.Market_Specialization__c == null && agm.Market_Specialization_Level__c != null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select a Market Specialization if a Market Specialization Level is selected'));
			isError = true;
		}
		if(agm.Application_Specialization__c != null && agm.Application_Specialization_Level__c == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select a Application Specialization Level if a Application Specialization is selected'));
			isError = true;
		}
		if(agm.Application_Specialization__c == null && agm.Application_Specialization_Level__c != null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select a Application Specialization if a Application Specialization Level is selected'));
			isError = true;
		}
		
		return (isError)?false:true;
	}
	
	public class CustomGroup{
		public Id id{get;set;}
		public String name{get;set;}
		
		public CustomGroup(Id id, String name){
			this.id = id;
			this.name = name;
		}
	}
}