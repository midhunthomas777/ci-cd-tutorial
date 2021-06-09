@isTest
public class DTSFPART_ContactMcnPermRemovalRefTest {
  
    @isTest
    public static void addTest() {
        DTSFPART_ContactMcnPermRemovalReference contactMcnPermRemovalReference = null;

        Test.startTest();
        contactMcnPermRemovalReference = new DTSFPART_ContactMcnPermRemovalReference();
        contactMcnPermRemovalReference.add('0031F00000ccZiAQAU', '0031F00000ccZiAQAU');
        Test.stopTest();
    }

    @isTest
    public static void addAllTest() {
        DTSFPART_ContactMcnPermRemovalReference contactMcnPermRemovalReference = null;

        Test.startTest();
        contactMcnPermRemovalReference = new DTSFPART_ContactMcnPermRemovalReference();
        contactMcnPermRemovalReference.addAll('0031F00000ccZiAQAU');
        Test.stopTest();
    }

    @isTest
    public static void shouldExistTest() {
        Contact_Permissions__c contactPermission = new Contact_Permissions__c();
        contactPermission.MCN_Account__c = '0031F00000ccZiAQAU';
        contactPermission.Contact__c = '0013400001K1X89AAF';
        Boolean isExisit = false;
        Test.startTest();
        DTSFPART_ContactMcnPermRemovalReference contactMcnPermRemovalReference = new DTSFPART_ContactMcnPermRemovalReference();
        isExisit = contactMcnPermRemovalReference.shouldExist(contactPermission);
        Test.stopTest();
    }
}