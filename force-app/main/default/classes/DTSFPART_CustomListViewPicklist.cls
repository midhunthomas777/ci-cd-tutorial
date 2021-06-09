global without sharing class DTSFPART_CustomListViewPicklist extends VisualEditor.DynamicPickList{
    
    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('', '');
        return defaultValue;
    }
    global override VisualEditor.DynamicPickListRows getValues() {
        List<Custom_ListView__mdt> listViews = [SELECT MasterLabel, DeveloperName FROM Custom_ListView__mdt];
        VisualEditor.DynamicPickListRows values = new VisualEditor.DynamicPickListRows();
        for (Custom_ListView__mdt listView : listViews) {
            values.addRow(new VisualEditor.DataRow(listView.MasterLabel, listView.DeveloperName));
        }
        return values;
    }
}