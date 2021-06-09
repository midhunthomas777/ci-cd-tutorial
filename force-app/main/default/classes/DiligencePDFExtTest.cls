@isTest
public class DiligencePDFExtTest {
            @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
        TriggerSettings__C agreetrgr = new TriggerSettings__C(Name = 'AgreementTriggerDisabled', IsActive__c = TRUE);
        insert agreetrgr;
    }
    
    static testmethod void myUnitTest(){
    Apttus__APTS_Agreement__c Agre = new Apttus__APTS_Agreement__c(Name='Test1');
    insert Agre;
PageReference pageRef = Page.Generate_Diligence;
Test.setCurrentPage(pageRef);
ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(Agre);
ApexPages.currentPage().getParameters().put('Id',Agre.id);

DiligencePDFExt ec = new DiligencePDFExt(sc);
    }
}