public class MassTasksCreateExtension {
    ApexPages.StandardSetController setCon;
    public PageReference originalUrl { get; set; }
    public Task task{set;get;}
    public Contact contact{set;get;}
    public String reminderTime{set;get;}
    public Boolean sendNotificationEmailCheckBox{set;get;}
    public Map<Id,String> displayNames{set;get;}
    private Map<Id,Id> ownerIds;
    private Map<String,Id> conUserIdsMap;
    public Boolean showWhoId{set;get;}
    public Boolean assignToOwner{set;get;}
    //Page processing parameters
    private List <Selectoption> selReminderOptions;
    private List<String> arrObjIds;
    private String objName = null;
    private Boolean saveStatus;
    private String objPrefix = null;
    
    public MassTasksCreateExtension(ApexPages.StandardSetController controller) {
        setCon = controller;
        task = new Task();
        task.OwnerId = Userinfo.getUserId();
        contact = new Contact();
        displayNames = new Map<Id,String>();
        ownerIds = new Map<Id,Id>();
        conUserIdsMap = new Map<String,Id>();
        showWhoId = false;
        sendNotificationEmailCheckBox = false;
        saveStatus = false;
        assignToOwner = false;
        arrObjIds = new List<String>();
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        for(sObject selectedAcc : (List<sObject>)setCon.getSelected()) {
            arrObjIds.add(selectedAcc.Id);
        }
        if(arrObjIds != null && !arrObjIds.isEmpty()){
            //Find the object name
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
            Set<String> keyPrefixSet = gd.keySet();
            String tPrefix = arrObjIds[0].subString(0,3);
            for(String sObj : keyPrefixSet){
                Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
                if(tPrefix.equals(r.getKeyPrefix())){
                    objName = r.getName();
                    objPrefix = tPrefix;
                    break;
                }
            }
            //Query the name for all the objects
            if(objName != null){
                String strFieldName = 'Name';
                //Check if the object is a Contact or Lead
                if(objName != 'Contact' && objName != 'Lead'){
                    showWhoId = true;
                }
                //Handle field that doesn't have a name field
                if(objName == 'Case'){
                    strFieldName = 'CaseNumber';
                }
                
                String strQuery = 'select id,OwnerId,' + strFieldName + ' from ' + objName + ' ';
                Boolean bFirst = true;
                for(String strObjId:arrObjIds){
                    if(bFirst){
                        strQuery += ' where Id in (\'';
                        bFirst = false;
                    }else{
                        strQuery += ',\'';
                    }
                    strQuery += String.escapeSingleQuotes(strObjId) + '\'';
                }
                strQuery += ')';
                try{
                    SObject [] sfdcObjects = Database.query(strQuery);
                    //Generate the name list
                    for(SObject sfdcObject:sfdcObjects){
                        displayNames.put((Id)sfdcObject.get('id'),(String)sfdcObject.get(strFieldName));
                        ownerIds.put((Id)sfdcObject.get('id'), (Id)sfdcObject.get('OwnerId'));
                    }
                    for(User conUser : [Select Id,Contact.Id,Contact.Email from User where Contact.Id IN : arrObjIds]) {
                        conUserIdsMap.put(conUser.Contact.Id, conUser.Id);
                    }
                }catch(Exception e){
                    strQuery = strQuery.replace(',' + strFieldName, ' ');
                    SObject [] sfdcObjects = Database.query(strQuery);
                    //Generate the Id list instead of name list
                    for(SObject sfdcObject:sfdcObjects){
                        displayNames.put((Id)sfdcObject.get('id'),(Id)sfdcObject.get('id'));
                    }
                }
            }
        }
    }
    public void assignToOwnerClick(){
        if(assignToOwner){
            assignToOwner = false;
        }else{
            assignToOwner = true;
        }
    }
    
    public void saveNew(){
        System.debug('Into SaveNew Method');
        //Create the new task list
        List <Task> lTask = new List<Task>();
        //Capture the status for save()
        saveStatus = false;
        try{
            System.debug('Into SaveNew Method arrObjIds####'+arrObjIds);
            for(String strObjId:arrObjIds){
                Task taskNew = new Task();
                System.debug('Into SaveNew Method strObjId####'+strObjId);
                System.debug('Into SaveNew Method showWhoId####'+showWhoId);
                System.debug('Into SaveNew Method taskNew###1#'+taskNew);
                
                if(showWhoId){
                    //If the selected objests are not Contacts/Leads
                    taskNew.WhatId = strObjId;
                }else{
                    //If only Contacts/Leads
                    taskNew.WhoId = strObjId;
                }
                System.debug('Into SaveNew Method taskNew###2#'+taskNew);
                //Assign to the record owner based on selected options
                if(assignToOwner && objName != 'Contact'){
                    taskNew.OwnerId = ownerIds.get(strObjId);   
                } else if (objName == 'Contact') {
                    if(task.Subject == 'Annual Resigning'){
                        taskNew.OwnerId = Userinfo.getUserId(); 
                    }else{
                        taskNew.OwnerId = conUserIdsMap.get(strObjId);
                    }
                   // taskNew.OwnerId = conUserIdsMap.get(strObjId);
                } else {
                    taskNew.OwnerId = task.OwnerId;
                }
                
                System.debug('Into SaveNew Method taskNew.OwnerId###3#'+taskNew.OwnerId);
                
                taskNew.status = task.status;
                taskNew.subject = task.subject;
                taskNew.activityDate = task.activityDate;
                taskNew.priority = task.priority;
                taskNew.Task_Description__c = task.Task_Description__c;
                taskNew.Is_Mass__c = true;
                //If the reminder is set
                if(task.IsReminderSet){
                    taskNew.IsReminderSet = true;
                    String [] arrReminderTimes = reminderTime.split(':');
                    Time tmpTime = Time.newInstance(Integer.valueOf(arrReminderTimes[0]), Integer.valueOf(arrReminderTimes[1]), 0, 0);
                    Datetime reminderDateTime = Datetime.newInstance(contact.Birthdate, tmpTime);
                    taskNew.ReminderDateTime = reminderDateTime;
                }
                lTask.add(taskNew);
            }
            //Insert the new tasks to the SFDC Org
            insert lTask;
        }catch(Exception e){
            System.debug('e.getMessage()###'+e.getMessage());
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 'There is an unexpected exception with the selected records, please contact Administrator'));
            return;
        }
        
        saveStatus = true;
        Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.CONFIRM, 'Task(s) successfully created.'));
        //Send email
        if(sendNotificationEmailCheckBox){
            sendMail(lTask);
        }
    }
    /**
* Save the new task and to back to the previous page 
* (If no errors)
*/
    public Pagereference save(){
        saveNew();
        if(saveStatus){
            return back();
        }
        return null;
    }   
    /**
* Send email to the assigned engineer
*/
    @TestVisible
    private void sendMail(List <Task> lTask){
        try{
            Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();
            mail.setTargetObjectIds(new List<String>(conUserIdsMap.keySet()));
            EmailTemplate mailTemplate = [SELECT Id from EmailTemplate WHERE DeveloperName ='Mass_Email_to_Partner_Contacts' LIMIT 1];
            mail.setTemplateID(mailTemplate.Id);
            Messaging.sendEmail(new Messaging.MassEmailMessage[] {mail}); 
        } catch(Exception e){
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 'Task(s) added. Mail not sent.'));
        } 
    }
    
    /**
* Insert in the ReminderDate List the Time : Hours:Min
*/ 
    public List<SelectOption> getselReminderOptions(){
        selReminderOptions = new List<SelectOption>();
        String val = '' ; 
        for (Integer i = 0 ; i < 24 ; i++){
            // Draw the options to add to the reminder picklist 
            val = i+':'+'00';           
            selReminderOptions.add(new SelectOption(val,val));
            val = i+':'+'30';
            selReminderOptions.add(new SelectOption(val,val));
        }
        return selReminderOptions;    
    } 
    /**
* Go to the previous page
*/
    public Pagereference back(){
        Pagereference pageRef;
        if(objPrefix!=null){
            pageRef = new Pagereference('/' + objPrefix);    
        }else{  // Added by Harish to handle Cancel Button on the Page
            pageRef = new Pagereference('/');    
        }
        pageRef.setRedirect(true);
        return pageRef;
    }
    /**
* Display the selected object names in front end
*/
    public List <String> getTableDisplayNames(){
        List <String> rtnList = new List<String>();
        
        for(String displayName:displayNames.values()){
            rtnList.add('-' + displayName);
        }
        return rtnList;
    }    
}