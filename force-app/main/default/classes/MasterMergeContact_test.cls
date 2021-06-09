@istest

public class MasterMergeContact_test
{
   private static testmethod void testMasterMerge(){
   MasterMergeContact mmc=new MasterMergeContact();
   MasterMergeContact.mergeContactIdSet = null;
   System.assertEquals(MasterMergeContact.mergeContactIdSet, MasterMergeContact.mergeContactIdSet);
   }
   
  }