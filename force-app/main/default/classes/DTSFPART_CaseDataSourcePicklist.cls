global without sharing class DTSFPART_CaseDataSourcePicklist extends VisualEditor.DynamicPickList{
    
    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('', '');
        return defaultValue;
    }
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows values = new VisualEditor.DynamicPickListRows();
        for (Case_Data_Source__mdt listView : Case_Data_Source__mdt.getall().values()) {
            values.addRow(new VisualEditor.DataRow(listView.MasterLabel, listView.DeveloperName));
        }
        return values;
    }
}