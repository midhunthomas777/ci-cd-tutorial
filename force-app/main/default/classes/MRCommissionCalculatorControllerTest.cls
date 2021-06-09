@isTest
public class MRCommissionCalculatorControllerTest {
    @isTest
    public static void mrCommissionCalculatorTest(){
        TestDataSetUpUtils.insertCustomSettings();
        User partneruser= TestDataSetUpUtils.createPortalUser();
                String mncNumber=string.valueof(integer.valueof(math.random()*1000000000)*100);

        system.runAs(partneruser){ 
            Test.startTest();
            MRCommissionCalculatorController.fetchMCN('jackson',mncNumber,'Illinois','United States','EDNA','411057','MR Led');
            MRCommissionCalculatorController.fetchStates('United States');
            MRCommissionCalculatorController.isPartnerUser();
            Test.stopTest();
        }
    }
}