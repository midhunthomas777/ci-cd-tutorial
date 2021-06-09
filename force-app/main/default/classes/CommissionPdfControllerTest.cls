@isTest
public class CommissionPdfControllerTest {
    @isTest
    public static void CommissionPdfControllerTest(){
        TestDataSetUpUtils.insertCustomSettings();
        Id PartnrRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id MCNrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        String mncNumber=string.valueof(integer.valueof(math.random()*1000000000)*100); 
        List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
        List<Account> lstMCNAccount=TestDataSetUpUtils.createMCNAccounts(1, MCNrectypeID, lstAccount);
        Account partnerAccount=TestDataSetUpUtils.createPartnerAccount(PartnrRecordTypeId);
        Account upMcn = new Account();
        upMcn.id= lstMCNAccount.get(0).Id;
        upMcn.Assigned_MR__c=partnerAccount.Id;
        update upMcn;
        Test.startTest();
        Partner_Identifier__c pI = new Partner_Identifier__c();
        pI.ID_Number__c='965432';
        pI.ID_Type__c='Federal Manufacturer Representative ID';
        pI.Account__c=partnerAccount.Id;
        insert pI;
        
        Partner_Identifier__c partnerIdentifier = new Partner_Identifier__c();
        partnerIdentifier.ID_Number__c='9654432';
        partnerIdentifier.ID_Type__c='State and Local Manufacturer Representative ID';
        partnerIdentifier.Account__c=partnerAccount.Id;
        insert partnerIdentifier;
        
        Partner_Type__c pgminfo = new Partner_Type__c();
        pgminfo.Account__c = partnerAccount.id;
        pgminfo.Program__c = 'RADIO';
        pgminfo.Status__c = 'Active'; 
        pgminfo.Purchasing_Method__c='Tier 16';
        pgminfo.US_Federal__c=True;
        pgminfo.RHO__c=True;
        insert pgminfo;
        
        Technology_Specialization__c techspec = new Technology_Specialization__c();
        techspec.Account__c = partnerAccount.Id;
        techspec.Partner_Program__c = pgminfo.Id;
        techspec.Technology_Specialization__c = 'Mission Critical Radio Systems';
        techspec.Technology_Specialization_Status__c =  'Active';
        techspec.Community_Type__c= 'State/Local Manufacturer Representative';
        insert techspec;
        
        MR_Commission_Calculator__c mrcalc = new MR_Commission_Calculator__c(Box_Order_Amount__c=9999,
                                                                             Box_Override_Commission_Dollars__c=100,
                                                                             Motorola_Customer_Number__c = upMcn.Id);
        
        insert mrcalc; 
        
        ApexPages.currentPage().getParameters().put('mrCalc',mrcalc.Id);
        ApexPages.currentPage().getParameters().put('isccmr','true');
        ApexPages.currentPage().getParameters().put('motoNum',mncNumber);
        ApexPages.currentPage().getParameters().put('accountId',lstAccount.get(0).Id);
        ApexPages.currentPage().getParameters().put('partnerId',lstMCNAccount.get(0).Id);
        ApexPages.currentPage().getHeaders().put('content-disposition', 'attachment'); 
        ApexPages.currentPage().getHeaders().put('filename', 'pdf'); 
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(mrcalc);
        CommissionPdfController controller = new CommissionPdfController(stdcontroller);   
        controller.mrCalc=mrcalc;
        Test.stopTest();
    }
}