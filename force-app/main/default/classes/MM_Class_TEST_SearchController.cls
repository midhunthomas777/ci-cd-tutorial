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
private class MM_Class_TEST_SearchController {

    static testMethod void controllerTestPartnerGeneric(){
        MM_Class_SearchController c = new MM_Class_SearchController();
        c.deepLink.dest = 'Channel';
        c.runSearchFromPage();
        c.deepLink.dest = 'Applciation';
        c.deepLink.currentPage = 'application';
        c.runSearchFromPage();
        
        c.doDetailAppProcess();
        c.populatePageState(MM_Class_SearchController.State.RESULTS);
        c.populateSubPageState(MM_Class_SearchController.State.CHANNEL_PARTNERS);
        c.partnerSearchAll();
        MM_Class_SearchController.PartnerSearch ps = new MM_Class_SearchController.PartnerSearch(new MM_Class_SearchController.DeepLinking());
        ps.stage.Partner_Region__c = 'North America';
        ps.stage.Partner_Country__c = 'United States';
        ps.stage.Partner_State__c = 'AL';
        ps.createQueries();

    }
    static testMethod void controllerTestAppGeneric(){
        MM_Class_SearchController c = new MM_Class_SearchController();
         c.deepLink.currentPage = 'partner';
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
        c.getPartnerQLIds();
        //c.partnerPreviousPage();
        //c.partnerNextPage();
        //c.updatePartnerPage();
        //c.changePartnerData();
        //c.appPreviousPage();
        //c.appNextPage();
        //c.updateAppPage();
        //c.changeAppData();
        
        
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
        c.partnerSearch.createQueries();
        //c.partnerPreviousPage();
        //c.partnerNextPage();
        //c.updatePartnerPage();
        //c.changePartnerData();
        //c.appPreviousPage();
        //c.appNextPage();
        //c.updateAppPage();
        //c.changeAppData();
        

        //MM_Class_SearchController.PartnerSearch ps = new MM_Class_SearchController.PartnerSearch();
        MM_Class_SearchController.PartnerSearch ps = new MM_Class_SearchController.PartnerSearch(new MM_Class_SearchController.DeepLinking());
        ps.stage.Partner_Region__c = 'Asia Pacific';
        ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
        ps.stage.Partner_Technology__c = 'SCADA';
       // ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
        ps.stage.Partner_Technology__c = 'Professional and Commercial Radio';
        //ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
        ps.stage.Partner_Technology__c = 'something else...';
        //ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
    }
    /*
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
            Database.query(pq.query);
        }
        
        Test.stopTest();
    }
    */
    static testMethod void queryBuildNAMR() {
        //MM_Class_SearchController.PartnerSearch ps = new MM_Class_SearchController.PartnerSearch();
        MM_Class_SearchController.PartnerSearch ps = new MM_Class_SearchController.PartnerSearch(new MM_Class_SearchController.DeepLinking());
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
            Database.query(pq.query);
        }
    }

    static testMethod void queryBuildLACR() {
        //MM_Class_SearchController.PartnerSearch ps = new MM_Class_SearchController.PartnerSearch();
        MM_Class_SearchController.PartnerSearch ps = new MM_Class_SearchController.PartnerSearch(new MM_Class_SearchController.DeepLinking());
        ps.stage.Partner_Region__c = 'Latin America';
        ps.stage.Partner_Industry__c = 'US Federal';
        ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
        ps.stage.Partner_Technology__c = 'SCADA';
        //ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
        ps.stage.Partner_Technology__c = 'Professional and Commercial Radio';
        //ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
        ps.stage.Partner_Technology__c = 'something else...';
        //ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            // Database.query(pq.query);
        }
    }

    static testMethod void queryBuildUSFederal() {
        MM_Class_SearchController.PartnerSearch ps = new MM_Class_SearchController.PartnerSearch();
        ps.stage.Partner_Region__c = 'U.S. Federal Government';
        //ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
        ps.stage.Partner_Technology__c = 'SCADA';
        //ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
        ps.stage.Partner_Technology__c = 'Professional and Commercial Radio';
        //ps.createQueries();
        for(MM_Class_SearchController.PartnerQuery pq : ps.partnerQueries){
            System.debug('pq.query:  ' + pq.query);
            System.debug('pq.objTypeSet:  ' + pq.objTypeSet);
            Database.query(pq.query);
        }
        ps.stage.Partner_Technology__c = 'something else...';
        //ps.createQueries();
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