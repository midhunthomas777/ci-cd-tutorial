@isTest
public class DTSFPART_TriggerConfigurationServiceTest {
    
    @isTest
    static void isTriggerLogicDisabledTest() {
        Boolean isTriggerDisabled = true;

        Test.startTest();
        isTriggerDisabled = new DTSFPART_TriggerConfigurationService('ALL', 'ALL').isTriggerLogicDisabled();
        Test.stopTest();

        System.assertEquals(false, isTriggerDisabled);
    }
}