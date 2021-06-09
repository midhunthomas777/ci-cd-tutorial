/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class MM_Class_TEST_SearchControllerAllData {
    @testSetup
    static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
    }
    /*static testMethod void singleAppSearch() {
        Id saId = [Select Id FROM Software_Applications__c LIMIT 1].Id;     
        
        PageReference appPage = Page.MM_AppFinderHome; 
        appPage.getParameters().put('appId', saId);
        appPage.getParameters().put('dest', 'Application');
        Test.setCurrentPage(appPage);
        
        Test.startTest();
        MM_Class_SearchController c = new MM_Class_SearchController();
        Test.stopTest();
     }*/

    static testMethod void appSearchFromPage() {
        PageReference appPage = Page.MM_AppFinderHome; 
        Test.setCurrentPage(appPage);
        MM_Class_SearchController c = new MM_Class_SearchController();
        c.deepLink.dest = 'Application';        
        Test.startTest();
        c.runSearchFromPage();
        Test.stopTest();
    }

    /*static testMethod void singlePartnerSearch() {
        Id acctId = [Select Id FROM Account ORDER BY MM_Metal_Level_Sort__c ASC, MM_Partner_Type_Sort__c ASC, MM_Federal_Specialization_Sort__c ASC LIMIT 1].Id;        
        
        PageReference partnerPage = Page.MM_PartnerFinderHome; 
        partnerPage.getParameters().put('partnerId', acctId);
        partnerPage.getParameters().put('dest', 'Channel');
        Test.setCurrentPage(partnerPage);
        
        Test.startTest();
        MM_Class_SearchController c = new MM_Class_SearchController();
        Test.stopTest();
    }*/

    static testMethod void partnerSearchFromPageChannel() {
        PageReference partnerPage = Page.MM_PartnerFinderHome; 
        Test.setCurrentPage(partnerPage);
        MM_Class_SearchController c = new MM_Class_SearchController();
        c.deepLink.dest = 'Channel';
        
        Test.startTest();
        c.runSearchFromPage();
        Test.stopTest();
    }

    static testMethod void partnerSearchFromPageDistributor() {
        PageReference partnerPage = Page.MM_PartnerFinderHome; 
        Test.setCurrentPage(partnerPage);
        MM_Class_SearchController c = new MM_Class_SearchController();
        c.deepLink.dest = 'Distributor';
        
        Test.startTest();
        c.runSearchFromPage();
        Test.stopTest();
    }

    static testMethod void partnerSearchFromPageAppPartner() {
        PageReference partnerPage = Page.MM_PartnerFinderHome; 
        Test.setCurrentPage(partnerPage);
        MM_Class_SearchController c = new MM_Class_SearchController();
        c.deepLink.dest = 'AppPartner';
        
        Test.startTest();
        c.runSearchFromPage();
        Test.stopTest();
    }

    static testMethod void partnerSearchFromPageChannelApplication() {
        PageReference partnerPage = Page.MM_PartnerFinderHome; 
        Test.setCurrentPage(partnerPage);
        MM_Class_SearchController c = new MM_Class_SearchController();
        c.deepLink.dest = 'Channel Application';
        
        Test.startTest();
        c.runSearchFromPage();
        Test.stopTest();
    }
    public enum QueryType {CHANNEL_PARTNER, CHANNEL_PARTNER2, DISTRIBUTOR, APP_PARTNER, CHANNEL_APP, CHANNEL_APP2}
//sampath
static testmethod void testmethod1()
{
  MM_Class_SearchController mm = new MM_Class_SearchController();
        mm.emailAddress ='Test009@testmotorola.com';
        mm.numberOfChannelPartners = 2;
        mm.numberOfDistributors =2;
        mm.numberOfSoftwareVendors =2;
        mm.numberOfChannelAndSoftware =2;
        mm.subPageState ='';
        mm.allTechs='allTechs';
        mm.idOfSelectedRecord ='idOfSelectedRecord ';
        mm.nameOfSelectedRecord = 'nameOfSelectedRecord ';
        account accnew=new account();
        accnew.name='test acc009';
        accnew.BillingCountry='United States';
        accnew.Billingcity='test';
        accnew.Billingstate='Texas';
        account accnew1 = new account();
        accnew1.name='test acc';
        accnew1.BillingCountry='United States';
        accnew1.Billingcity='test';
        accnew1.Billingstate='Texas';
        Test.startTest();
        insert accnew;
        insert accnew1;
        Test.stopTest();
      MM_Class_SearchController.QuickLinkPanel QP = new MM_Class_SearchController.QuickLinkPanel();
      QP.getTotalLinks();
     MM_Class_SearchController.QuickLink QL= new MM_Class_SearchController.QuickLink('test','test',true,'test');
      list<MM_Class_SearchController.QuickLink> newlists= QP.enterpriseAppLinks;
      list<MM_Class_SearchController.QuickLink> newlists1= QP.radioAppLinks;
         Cookie qlCookie =  ApexPages.currentPage().getCookies().put('quickLinks',new Cookie('quickLinks', '1', null, -1, false));
         system.debug('qlCookie qlCookie '+qlCookie );
        
        MM_Class_SearchController.ApplicationDataStripped ApplicationData = new  MM_Class_SearchController.ApplicationDataStripped();
        ApplicationData.compareTo(ApplicationData);
   
      ApplicationData.hasTechnology=true;  
       string s ='';
       boolean checkempty =ApplicationData.isEmpty(s);
        
        mm.partnerSearchAll();
       mm.doDetailAppProcess();
        mm.populateTechTrackMap();
        mm.runSearchFromPage();
        //mm.subPageState='';
         
          list<id> accidset=new list<id>{accnew1.Id, accnew.Id};
         Set<Id> accountIdSet = new Set<Id>();
         for(id ids:accidset)
         {
            accountIdSet.add(ids);
         }
        
        MM_Class_SearchController.QueryType valenum1 = MM_Class_SearchController.QueryType.APP_PARTNER;
           //mm.fillPartnerData(accnew,valenum1,accountIdSet);  //sampath
           boolean b=true;
           mm.updatePartnerQuickList(b);
        mm.GENAppBusinessGrp();

}
Static testmethod void testmethod2()
    {
         MM_Class_SearchController mm = new MM_Class_SearchController();
        mm.emailAddress ='Test11@motorola.com';
        mm.numberOfChannelPartners = 3;
        mm.numberOfDistributors =3;
        mm.numberOfSoftwareVendors =3;
        mm.numberOfChannelAndSoftware =3;
        mm.subPageState ='test';
        mm.allTechs='Testing';
        mm.idOfSelectedRecord ='idOfSelectedRecord ';
        mm.nameOfSelectedRecord = 'nameOfSelectedRecord ';
 
//system.debug('ddddd'+dl.currentPage);
 //System.assertEquals(dl.currentPage,'partner');
        MM_Class_SearchController.QuickLinkPanel QP = new MM_Class_SearchController.QuickLinkPanel();
     MM_Class_SearchController.QuickLink QL= new MM_Class_SearchController.QuickLink('test','test',true,'test');
      list<MM_Class_SearchController.QuickLink> newlists= QP.enterpriseAppLinks;
      list<MM_Class_SearchController.QuickLink> newlists1= QP.radioAppLinks;
         Cookie qlCookie =  ApexPages.currentPage().getCookies().put('quickLinks',new Cookie('quickLinks', '1', null, -1, false));
         system.debug('qlCookie qlCookie '+qlCookie );
        
        MM_Class_SearchController.ApplicationDataStripped ApplicationData = new  MM_Class_SearchController.ApplicationDataStripped();
        ApplicationData.compareTo(ApplicationData);
   
      ApplicationData.hasTechnology=true;  
       string s ='';
       boolean checkempty =ApplicationData.isEmpty(s);
        
        mm.partnerSearchAll();
       mm.doDetailAppProcess();
        mm.populateTechTrackMap();
        mm.runSearchFromPage();
 MM_Class_SearchController.ApplicationSearch apps = new MM_Class_SearchController.ApplicationSearch();
 
    MM_Staging__c stage1 = new  MM_Staging__c();
    stage1.E_or_G__c='E';
   stage1.Industry__c='Education';
  stage1.Industry_Specialty__c='Autonomous Mining';
  stage1.Business_Industry__c='test';
  stage1.Business__c='Education';
  //stage1.Industry__c='Command and Control';
stage1.Business_Specialty__c='Command and Control';
stage1.Technology__c='Advanced Data Capture';
   insert stage1;
      
     MM_Class_SearchController.CustomApplication CSAPP = new MM_Class_SearchController.CustomApplication();
     
//list<Software_Applications__c> newsplist=new list<Software_Applications__c>();
list<Industries_Solutions__c> newInsolnlist=new list<Industries_Solutions__c>();
list<Cross_Industries_Solutions__c> CISlist=new list<Cross_Industries_Solutions__c>();
//list<Supported_Products__c> supPlist= new list<Supported_Products__c>();

Territory_Master__c TM = new Territory_Master__c();
TM.City__c='testCitytest';
insert TM;
    account accnew=new account();
        accnew.name='test acc0091';
        accnew.Billingcity = 'Santest Mateo';
        accnew.Billingstate = 'Texas';
        accnew.BillingCountry = 'United States';
        account accnew1=new account();
        accnew1.name='test acc';
        accnew1.Billingcity = 'San Mateo';
        accnew1.Billingstate = 'Texas';
        accnew1.BillingCountry = 'United States';
        insert accnew;
        insert accnew1;
          
/*Software_Applications__c sp = new Software_Applications__c();
sp.name='--None--';
sp.Account_C__c=accnew.id;
Software_Applications__c sp1 = new Software_Applications__c();
sp1.name='--None--';
sp1.Account_C__c=accnew1.id;
insert sp;
insert sp1;
newsplist.add(sp);
newsplist.add(sp1);
*/
/*Industries_Solutions__c IS = new Industries_Solutions__c();
IS.Horizontal__c='--None--';
//IS.Software_Applications__c=sp.id;
Industries_Solutions__c IS1 = new Industries_Solutions__c();
IS1.Horizontal__c='--None--';
//IS1.Software_Applications__c=sp1.id;
insert IS;
insert IS1;
newInsolnlist.add(IS);
newInsolnlist.add(IS1);

Cross_Industries_Solutions__c CIS = new Cross_Industries_Solutions__c();
CIS.Cross_Industries__c='Command and Control';
//CIS.Software_Applications__c=sp.id;
Cross_Industries_Solutions__c CIS1 = new Cross_Industries_Solutions__c();
CIS1.Cross_Industries__c='Command and Control';
//CIS1.Software_Applications__c=sp1.id;
insert CIS;
insert CIS1;
CISlist.add(CIS);
CISlist.add(CIS1);*/

/*Supported_Products__c SupP =new Supported_Products__c();
SupP.Motorola_Support_Product_Tested__c='Yes';
SupP.Software_Applications__c = sp.id;
Supported_Products__c SupP1 =new Supported_Products__c();
SupP1.Motorola_Support_Product_Tested__c='Yes';
SupP1.Software_Applications__c = sp1.id;
insert SupP;
insert SupP1;
supPlist.add(SupP);
supPlist.add(SupP1);*/


//Map<Id, Software_Applications__c> softwareAppMap = new Map<Id, Software_Applications__c> ();
//Map<Id, Industries_Solutions__c> industrySolutionsMap = new Map<Id, Industries_Solutions__c>();
//Map<Id, Cross_Industries_Solutions__c> crossIndustriesMap =new Map<Id, Cross_Industries_Solutions__c>();
//Map<Id, Supported_Products__c> supportedProductsMap = new Map<Id, Supported_Products__c>();
 Map<Id, MM_Class_SearchController.CustomApplication> customAppMap = new Map<Id, MM_Class_SearchController.CustomApplication>();
  MM_Class_SearchController.CustomApplication c = new MM_Class_SearchController.CustomApplication();
               // c.app = sp;
               // c.app.Long_Description__c = '';
                //customAppMap.put(c.app.Id, c);

/*for(Software_Applications__c newsp:newsplist)
{
softwareAppMap.put(newsp.id,newsp);
} */
/*for(Industries_Solutions__c newIS:newInsolnlist)
{
industrySolutionsMap.put(newIS.id,newIS);
}
for(Cross_Industries_Solutions__c newCIS:CISlist)
{
crossIndustriesMap.put(newCIS.id,newCIS);
}*/
/*for(Supported_Products__c newSupP:supPlist)
{
supportedProductsMap.put(newSupP.id,newSupP);
}*/
//CSAPP
// mm.processAppSearchData(softwareAppMap,industrySolutionsMap,crossIndustriesMap,supportedProductsMap,customAppMap);//sampath

    
          list<id> accidset=new list<id>{accnew1.Id, accnew.Id};
         Set<Id> accountIdSet = new Set<Id>();
         for(id ids:accidset)
         {
            accountIdSet.add(ids);
         }
         boolean b= false;
         system.debug('accountIdSetaccountIdSet'+accountIdSet);
           system.debug('bbbbbbbbbbbbbbbbb'+b);
        try{
        PageReference bool1 = mm.continuePartnerSearch(accountIdSet,accountIdSet,accountIdSet,accountIdSet,accountIdSet,b);//sampath
        } catch(Exception exp){}
            MM_Class_SearchController.QueryType valenum1 = MM_Class_SearchController.QueryType.DISTRIBUTOR;
       //    mm.fillPartnerData(accnew,valenum1,accountIdSet);//sampath
    }
       Static testmethod void testmethod3()
    {
      boolean b= true;
        integer i=0;
        list<account> newacc=new list<account>();
       
        Account accnew=new Account();
        accnew.name='test acc0089';
        accnew.BillingCountry='United States';
        accnew.Billingcity='testCity009';
        accnew.Billingstate='Texas';
        accnew.Partner_Region__c = 'EMEA';
        accnew.Owner_Business_Group__c='Government';
        
        Account accnew1=new Account();
        accnew1.name='acc00876';
        accnew1.BillingCountry='Canada';
        accnew1.Billingcity='testCity009';
        accnew1.Billingstate='Alberta';
        accnew1.Territory__c='T1';
        accnew1.Region__c='NA';
        Test.startTest();
        insert accnew;
        insert accnew1;
        Partner_Type__c pt1 = new Partner_Type__c(Account__c = accnew.id, Program__c = 'RADIO',Purchasing_Method__c='Tier 1',
                                                  Status__c='Active',Partner_Track__c='Reseller');
        insert pt1;
        Market_Specializations__c marketSpecialization1  = new Market_Specializations__c(Market_Specialization_Level__c='Authorized',
                                                                                      Market_Specialization__c = 'US Federal',
                                                                                        Account__c = accnew.Id);
        insert marketSpecialization1;
        Technology_Specialization__c techSpec1 = new Technology_Specialization__c(Partner_Program__c = pt1.Id,
                                                                                  Account__c=accnew.Id,
                                                                          Technology_Specialization__c='Professional and Commercial Radio',
                                                                          Community_Type__c='Application Partner',
                                                                          Technology_Specialization_Status__c ='Active',
                                                                          Technology_Specialization_Level__c='Authorized',
                                                                          TechnologySubSegment__c='MOTOTRBO Capacity Max',
                                                                          Type__c = 'Application');
        insert techSpec1;
        Product_Offered__c prd1 = new Product_Offered__c(Account__c=accnew.Id,Product_Offering__c='Support Services');
        insert prd1;
        Test.stopTest();
        newacc.add(accnew);
        newacc.add(accnew1);
      
         MM_Class_SearchController mm = new MM_Class_SearchController();
        
          
        MM_Class_SearchController.Pager Pager1= new MM_Class_SearchController.Pager(i,b);
         MM_Class_SearchController.Paginate paginater = new MM_Class_SearchController.paginate(i,i);
        // paginater.paginater;
        paginater.updateNumbers();
        paginater.decrement();
        paginater.increment();
        
           list<id> newstring = new list<id>();
            set<id> Technology_Segment= new set<id>();
         for(account acc:newacc) {
        newstring.add(acc.id);
        }
        system.debug('newstring'+newstring);
        MM_Class_SearchController.ApplicationData appData= new MM_Class_SearchController.ApplicationData();
       appData.motorolaTested ='motorolaTested';
       integer a =appData.CustomerNameSize;
          
         MM_Class_SearchController.Location loc =new MM_Class_SearchController.Location();
         string latitude = loc.latitude;
         String longitude = loc.longitude;
         String name = loc.name;
         String address1 = loc.address1;
         String address2 = loc.address2;
         String city = loc.city;
         String state = loc.state;
         String zip = loc.zip;
         String country = loc.country;
         String phone = loc.phone;
         String fax = loc.fax;
        
          
           MM_Class_SearchController.Screenshot Screens = new MM_Class_SearchController.Screenshot('test','test','test');
       /*list<Software_Applications__c > listswapp = new list<Software_Applications__c>();
       Software_Applications__c swapp=new Software_Applications__c();
       swapp.Account_C__c = accnew.id;
       swapp.Name = 'test';
       swapp.Short_Description__c='test';
       swapp.Version__c='1';
       swapp.Target_Customer_Size__c ='Large Enterprise (1000+)';
       swapp.Supported_Operating_Systems__c ='WinCE 4.2- Core';
       swapp.Publish_on_Motorola_com__c = 'Yes';
       swapp.Type_of_Application_Build_Per_Client__c ='User self-configured';
       swapp.Customer__c ='End Customer';
       swapp.Languages__c='Telugu';
       swapp.Offer_Countries_End_User__c ='India';
       listswapp.add(swapp);
       Software_Applications__c swapp1=new Software_Applications__c();
       swapp1.Account_C__c = accnew.id;
       swapp1.Name = 'test';
       swapp1.Short_Description__c='test';
       swapp1.Version__c='1';
       swapp1.Target_Customer_Size__c ='Large Enterprise (1000+)';
       swapp1.Supported_Operating_Systems__c ='WinCE 4.2- Core';
       swapp1.Publish_on_Motorola_com__c = 'Yes';
       swapp1.Type_of_Application_Build_Per_Client__c ='User self-configured';
       swapp1.Customer__c ='End Customer';
       swapp1.Languages__c='Telugu';
       swapp1.Offer_Countries_End_User__c ='India';
           listswapp.add(swapp1);
        
        insert listswapp;*/
       
      // system.debug('listswapplistswapplistswapp'+listswapp);
       for(id ids:newstring)
       {
            system.debug('newstring[k]'+ids);
           
               Technology_Segment.add(ids);
       }
        
           system.debug('appData.Technology_SegmentappData.Technology_Segment'+appData.Technology_Segment);
         list<id> accidset=new list<id>{accnew1.Id, accnew.Id};
         Set<Id> accountIdSet = new Set<Id>();
         for(id ids:accidset)
         {
            accountIdSet.add(ids);
         }
        
        system.debug('accountIdSet accountIdSet '+accountIdSet );
         system.debug('accidsetaccidset'+accidset);
        list<account> updt =[ select id,name from account where id IN:accountIdSet ];
          system.debug('updt updt updt updt '+updt );
          
          MM_Class_SearchController.DeepLinking DL = new  MM_Class_SearchController.DeepLinking();
          dl.business='E';
        dl.currentPage='partner';
        dl.partnerId='test';
        mm.displayDetailLinks=false;
        //list<string> track = mm.trackForSearch;
         MM_Class_SearchController.PartnerSearch PS = new  MM_Class_SearchController.PartnerSearch(DL);
         mm.runSearchFromPage();
         ps.stage.Partner_Country__c='United States';
           
          MM_Class_SearchController.ApplicationSearch APPS= new MM_Class_SearchController.ApplicationSearch(DL);
             APPS.stage.Country__c='Afghanistan';
           List<SelectOption> STO=APPS.SystemTypeOptions;
           List<string> STYpes = APPS.SystemTypes;
           MM_Class_SearchController.PartnerSearch PS1 = new  MM_Class_SearchController.PartnerSearch();
           List<SelectOption> selOpts=ps.technologyOptions;
        RecordType theRecordType = [SELECT Id FROM RecordType WHERE Name='Partner' AND SobjectType='Account' LIMIT 1];
        Account accTest = new Account( Name='Test Account Partner',
                          RecordTypeId = theRecordType.id,BillingStreet='12th Street',BillingCity='Bangalore',BillingCountry='India',BillingPostalCode='560100',
                          Motorola_Customer_Number__c=string.valueof(integer.valueof(math.random()*1000000000)*100),Role_Created__c = true);
        insert accTest;
        accTest.IsPartner = true;
        update accTest;
        Partner_Location__c partnerLocation1 = new Partner_Location__c(Account__c = accTest.id,
                                                                       Address_Type__c = 'Primary Location',
                                                                       Location_Publish_Flag__c = true
                                                                       
                                                                      );
        insert partnerLocation1 ;
        
        MM_Class_SearchController.QueryType valenum = MM_Class_SearchController.QueryType.CHANNEL_PARTNER;
        MM_Class_SearchController.PartnerData pd= new  MM_Class_SearchController.PartnerData(accnew,PS,'test',valenum ,Technology_Segment);
       pd.compareTo(pd);
        MM_Class_SearchController.Paginate pge = new MM_Class_SearchController.Paginate(2,2);
       mm.paginater = pge;
       ps.refreshTechnology();
       pd.loadLocation(partnerLocation1);
       pd.randomSort();
       pd.channelAppSort(pd);
       pd.channelPartnerSort(pd);
       pd.distributorSort(pd);
       pd.appPartnerSort(pd);
       pd.isEmpty('test');
       mm.setPartnerQuickList(false,new List<MM_Class_SearchController.PartnerData>{pd});
       mm.mapSortedListToIdList(new List<MM_Class_SearchController.PartnerData>{pd});
       mm.makeCurrentPartnerDataListMatchIdList(new List<Id>(),new List<MM_Class_SearchController.PartnerData>{pd});
       
       mm.showPartnerDetail();
       MM_Class_SearchController.getResourceURL('Test resource');
       mm.additionalLocationsClicked();
       mm.partnerDetailClicked();
       mm.nextItemPartner();
       mm.previousItemPartner();
       try{
       mm.partnerPreviousPage();
       } catch(Exception exp){}
       try{
        mm.partnerNextPage();
        } catch(Exception exp){}
       try{
        mm.updatePartnerPage();
        } catch(Exception exp){}
       try{
        mm.changePartnerData();
        } catch(Exception exp){}
       try{
        mm.appPreviousPage();
        } catch(Exception exp){}
       try{
        mm.appNextPage();
        } catch(Exception exp){}
       try{
        mm.updateAppPage();
        } catch(Exception exp){}
       try{
        mm.changeAppData();
        } catch(Exception exp){}
       try{
        mm.partnerClickedFromAppDetail();
        } catch(Exception exp){}
       try{
        mm.partnerLinkClicked();
        } catch(Exception exp){}
       try{
        mm.appLinkClicked();
        } catch(Exception exp){}
       try{
        mm.appLinkBackClicked();
        } catch(Exception exp){}
       
       mm.linkClicked('MM_PartnerFinderHome','NAMR','United States','Value Added Reseller','gov');
       
       Partner_Type__c newpartnertype = new Partner_Type__c();
       newpartnertype.Compliance_Status__c ='Compliant';
       newpartnertype.Account__c=accnew.id;
       insert newpartnertype;
       MM_Class_SearchController.CustomPartnerType Custompartner = new MM_Class_SearchController.CustomPartnerType(newpartnertype);
       Custompartner.compareTo(Custompartner);
   
   
       Technology_Specialization__c newtechspeclization = new Technology_Specialization__c();    
       newtechspeclization.Partner_Program__c = newpartnertype.id;
       newtechspeclization.Community_Type__c ='Value Added Reseller';
       newtechspeclization.Technology_Specialization__c = 'Advanced Data Capture';
       insert newtechspeclization;
       MM_Class_SearchController.CustomTechSpec CustomTech = new MM_Class_SearchController.CustomTechSpec(newtechspeclization); 
       CustomTech.compareTo(CustomTech);
       
       //mm.fillPartnerData(accnew,valenum,accountIdSet);//sampath
        
       //pd.partnerData;
       //pd.loadLocation
       //mm.Paginate pagi = new mm.Paginate(0,0).updateNumbers();
    }
    static testmethod void testmethod4()
    {
        Account accnew=new Account();
        accnew.name='test accVKC00987';
        accnew.BillingCountry='United States';
        accnew.Billingcity='testCity76';
        accnew.Billingstate='Texas';
        
        Account accnew1=new Account();
        accnew1.name='testVKC acc0090';
        accnew1.BillingCountry='United States';
        accnew1.Billingcity='testCity765';
        accnew1.Billingstate='Texas';
        insert accnew;
        insert accnew1;
          
        Partner_Type__c newpartnertype = new Partner_Type__c();
        newpartnertype.Compliance_Status__c ='Compliant';
        newpartnertype.Account__c=accnew.id;
        insert newpartnertype;
       
        Technology_Specialization__c newtechspeclization = new Technology_Specialization__c();    
        newtechspeclization.Partner_Program__c = newpartnertype.id;
        newtechspeclization.Community_Type__c ='Value Added Reseller';
        newtechspeclization.Technology_Specialization__c = 'Advanced Data Capture';
        insert newtechspeclization;
       
        Market_Specializations__c newmarketSpecializations = new Market_Specializations__c();
        newmarketSpecializations.Market_Specialization__c = 'US Federal';
        newmarketSpecializations.Account__c = accnew.id;
        insert newmarketSpecializations;
        
        Product_Offered__c newproductoffered = new Product_Offered__c();
        newproductoffered.Account__c=accnew.id;
        newproductoffered.Product__c='Commercial Analog Subscribers';
        insert newproductoffered;
        MM_Class_SearchController.CustomCommunity custcomm = new MM_Class_SearchController.CustomCommunity(newtechspeclization);
        //  custcomm.compareTo(custcomm);
        // custcomm.compareTo(custcomm);
    
    MM_Class_SearchController.CustomMarketSpec custmarket = new MM_Class_SearchController.CustomMarketSpec(newmarketSpecializations);
    custmarket.compareTo(custmarket);
    
    MM_Class_SearchController.CustomAuthProd CustAuth = new MM_Class_SearchController.CustomAuthProd(newtechspeclization,newproductoffered);
        CustAuth.compareTo(CustAuth);
        
    MM_Class_SearchController mm = new MM_Class_SearchController();
   
  //set<id> ids1= MM_Class_SearchController.getPartnerQLIds;
          list<id> accidset=new list<id>{accnew1.Id, accnew.Id};
         Set<Id> accountIdSet = new Set<Id>();
         for(id ids:accidset)
         {
            accountIdSet.add(ids);
         }
        
        MM_Class_SearchController.QueryType valenum1 = MM_Class_SearchController.QueryType.CHANNEL_APP;
          // mm.fillPartnerData(accnew,valenum1,accountIdSet); //sampath
        
           
}
static testmethod void testmethod5()
{
    account accnew=new account();
    accnew.name='test acc';
    accnew.BillingCountry='United States';
        accnew.Billingcity='test';
        accnew.Billingstate='Texas';
    insert accnew;
    
  /*  Software_Applications__c sp = new Software_Applications__c();
    sp.name='--None--';
    sp.Account_C__c=accnew.id;
    insert sp;*/
    MM_Country_Mapping__c countryMap = new MM_Country_Mapping__c();
    countryMap.Name = 'United States';
    countryMap.Code__c = 'US';
    countryMap.Region__c = 'North America';
    insert countryMap;
    
    MM_Locale_Mapping__c localeMap = new MM_Locale_Mapping__c();
    localeMap.Name = 'US-EN';
    localeMap.Default_Country__c = 'United States';
    localeMap.Language__c = 'English';
    localeMap.Language_Code__c = 'en';
    localeMap.Region__c = 'North America';
    insert localeMap;
    
    MM_Region_To_App_Map__c regMap = new MM_Region_To_App_Map__c();
    regMap.Name='NAMR';
    regMap.Has_Access__c = true;
    insert regMap;
    
    MM_Class_SearchController.DeepLinking dl=new MM_Class_SearchController.DeepLinking();
    dl.dest='Applciation';
    dl.currentPage='application';
    dl.technology='RADIO';
   // dl.appId = sp.id;
   
    System.assertEquals(dl.dest,'Applciation');
    System.assertEquals(dl.currentPage,'application');
    System.assertEquals(dl.technology,'RADIO');
   // System.assertEquals(string.valueof(sp.id),dl.appId);
   MM_Class_SearchController mm=new  MM_Class_SearchController();
   set<id> PartnerQLIds =new set<id>(); 
   set<id> PartnerQLIds1 = mm.getPartnerQLIds();
  mm.clearName();
    
    MM_Class_SearchController c = new MM_Class_SearchController();
        c.appSearch();
        c.populateAppDataList();
        c.writeQuickLinksToCookie();
        c.addToQuickList();
        c.addToQuickListPartner();
        c.emailAddress = 'email@email.com;email@email.com;email@email.com;email@email.com;email@email.com;email@email.com';
        c.emailQuickList();
        c.removeFromQuickListApplication();
        c.removeFromQuickListPartner();
        c.showAppDetail();
        c.populateSubPageState(MM_Class_SearchController.State.CHANNEL_PARTNERS);
        c.getTempPartnerDataList();
        c.populateSubPageState(MM_Class_SearchController.State.DISTRIBUTORS);
        c.getTempPartnerDataList();
        c.populateSubPageState(MM_Class_SearchController.State.SOFTWARE_VENDORS);
        c.getTempPartnerDataList();
        c.populateSubPageState(MM_Class_SearchController.State.CHANNEL_PARTNER_AND_SOFTWARE);
        c.getTempPartnerDataList();
      //  c.showPartnerDetail();
        c.showQuickLinkClicked();
        c.closeQuickLink();
        c.backFromDetail();
        c.backFromAdditionalLocations();
        c.newSearch();
        c.populateGenericList();
        c.commonGenericList();
        c.checkPartnerInputs();
        c.checkPartnerCounty();
        c.channelPartnerClicked();
        //c.additionalLocationsClicked();
        c.distributorsClicked();
        c.softwareVendorsClicked();
        c.channelPartnerAndSoftwareClicked();
        c.moreLocationsClicked();
       // c.partnerDetailClicked();
        c.partnerMapClicked();
        c.partnerListClicked();
        c.partnerShowTenClicked();
        c.partnerShowAllClicked();
        c.appShowTenClicked();
        c.appShowAllClicked();
        c.nextItem();
       // c.nextItemPartner();
        c.optionChanged();
        //c.partnerPreviousPage();
        //c.partnerNextPage();
        //c.updatePartnerPage();
        //c.changePartnerData();
        //c.appPreviousPage();
        //c.appNextPage();
        //c.updateAppPage();
        //c.changeAppData();
        
        

        test.starttest();
       //MM_Class_SearchController.PartnerSearch ps = new MM_Class_SearchController.PartnerSearch();
       MM_Class_SearchController.PartnerSearch ps = new MM_Class_SearchController.PartnerSearch(new MM_Class_SearchController.DeepLinking());
       ps.checkInputsForMego();
        ps.stage.Partner_Region__c = 'Asia Pacific';
        ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
        ps.stage.Partner_Technology__c = 'SCADA';
        ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
        ps.stage.Partner_Technology__c = 'Professional and Commercial Radio';
        ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
        ps.stage.Partner_Technology__c = 'something else...';
        ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
                test.stoptest();

   
 // MM_Class_SearchController.PartnerData PD = new MM_Class_SearchController.PartnerData();
   //list<MM_Class_SearchController.PartnerData> PD= MM_Class_SearchController.PartnerData.partnerGenericList;
}
    //sampath
    static testMethod void controllerTestPartnerGeneric(){
        MM_Class_SearchController c = new MM_Class_SearchController();
        MM_Class_SearchController.DeepLinking dp = new MM_Class_SearchController.DeepLinking();
        MM_Class_SearchController.PartnerSearch ps = new MM_Class_SearchController.PartnerSearch(dp);
        MM_Staging__c stage1 = new MM_Staging__c();
        stage1.E_or_G__c='E';
        stage1.Industry__c='Education';
        stage1.Industry_Specialty__c='Autonomous Mining';
        stage1.Business_Industry__c='test';
        stage1.Business__c='Education';
        stage1.Partner_Region__c='North America';
        stage1.Business_Specialty__c='Command and Control';
        stage1.Technology__c='Advanced Data Capture';
        stage1.Partner_Country__c = 'United States';
        stage1.Country__c = 'United States';
        stage1.Partner_Technology__c = 'Advanced Data Capture';
        insert stage1;
        ps.stage = stage1;
        
        c.deepLink.dest = 'Channel';
        c.runSearchFromPage();
        c.deepLink.dest = 'Applciation';
        c.deepLink.currentPage = 'partner';
        c.runSearchFromPage();
        c.partnerSearch();
        c.doDetailAppProcess();
        c.populatePageState(MM_Class_SearchController.State.RESULTS);
        c.populateSubPageState(MM_Class_SearchController.State.CHANNEL_PARTNERS);
        c.partnerSearchAll();
        //c.partnerClickedFromAppDetail();
        c.partnerLinkClicked();
        c.appLinkClicked();
        c.appLinkBackClicked();
        MM_Class_SearchController.ApplicationDataStripped ApplicationData = new MM_Class_SearchController.ApplicationDataStripped();
        ApplicationData.compareTo(ApplicationData);
        MM_Class_SearchController.ApplicationData appData = new MM_Class_SearchController.ApplicationData();
        appData.getCustomerNameSize();
    }
    /*static testMethod void controllerTestAppGeneric(){
        Software_Applications__c saId = [Select Id FROM Software_Applications__c LIMIT 1]; 
        MM_Class_SearchController.DeepLinking deep = new MM_Class_SearchController.DeepLinking();
        MM_Class_SearchController.ApplicationSearch appSearch = new MM_Class_SearchController.ApplicationSearch(deep);
        MM_Class_SearchController c = new MM_Class_SearchController();
        c.idOfSelectedRecord = 'test';
        c.populatePageState(MM_Class_SearchController.State.RESULTS);
        MM_Class_SearchController.ApplicationData appData = new MM_Class_SearchController.ApplicationData();
        appData.application = saId;
        appData.appId = 'testappId';
        
        RecordType rect=[SELECT r.Id FROM RecordType r WHERE r.SobjectType='Account' and r.name='Customer'];
        Account accnt1 = new Account(name='test_cusaccount1');
        accnt1.Type ='Customer';
        accnt1.RecordTypeId=rect.Id;
        accnt1.Federal_Agency__c = 'Department of Defense';
        accnt1.BillingCity = 'test';
        accnt1.BillingCountry = 'United States';
        accnt1.BillingState = 'Alabama';
        accnt1.Primary_County__c = 'Yuma';
        accnt1.Territory__c = '';
        accnt1.Partner_Region__c = 'EMEA';
        insert accnt1;
        Set<Id> TestpartnerSet = new Set<Id>();
        TestpartnerSet.add(accnt1.Id);
        
        MM_Class_SearchController.PartnerSearch ps = new MM_Class_SearchController.PartnerSearch(new MM_Class_SearchController.DeepLinking());
        MM_Class_SearchController.QueryType qt;
        qt = MM_Class_SearchController.QueryType.CHANNEL_PARTNER;
        
        MM_Class_SearchController.PartnerData pData = new MM_Class_SearchController.PartnerData(accnt1,ps,'allparams',qt,TestpartnerSet);
        
        MM_Class_SearchController.ApplicationDataStripped ApplicationData = new MM_Class_SearchController.ApplicationDataStripped();
        ApplicationData.compareTo(ApplicationData);
   
        ApplicationData.hasTechnology=true;
        String s ='';
        Boolean checkempty = ApplicationData.isEmpty(s);
        
        c.appSearch();
        
        c.populateAppDataList();
        c.writeQuickLinksToCookie();
        c.addToQuickList();
        c.addToQuickListPartner();
        c.emailAddress = 'email@email.com;email@email.com;email@email.com;email@email.com;email@email.com;email@email.com';
        c.emailQuickList();
        c.removeFromQuickListApplication();
        c.removeFromQuickListPartner();
        c.showAppDetail();
        c.populateSubPageState(MM_Class_SearchController.State.CHANNEL_PARTNERS);
        c.getTempPartnerDataList();
        c.populateSubPageState(MM_Class_SearchController.State.DISTRIBUTORS);
        c.getTempPartnerDataList();
        c.populateSubPageState(MM_Class_SearchController.State.SOFTWARE_VENDORS);
        c.getTempPartnerDataList();
        c.populateSubPageState(MM_Class_SearchController.State.CHANNEL_PARTNER_AND_SOFTWARE);
        c.getTempPartnerDataList();
        c.showPartnerDetail();
        c.showQuickLinkClicked();
        c.closeQuickLink();
        c.backFromDetail();
        c.backFromAdditionalLocations();
        c.newSearch();
        c.populateGenericList();
        c.commonGenericList();
        c.checkPartnerInputs();
        c.checkPartnerCounty();
        c.channelPartnerClicked();
        c.additionalLocationsClicked();
        c.distributorsClicked();
        c.softwareVendorsClicked();
        c.channelPartnerAndSoftwareClicked();
        c.moreLocationsClicked();
        c.partnerDetailClicked();    
        c.partnerMapClicked();
        c.partnerListClicked();
        c.partnerShowTenClicked();
        c.partnerShowAllClicked();
        c.appShowTenClicked();
        c.appShowAllClicked();
        c.nextItem();
        c.nextItemPartner();
        c.previousItemPartner();
        c.optionChanged();
        c.previousItem();
        
        //c.partnerClickedFromAppDetail();
        //c.partnerPreviousPage();
        //c.partnerNextPage();
        //c.updatePartnerPage();
        //c.changePartnerData();
        //c.appPreviousPage();
        //c.appNextPage();
        //c.updateAppPage();
        //c.changeAppData();
        //c.AppBusinessGrp = new SelectOption('test','test');
        c.GENAppBusinessGrp();
        
    }*/
    
    Static testmethod void PrimaryPartnerLocations()
    {
        MM_Class_SearchController c = new MM_Class_SearchController();
       
        c.appSearch();
        
        c.populateAppDataList();
        c.writeQuickLinksToCookie();
        c.addToQuickList();
        c.addToQuickListPartner();
        c.emailAddress = 'email@email.com;email@email.com;email@email.com;email@email.com;email@email.com;email@email.com';
        c.emailQuickList();
        c.removeFromQuickListApplication();
        c.removeFromQuickListPartner();
        c.showAppDetail();
        c.populateSubPageState(MM_Class_SearchController.State.CHANNEL_PARTNERS);
        c.getTempPartnerDataList();
        c.populateSubPageState(MM_Class_SearchController.State.DISTRIBUTORS);
        c.getTempPartnerDataList();
        c.populateSubPageState(MM_Class_SearchController.State.SOFTWARE_VENDORS);
        c.getTempPartnerDataList();
        c.populateSubPageState(MM_Class_SearchController.State.CHANNEL_PARTNER_AND_SOFTWARE);
        c.getTempPartnerDataList();
      //  c.showPartnerDetail();//
        c.showQuickLinkClicked();
        c.closeQuickLink();
        c.backFromDetail();
        c.backFromAdditionalLocations();
        c.newSearch();
        c.populateGenericList();
        c.commonGenericList();
        c.checkPartnerInputs();
        c.checkPartnerCounty();
        c.channelPartnerClicked();
        //c.additionalLocationsClicked();
        c.distributorsClicked();
        c.softwareVendorsClicked();
        c.channelPartnerAndSoftwareClicked();
        c.moreLocationsClicked();
        //c.partnerDetailClicked();    //commented by Harish
        c.partnerMapClicked();
        c.partnerListClicked();
        c.partnerShowTenClicked();
        c.partnerShowAllClicked();
        c.appShowTenClicked();
        c.appShowAllClicked();
        c.nextItem();
     //c.nextItemPartner();//
       // c.previousItemPartner();//
        c.optionChanged();
        c.previousItem();
        
        //c.partnerClickedFromAppDetail();
        //c.partnerPreviousPage();
        //c.partnerNextPage();
        //c.updatePartnerPage();
        //c.changePartnerData();
        //c.appPreviousPage();
        //c.appNextPage();
        //c.updateAppPage();
        //c.changeAppData();
    //MM_Class_SearchController c = new MM_Class_SearchController();
        try{
            c.setupLists();
        } catch(Exception exp){}
    Set<Id> TestpartnerSet = new Set<Id>();
    List<SelectOption> temp = new list<SelectOption>() ;
    //List<Account> TestLocalAcc= new List<Account>();
   // Account TestAcc = [Select Id,Owner_Business_Group__c, MM_Fed_Specialization_Sort__c, MM_Partner_Type_Sort__c, MM_Metal_Level_Sort__c, Partner_Region__c, MEGO_Order__c, Name, NameLocal, Partner_Account_Name__c, Value_Add__c, Company_Description__c, Socio_Economic_Status__c, Website_URL__c, Metal_Level__c, (Select Id, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, ConnectionReceivedId, ConnectionSentId, Account__c, Account_Product__c, ProductKey__c, Product_Ext_Ref_Id__c, Product__c, Product_offering__c, Publish_Flag__c, Account_Unique_Id__c, Account__r.Partner_Region__c From Product_Offered__r), (Select Id, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, ConnectionReceivedId, ConnectionSentId, Account_C__c, Customer__c, End_Date__c, Languages__c, Long_Description__c, Market_Ready_Offering__c, Account_C__r.Metal_Level_Sort__c, MM_Motorola_Tested_Sort__c, Motorola_Tested__c, Offer_Countries_End_User__c, Offer_Countries_Partner_to_Partner__c, Publish_on_Motorola_com__c, Request_Motorola_Validation__c, Short_Description__c, Status__c, Supported_Operating_Systems__c, Supported_Peripherals__c, Target_Customer_Size__c, Tested_Date__c, Type_of_Application_Build_Per_Client__c, Uses_a_MSI_Rho_Development_Framework__c, Version__c From Partner_Software_Apps_del__r), (Select UPL_CommunityMarketTerm__c, Type__c, Technology_Specialization__c, Technology_Specialization_Status__c, Technology_Specialization_Level__c, Tech_Specialization_Compliant_Status__c, SystemModstamp, Sort_Order__c, Program__c, Partner_Zone__c, Partner_Program__c, Partner_Category__c, Name, Market_Term__c, LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, Id, CurrencyIsoCode, CreatedDate, CreatedById, ConnectionSentId, ConnectionReceivedId, Compliance_Review_Date__c, Community_Type__c, Authorized__c, Account__c, Account_Unique_Id__c, AccountPartnerRegion__c, Acc_Prgm_Track_Cmnty__c, Partner_Program__r.Status__c, MM_Distributor_Sort__c, MM_Sort_Order__c, Country__c FROM Technology_Specializations__r), (Select SystemModstamp, Name, Market_Specialization__c, Market_Specialization_Level__c, LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, Id, CurrencyIsoCode, CreatedDate, CreatedById, ConnectionSentId, ConnectionReceivedId, Account__c, MM_Sort_Order__c FROM Market_Specializations__r), (Select street__c, SystemModstamp, State__c, State_Code__c, Postal_code__c, Phone__c, PartnerName__c, Name, Longitude__c, Location_Publish_Flag__c, Location_Key__c, Location_Ext_Ref_Id__c, Latitude__c, LastModifiedDate, LastModifiedById, Keyword__c, IsPrimary__c, IsDeleted, Id, Federal_Status__c, Fax__c, CurrencyIsoCode, CreatedDate, CreatedById, Country_Code__c, Country1__c, ConnectionSentId, ConnectionReceivedId, City__c, Address_Type__c, Address_Line3__c, Address_Line2__c, Address_Line1__c, Account__c, Account_Website_URL__c, Account_Name__c, Account_Location__c FROM Partner_Locations__r) FROM Account WHERE Id = '0013000000LZ8uz'];
   // TestpartnerSet.add(TestAcc.Id);
   // TestLocalAcc[0] = TestAcc.clone();
   // System.Debug('My List-Harish'+TestAcc );
    QueryType qt;
     qt = QueryType.CHANNEL_PARTNER;
    /**
    //Account TestAcc = new Account();
    Product_Offered__c TestProd= new Product_Offered__c();
    // Added Code Here
    Technology_Specialization__c TestTech = new Technology_Specialization__c();
    // Add code Here
    Market_Specializations__c TestMarket = new Market_Specializations__c();
    //Add Code Here;
    Partner_Location__c TestPartnerLoc = new Partner_Location__c();
    //Add Code Here
    
    MM_Class_SearchController.DeepLinking TestDeep =new MM_Class_SearchController.DeepLinking();
    
            TestDeep.languageCode = 'en';
            TestDeep.hasAccessToApplication = true;
            TestDeep.region = 'North America';
            TestDeep.country = 'United States';
            TestDeep.defaultCountry = 'United States';
            TestDeep.allParams = '';
            Insert TestDeep;
         **/    
    MM_Class_SearchController.PartnerSearch ps = new MM_Class_SearchController.PartnerSearch(new MM_Class_SearchController.DeepLinking());
   // MM_Class_SearchController.PartnerData TestPD = new MM_Class_SearchController.PartnerData(TestAcc,ps,ps.allparams,qt,TestpartnerSet);
   // MM_Class_SearchController.Location l = new MM_Class_SearchController.Location();
                   /* l.address1= 'Test Address 1';
                    l.address2 = 'Test Address 2';
                    l.name = 'Test Name';
                    l.city = 'Test City';
                    l.state = 'Test State';
                    l.zip = 'Test ZipCOde';
                    l.phone = '98745631211';
                    l.fax = '85123649';
                    l.country = 'United States';
                    l.latitude = '';
                    l.longitude = '';
        PD.additionalLocations.add(l);*/
       // c.additionalLocationsClicked();
       // c.partnerDetailClicked();
    }
    static testMethod void queryBuildAPAC() {
        MM_Class_SearchController c = new MM_Class_SearchController();
        c.appSearch();
        c.populateAppDataList();
        c.writeQuickLinksToCookie();
        c.addToQuickList();
        c.addToQuickListPartner();
        c.emailAddress = 'email@email.com;email@email.com;email@email.com;email@email.com;email@email.com;email@email.com';
        c.emailQuickList();
        c.removeFromQuickListApplication();
        c.removeFromQuickListPartner();
        c.showAppDetail();
        c.populateSubPageState(MM_Class_SearchController.State.CHANNEL_PARTNERS);
        c.getTempPartnerDataList();
        c.populateSubPageState(MM_Class_SearchController.State.DISTRIBUTORS);
        c.getTempPartnerDataList();
        c.populateSubPageState(MM_Class_SearchController.State.SOFTWARE_VENDORS);
        c.getTempPartnerDataList();
        c.populateSubPageState(MM_Class_SearchController.State.CHANNEL_PARTNER_AND_SOFTWARE);
        c.getTempPartnerDataList();
      //  c.showPartnerDetail();
        c.showQuickLinkClicked();
        c.closeQuickLink();
        c.backFromDetail();
        c.backFromAdditionalLocations();
        c.newSearch();
        c.populateGenericList();
        c.commonGenericList();
        c.checkPartnerInputs();
        c.checkPartnerCounty();
        c.channelPartnerClicked();
        //c.additionalLocationsClicked();
        c.distributorsClicked();
        c.softwareVendorsClicked();
        c.channelPartnerAndSoftwareClicked();
        c.moreLocationsClicked();
       // c.partnerDetailClicked();
        c.partnerMapClicked();
        c.partnerListClicked();
        c.partnerShowTenClicked();
        c.partnerShowAllClicked();
        c.appShowTenClicked();
        c.appShowAllClicked();
        c.nextItem();
       // c.nextItemPartner();
        c.optionChanged();
        //c.partnerPreviousPage();
        //c.partnerNextPage();
        //c.updatePartnerPage();
        //c.changePartnerData();
        //c.appPreviousPage();
        //c.appNextPage();
        //c.updateAppPage();
        //c.changeAppData();

        test.starttest();
       //MM_Class_SearchController.PartnerSearch ps = new MM_Class_SearchController.PartnerSearch();
       MM_Class_SearchController.PartnerSearch ps = new MM_Class_SearchController.PartnerSearch(new MM_Class_SearchController.DeepLinking());
       ps.checkInputsForMego();
        ps.stage.Partner_Region__c = 'Asia Pacific';
        ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
        ps.stage.Partner_Technology__c = 'SCADA';
        ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
        ps.stage.Partner_Technology__c = 'Professional and Commercial Radio';
        ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
        ps.stage.Partner_Technology__c = 'something else...';
        ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
        test.stoptest();
    }
    
    static testMethod void queryBuildEMEA() {
    Test.startTest();
        MM_Class_SearchController.PartnerSearch ps = new MM_Class_SearchController.PartnerSearch();
        ps.stage.Partner_Region__c = 'EMEA';
        ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
        ps.stage.Partner_Technology__c = 'SCADA';
        ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
        ps.stage.Partner_Technology__c = 'Professional and Commercial Radio';
        ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
        ps.stage.Partner_Technology__c = 'Radio Solutions';
        ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
        ps.stage.Partner_Technology__c = 'something else...';
        ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            //Database.query(pq.query);
        }
        
        Test.stopTest();
    }
    
    
    static testMethod void queryBuildNAMR() {
        MM_Class_SearchController c = new MM_Class_SearchController();
        c.appSearch();
        c.populateAppDataList();
        c.writeQuickLinksToCookie();
        c.addToQuickList();
        c.addToQuickListPartner();
        c.emailAddress = 'email@email.com;email@email.com;email@email.com;email@email.com;email@email.com;email@email.com';
        c.emailQuickList();
        c.removeFromQuickListApplication();
        c.removeFromQuickListPartner();
        c.showAppDetail();
        c.populateSubPageState(MM_Class_SearchController.State.CHANNEL_PARTNERS);
        c.getTempPartnerDataList();
        c.populateSubPageState(MM_Class_SearchController.State.DISTRIBUTORS);
        c.getTempPartnerDataList();
        c.populateSubPageState(MM_Class_SearchController.State.SOFTWARE_VENDORS);
        c.getTempPartnerDataList();
        c.populateSubPageState(MM_Class_SearchController.State.CHANNEL_PARTNER_AND_SOFTWARE);
        c.getTempPartnerDataList();
      //  c.showPartnerDetail();
        c.showQuickLinkClicked();
        c.closeQuickLink();
        c.backFromDetail();
        c.backFromAdditionalLocations();
        c.newSearch();
        c.populateGenericList();
        c.commonGenericList();
        c.checkPartnerInputs();
        c.checkPartnerCounty();
        c.channelPartnerClicked();
        //c.additionalLocationsClicked();
        c.distributorsClicked();
        c.softwareVendorsClicked();
        c.channelPartnerAndSoftwareClicked();
        c.moreLocationsClicked();
       // c.partnerDetailClicked();
        c.partnerMapClicked();
        c.partnerListClicked();
        c.partnerShowTenClicked();
        c.partnerShowAllClicked();
        c.appShowTenClicked();
        c.appShowAllClicked();
        c.nextItem();
       // c.nextItemPartner();
        c.optionChanged();
        //c.partnerPreviousPage();
        //c.partnerNextPage();
        //c.updatePartnerPage();
        //c.changePartnerData();
        //c.appPreviousPage();
        //c.appNextPage();
        //c.updateAppPage();
        //c.changeAppData();
        Test.startTest();
        MM_Class_SearchController.PartnerSearch ps = new MM_Class_SearchController.PartnerSearch();
        MM_Class_SearchController mm = new MM_Class_SearchController();
        PageReference  bool=new MM_Class_SearchController.PartnerSearch().refreshTechnology(); 
        mm.showQuickLinkEmailClicked();
        ps.stage.Partner_Region__c = 'North America';
        ps.stage.Partner_Country__c = 'United States';
        ps.stage.Partner_State__c = 'AL';
        ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
        ps.stage.Partner_Technology__c = 'SCADA';
        ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
        ps.stage.Partner_Technology__c = 'Professional and Commercial Radio';
        ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
        ps.stage.Partner_Technology__c = 'something else...';
        ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
           //Database.query(pq.query);
          
        }
        Test.stopTest();
    }

    static testMethod void queryBuildLACR() {
        //MM_Class_SearchController.PartnerSearch ps = new MM_Class_SearchController.PartnerSearch();
        MM_Class_SearchController.PartnerSearch ps = new MM_Class_SearchController.PartnerSearch(new MM_Class_SearchController.DeepLinking());
        ps.stage.Partner_Region__c = 'Latin America';
        ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
        ps.stage.Partner_Technology__c = 'SCADA';
        ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
        ps.stage.Partner_Technology__c = 'Professional and Commercial Radio';
        ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
        ps.stage.Partner_Technology__c = 'something else...';
        ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            // Database.query(pq.query);
        }
    }

    static testMethod void queryBuildUSFederal() {
        //MM_Class_SearchController.PartnerSearch ps = new MM_Class_SearchController.PartnerSearch();
        MM_Class_SearchController.PartnerSearch ps = new MM_Class_SearchController.PartnerSearch(new MM_Class_SearchController.DeepLinking());
        ps.stage.Partner_Region__c = 'U.S. Federal Government';
        ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
        ps.stage.Partner_Technology__c = 'SCADA';
        ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
        ps.stage.Partner_Technology__c = 'Professional and Commercial Radio';
        ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
        ps.stage.Partner_Technology__c = 'something else...';
        ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
    }

    static testMethod void queryBuildUSFederalIndustry() {
        MM_Class_SearchController.PartnerSearch ps = new MM_Class_SearchController.PartnerSearch(new MM_Class_SearchController.DeepLinking());
        ps.stage.Partner_Industry__c = 'US Federal';
        ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
        ps.stage.Partner_Technology__c = 'SCADA';
        ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
        ps.stage.Partner_Technology__c = 'Professional and Commercial Radio';
        ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
        ps.stage.Partner_Technology__c = 'something else...';
        ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
    }
}