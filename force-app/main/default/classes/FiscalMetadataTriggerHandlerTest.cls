@isTest
public class FiscalMetadataTriggerHandlerTest {
    @isTest
    public static void FiscalMetadataTriggerHandler(){
        TestDataSetUpUtils.insertCustomSettings();
        Fiscal_Metadata__c fiscalMetadata = new Fiscal_Metadata__c();
        fiscalMetadata.Fiscal_Period__c='January';
        fiscalMetadata.Week_End_Date__c=Date.newInstance(2020,1,05);
        fiscalMetadata.Week_Start_Date__c=Date.newInstance(2020,1,01);
        fiscalMetadata.Year__c='2019';
        fiscalMetadata.Yearly_Week__c='1';
        insert fiscalMetadata;
        delete fiscalMetadata;
        undelete fiscalMetadata;
    }
}