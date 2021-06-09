/*********************************************************************************************************************************************************
 * Name : NewOpportunityForCommunityCtrlTest
 * Description : Test class for NewOpportunityForCommunityCtrl
 * Author : 
 * Date : 
 * *******************************************************************************************************************************************************
 */
@isTest
public class NewOpportunityForCommunityCtrlTest {
	@isTest
    public static void testFetchAccessibleRecordTypes(){
        Map<String, String> recordTypeMap = new Map<String, String>();
        Boolean isPartner;
        Test.startTest();
        	recordTypeMap = NewOpportunityForCommunityCtrl.fetchAccessibleRecordTypes();
        	isPartner = NewOpportunityForCommunityCtrl.isPartnerUser();
        Test.stopTest();
    }
}