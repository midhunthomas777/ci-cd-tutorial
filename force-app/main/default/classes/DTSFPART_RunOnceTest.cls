@isTest
public class DTSFPART_RunOnceTest {
    
    @isTest
    private static void hasAlreadyfiredTest() {
        DTSFPART_RunOnce.setAlreadyfired('Test');
        Boolean hasAlreadyFired = DTSFPART_RunOnce.hasAlreadyfired('Test');
        System.assertEquals(true, hasAlreadyFired);
    }
}