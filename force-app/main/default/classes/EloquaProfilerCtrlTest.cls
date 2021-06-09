@isTest
public class EloquaProfilerCtrlTest {
	@isTest
    public static void testEloquaProfilerLead(){
        TestDataSetUpUtils.insertCustomSettings();
        String dt ='12/31/2018';  
        date CloseDT=date.parse(dt);
        Lead newLead = new Lead(
            Company = 'Test Account', LastName= 'Test Lead',
            LeadSource = 'Web',  
            Status = 'Qualified',Lead_Value__c =121,Close_Date__c = CloseDT);
        insert newLead;
        PageReference pageRef = Page.EloquaProfilerLead;
        Test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('isEngage','TRUE');
        String engage;
        ApexPages.StandardController stdCtrl = new ApexPages.standardController(newLead);
        EloquaProfilerCtrl ctrl = new EloquaProfilerCtrl(stdCtrl);
        
    }
    
    @isTest
    public static void testEloquaProfilerContact(){
        TestDataSetUpUtils.insertCustomSettings();
        Id accRectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Account accTest = new Account( Name='Test Account Partner',
                                      RecordTypeId = accRectypeID,BillingStreet='12th Street',
                                      BillingCity='Bangalore',BillingCountry='India',BillingPostalCode='560100',
                                      Motorola_Customer_Number__c=String.valueOf(Math.abs(Crypto.getRandomInteger())),
                                      Role_Created__c = true,Partner_Region__c='NAMR');
        insert accTest;
        Id conRectypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Contact partTestCont = new Contact(
            AccountId = accTest.Id,
            RecordtypeId = conRectypeID,
            FirstName = 'Test',
            LastName = 'Partner Contact',
            FirstNameLocal = 'Test',
            LastNameLocal = 'Partner Contact');
        insert partTestCont;
        PageReference pageRef = Page.EloquaProfilerContact;
        Test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('isEngage','FALSE');
        ApexPages.StandardController stdCtrl = new ApexPages.standardController(partTestCont);
        EloquaProfilerCtrl ctrl = new EloquaProfilerCtrl(stdCtrl);
    }
    
    @isTest
    public static void testEloquaProfilerOppty(){
        TestDataSetUpUtils.insertCustomSettings();
        Opportunity oppty = new opportunity(ownerId=Userinfo.getUserID(),name='test654',StageName='Commit',
                                           CloseDate=Date.newInstance(2010,10,10),Clone_Check__c=true,
                                           Industry__c='Education',Channel_Opportunity__c='Direct');
        insert oppty;
        PageReference pageRef = Page.EloquaProfilerOpportunity;
        Test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('isEngage','FALSE');
        ApexPages.StandardController stdCtrl = new ApexPages.standardController(oppty);
        EloquaProfilerCtrl ctrl = new EloquaProfilerCtrl(stdCtrl);
        
    }
}