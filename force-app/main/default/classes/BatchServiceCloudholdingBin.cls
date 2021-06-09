global class BatchServiceCloudholdingBin implements Database.batchable<sObject>{
    global Database.querylocator start(Database.batchableContext bc){   
        //Call GlobalUtility Class to fetch business days....
        DateTime days3back = GlobalUtility.subtractDays(DateTime.Now(),3,'NA Radio Lead Management'); // Fetch previous business days..
        //DateTime days3back = DateTime.Now().AddDays(-3);  
        //Removing 'MSI_Support_Case_Incident' reference from the below query - "(OR recordtype.developerName = 'MSI_Support_Case_Incident')".....
        return Database.getQueryLocator([Select Id,OwnerId,owner.Name from Case where Owner.type = 'Queue' and (recordtype.developerName='Admin_Service_Case' OR recordType.developerName = 'MSI_Support_Case_Technical_Request' OR recordtype.developerName = 'MSI_Support_Case_Application_Support' OR recordtype.developerName = 'MSI_Support_Case_Administrative' OR recordtype.developerName = 'MSI_Support_Case_Order_Management' OR recordtype.developerName = 'Image') and Status != 'Closed' AND Id NOT IN (Select ParentId from CaseFeed where CreatedDate >: days3back) 
           AND Id NOT IN (Select ParentId from EmailMessage where CreatedDate >: days3back) ]);
          
    }
    global void execute(Database.BatchableContext BC, List<Case> scope){HoldingBinClass.performCaseUpdate(scope);
    }
    global void finish(Database.BatchableContext BC){}
}