@isTest
public class MassTasksCreateExtensionTest {
    @testSetup static void setup(){
        TestDataSetUpUtils.insertCustomSettings();
    }
    
    static testMethod void myUnitTest() {
        Test.startTest();
        
        //Create Accounts
        Id prospectRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1,prospectRecTypeId);
        //Create Contacts
        List <Contact> lstContact = new List<Contact>();
        Contact contact1 = new Contact();
        contact1.LastName = 'Test_Contact_01';
        lstContact.add(contact1);
        
        Contact contact2 = new Contact();
        contact2.LastName = 'Test_Contact_01';
        lstContact.add(contact2);
        insert lstContact;
        
        //Get a profile from SFDC
        Profile profile = [select Id from Profile limit 1];
        
        //Create a user
        /*User user = new User();
        user.Username = 'Test_user_name@test.com';
        user.LastName = 'Test_last_name';
        user.ProfileId = profile.Id;
        user.contactId=lstContact[0].Id;
        user.Alias = 'tst';
        user.Email = 'Test_email@email.com';
        user.CommunityNickname = 'Test_nick_name';
        user.TimeZoneSidKey = 'GMT';
        user.LocaleSidKey = 'en_US';
        user.LanguageLocaleKey = 'en_US';
        user.EmailEncodingKey = 'ISO-8859-1';
        insert user;*/
                User user= TestDataSetUpUtils.createPortalUser();

        //Simulate the page for What Id
        PageReference pPageReference = Page.MassTaskCreateAccountVF;
        Test.setCurrentPage(pPageReference);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(lstAccount);
        sc.setSelected(lstAccount);
        MassTasksCreateExtension controler = new MassTasksCreateExtension(sc);
        
        controler.getTableDisplayNames();
        //controler.saveNew();
        controler.save();
        controler.back();
        
        //Simulate the page for Who Id
        pPageReference = Page.MassTaskCreateAccountVF;
        Test.setCurrentPage(pPageReference);
        ApexPages.StandardSetController sc1 = new ApexPages.StandardSetController(lstContact);
        sc1.setSelected(lstContact);
        controler = new MassTasksCreateExtension(sc1);
        
        controler.getTableDisplayNames();
        controler.getselReminderOptions();
        controler.saveNew();
        Pagereference pageRef = controler.save();
        
        controler.back();
        
        controler.task.OwnerId = user.Id;
        controler.task.Subject = 'Test_Subject';
        controler.task.Status = 'Completed';
        controler.task.Priority = 'High';
        //Set the reminder
        controler.task.IsReminderSet = true;
        controler.contact.Birthdate = Date.today();
        controler.reminderTime = '23:30';
        //Send Email notification
        controler.sendNotificationEmailCheckBox = true;
        
        controler.saveNew();
        pageRef = controler.save();
        controler.assignToOwnerClick();
        
        List<Task> taskList = new List<Task>();
        taskList.add(controler.task);
        controler.sendMail(taskList);
        Test.stopTest();
    }
}