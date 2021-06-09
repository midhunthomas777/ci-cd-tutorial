public with sharing class APTPS_ApproveRejectController {
    public Apttus_Approval__Approval_Request__c thereq;
    public ApexPages.StandardController thecontroller;
    public Apttus_Approval.ApprovalActionController2 baseController;
    String keyPrefix;
    public String approvalRequestId;
    public PageReference currentPage;
    public String customPage;
    public String actionName; 
    public String pageMode;
    
    public APTPS_ApproveRejectController(ApexPages.StandardController controller)
    {
    	System.debug('DEBUG - APTPS_ApproveRejectController ...');
        thereq = (Apttus_Approval__Approval_Request__c)controller.getRecord();
        approvalRequestId = thereq.Id;
        System.debug('DEBUG - Approval Request Id: ' + approvalRequestId);
        PageReference currentPage = ApexPages.currentPage();
        theController = controller; 
        baseController = new Apttus_Approval.ApprovalActionController2(controller);
        Map<String,String> params = currentPage.getParameters();
        this.customPage = params.get('customPage');
        this.actionName = params.get('actionName');
        this.pageMode = params.get('pageMode');
        
        //Schema.DescribeSObjectResult agmtRes = Apttus__Apts_Agreement__c.SObjectType.getDescribe();
        //keyPrefix = agmtRes.getKeyPrefix();
    }
    
    public PageReference rejectApprovalRequest()
    {    
        System.debug('Reject action '+ thereq.id);
        
        PageReference pageRef = baseController.doreject();
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Rejected'));
        
        return new ApexPages.Pagereference('/'+ thereq.Apttus_Approval__Object_Id__c);
        //return new ApexPages.Pagereference('/'+ keyPrefix + '/o');
    }

    
    public PageReference approveApprovalRequest()
    {
        System.debug('doapprove action '+ keyPrefix);
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Approved'));
        PageReference pageRef = baseController.doapprove();
        
        return new ApexPages.Pagereference('/'+ thereq.Apttus_Approval__Object_Id__c);
        //return new ApexPages.Pagereference('/'+ keyPrefix+ '/o');
    }
   
    /*
    public PageReference resendEmailNotification()
    {
        System.debug('Resend Email Notification action ...');
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Approved')); 
        
        thereq.APTPS_Resend_Assignment_Notification__c = true;
        update thereq;
                
        return new ApexPages.Pagereference('/'+ keyPrefix+ '/o');
    }
    */
    
    
    public PageReference checkCurrentApprover()
    {
        System.debug('DEBUG - Check if Logged In User is Current Approver ...');
        
        // Get the current logged in user
        String currentUserId = UserInfo.getUserId();
        System.debug('DEBUG - Current User: ' + currentUserId);
        
        // Check the assigned to type
        String assignedToType = thereq.Apttus_Approval__Assigned_To_Type__c;
        System.debug('DEBUG - Assigned To Type: ' + assignedToType);
        
        // Get the current approver
        String currentApproverId = thereq.Apttus_Approval__Assigned_To_Id__c;
        System.debug('DEBUG - Current Assigned To Approver: ' + currentApproverId);
        
        //Boolean isGroupMember = false;
        Integer iGroupMember = 0;
        
        // If the assigned to type is a queue, check if they are a queue memeber
        if (assignedToType == 'Queue')
        {
       		iGroupMember = [select count() 
        							from GroupMember gm 
        							where gm.UserOrGroupId = :currentUserId 
        							and Group.Id = :currentApproverId
        							and Group.Type = 'Queue'];
        							
        	System.debug('Check If Member of Queue');
        	System.debug('Group Member: ' + iGroupMember);
        							  
        } 
        
        if (assignedToType == 'Role')
        {
       		iGroupMember = [select count() 
        							from GroupMember gm 
        							where gm.UserOrGroupId = :currentUserId 
        							and Group.Id = :currentApproverId
        							and Group.Type = 'Role'];
        							
        	System.debug('Check If Member of Role');
        	System.debug('Group Member: ' + iGroupMember);
        							  
        } 
        
        // Check if the current logged in user is the current approver
        If ((assignedToType == 'User' && currentUserId == currentApproverId) || (assignedToType == 'Queue' && iGroupMember > 0) || (assignedToType == 'Role' && iGroupMember > 0))
        {
        	System.debug('DEBUG - Approval Request - Current Logged in User is the Assigned To...');
            
            // If logged in user is the current approver, approve the request
            PageReference pageRef = baseController.doapprove();
                   	
        	//System.debug('DEBUG - Keyprefix: ' + keyPrefix);
        	System.debug('DEBUG - Agreement Id: ' + thereq.Apttus_Approval__Object_Id__c);
        
            return new ApexPages.Pagereference('/'+ thereq.Apttus_Approval__Object_Id__c);
        }
        else
        {
        	System.debug('DEBUG - Approve Request - Current Logged in User is NOT the Assigned To...');
        	
            // If logged in user is not the current user - Check if an attachment has been added in last 5 mins
            datetime myDateTime = datetime.now();
            datetime fiveminsago = myDateTime.addminutes(-5);
            
            System.debug('DEBUG - Checking for Attachments ...');
            
            Integer iCnt = 
                [SELECT count() 
                  FROM Attachment 
                  WHERE ParentId = :approvalRequestId 
                  AND CreatedById = :currentUserId
                  AND CreatedDate > :fiveminsago];     
            
            System.debug('DEBUG - Number of Attachments: ' + iCnt);
            
            If (iCnt > 0)
            {
            	System.debug('DEBUG - Approve Approval Request...');
            	
                // Approve the request
                PageReference pageRef = baseController.doapprove();
                
        		System.debug('DEBUG - Agreement Id: ' + thereq.Apttus_Approval__Object_Id__c);
                return new ApexPages.Pagereference('/'+ thereq.Apttus_Approval__Object_Id__c);
            }
            else
            {
            	System.debug('DEBUG - Approve Request Denied because there is no attachment ...');
            	
                // Do not allow approval - Give error message and return to screen
                // Put error message here
                //this.hasError = true;
                //this.errorMsg = 'Since you are not the current approver, please attach proof';
                //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'If you are not the current approver, you must add an attachment within the last 5 minutes.'); 
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'An attachment is required in order to approve this record. Please add your attachment and then click approve. (NOTE: The action to approve must occur within 5 minutes of uploading the attachment.)');  
                ApexPages.addMessage(myMsg);
                
                /*currentPage.getParameters().put('Id', thereq.Apttus_Approval__Object_Id__c);
        		currentPage.getParameters().put('customPage', this.customPage);
        		currentPage.getParameters().put('actionName', this.actionName);
        		currentPage.getParameters().put('pageMode', this.pageMode);*/
                  
                //return currentPage;                
                return null;
            }
        }
        
    }
    
}