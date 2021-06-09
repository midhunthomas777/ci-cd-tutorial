@isTest
public class CreateNoteCtrlTest { 
    @isTest
    public static void CreateNoteCtrl(){
        TestDataSetUpUtils.insertCustomSettings();
        List<Briefing_Room_Report__c> lstBRR = new List<Briefing_Room_Report__c>();
        lstBRR.add(new Briefing_Room_Report__c(name='Week Ending April 24 2020'));
        lstBRR.add(new Briefing_Room_Report__c(name='Week Ending April 11 2020'));
        insert lstBRR;
        ContentNote cn = new ContentNote();
        cn.Title = 'test1';
        String body = 'Please work';
        cn.Content = Blob.valueOf(body.escapeHTML4());
        insert cn;
        CreateNoteCtrl.createContentNote(cn,lstBRR.get(0).Id);
        CreateNoteCtrl.createContentNote(cn,null);
        DisplayNotesBelowHeirarchyCtrl.getNotesForUser(lstBRR.get(0).Id);
        
    }
}