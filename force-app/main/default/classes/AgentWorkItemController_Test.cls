@isTest
private class AgentWorkItemController_Test {

    //Mock callout
    private class mockCallout implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            System.assertEquals('callout:PureCloud_Omni_Sync/users/7247e6ae-91ff-41e2-a7d6-c03721103e1d/presences/purecloud', req.getEndpoint());
            System.assertEquals('PATCH', req.getMethod());
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('{"errorMsg":""}');
            return res;
        }
    }

    @isTest (SeeAllData=true)
    static void changePhoneCallStatusTest(){
        test.startTest();
        //get user who is setup for purecloud
        User agent = [SELECT Id,PureCloud_User_ID__c 
                      FROM User 
                      WHERE PureCloud_User_ID__c!= NULL AND Id = '00534000003hcJTAAY' 
                      LIMIT 1 ];
        System.runAs(agent){
            //create a task -to do
            Task pureCloudTask = new Task(
                Subject='Call',
                ActivityDate=Date.Today(),
                Status = 'Not Started',
                Priority='Normal',
                CreatedById = agent.Id 
            );
            insert pureCloudTask;
            
            pureCloudTask.Purecloud_Conversation_ID__c = EncodingUtil.convertToHex(Crypto.generateAesKey(128)).substring(0, 32);
            update pureCloudTask;
            
            System.debug('##PCTask##'+PureCloudTask);
            //create a Phone_Call__c record
            Phone_Call__c phoneCallRec  = new Phone_Call__c(
                Purecloud_Conversation_ID__c=pureCloudTask.Purecloud_Conversation_ID__c,
                OwnerId = agent.Id,
                Work_Item_Status__c='In Progress',
                CreatedById = agent.Id 
            );
            insert phoneCallRec;
            System.debug('##phone call record##'+phoneCallRec);
            
            ServiceChannel sc = [SELECT Id 
                                 FROM ServiceChannel 
                                 WHERE DeveloperName = 'Phone_Call' 
                                 LIMIT 1];
            //create an agentWorkItem record  //assign the agentWorkItem record to the agent user
            AgentWork aw = new AgentWork(
                ServiceChannelId = sc.Id,
                WorkItemId = phoneCallRec.Id,
                UserId = agent.Id
            );
            insert aw;
            AgentWorkItemController.changePhoneCallStatus(pureCloudTask.Id,agent.Id);
            System.debug('updated 1 phoneCallRec'+phoneCallRec);
            phoneCallRec.Work_Item_Status__c = 'Closed';
            update phoneCallRec;
            update aw;
            test.stopTest();
        }
    }

    @isTest (SeeAllData=true)
    static void changePureCloudStatusOnCapacity1Test1(){
        User agent = [SELECT Id,PureCloud_User_ID__c 
        FROM User 
        WHERE PureCloud_User_ID__c!= NULL AND Id = '00534000003hcJTAAY' 
        LIMIT 1 ];
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new mockCallout());
        AgentWorkItemController.changePureCloudStatusOnCapacity1(agent.id,'FULL');
        test.stopTest();
    }

    @isTest (SeeAllData=true)
    static void changePureCloudStatusOnCapacity1Test2(){
        User agent = [SELECT Id,PureCloud_User_ID__c 
        FROM User 
        WHERE PureCloud_User_ID__c!= NULL AND Id = '00534000003hcJTAAY' 
        LIMIT 1 ];
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new mockCallout());
        AgentWorkItemController.changePureCloudStatusOnCapacity1(agent.id,'NOT FULL');
        test.stopTest();
    }

    @isTest (SeeAllData=true)
    static void changePureCloudStatusTest1(){
        User agent = [SELECT Id,PureCloud_User_ID__c 
        FROM User 
        WHERE PureCloud_User_ID__c!= NULL AND Id = '00534000003hcJTAAY' 
        LIMIT 1 ];
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new mockCallout());
        //Presence Status - Available_Phone_Case
        AgentWorkItemController.changePureCloudStatus(agent.id,'Available_Phone_Case');
        test.stopTest();

    }

    @isTest (SeeAllData=true)
    static void changePureCloudStatusTest2(){
        User agent = [SELECT Id,PureCloud_User_ID__c 
        FROM User 
        WHERE PureCloud_User_ID__c!= NULL AND Id = '00534000003hcJTAAY' 
        LIMIT 1 ];
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new mockCallout());
        //Presence Status - Available_Phone_Case
        AgentWorkItemController.changePureCloudStatus(agent.id,'Available_Case');
        test.stopTest();

    }

}