@isTest
private class MPP_Class_HLPR_Data_Test {
    /*
    * Method name   : test
    * Description   : To test method selectAllFrom and commitToDB of class MPP_Class_HLPR_Data
    * Return Type   : N/A
    * Parameter : nil
    */
    private static testMethod void test() {
        MPP_Class_HLPR_Data instOfMCHD = new MPP_Class_HLPR_Data();
        MPP_Class_HLPR_Data.OpperationType opp = MPP_Class_HLPR_Data.OpperationType.INSERT_RECS;
        TestDataSetUpUtils.activateAccTrigger();
        MPP_Class_HLPR_Data.commitToDB(opp,TestDataSetUpUtils.createAccounts(1,Schema.SObjectType.Account.RecordTypeInfosByName.get('Prospect').RecordTypeId));
        MPP_Class_HLPR_Data.OpperationType oppSec = MPP_Class_HLPR_Data.OpperationType.UPDATE_RECS;
        MPP_Class_HLPR_Data.commitToDB(oppSec,TestDataSetUpUtils.createAccounts(1,Schema.SObjectType.Account.RecordTypeInfosByName.get('Prospect').RecordTypeId));
        MPP_Class_HLPR_Data.OpperationType oppThir = MPP_Class_HLPR_Data.OpperationType.DELETE_RECS;
        MPP_Class_HLPR_Data.commitToDB(oppThir,TestDataSetUpUtils.createAccounts(1,Schema.SObjectType.Account.RecordTypeInfosByName.get('Prospect').RecordTypeId));
        MPP_Class_HLPR_Data.selectAllFrom('Account','');
    }
}