global without sharing class DTSFPART_ContactListViewPicklist extends VisualEditor.DynamicPickList{
    
    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('', '');
        return defaultValue;
    }
    global override VisualEditor.DynamicPickListRows getValues() {
        List<ListView> listViews = [SELECT Id, DeveloperName, Name FROM ListView WHERE SobjectType = 'Contact'];
        VisualEditor.DynamicPickListRows values = new VisualEditor.DynamicPickListRows();
        for (ListView listView : listViews) {
            values.addRow(new VisualEditor.DataRow(listView.Name, listView.DeveloperName));
        }
        return values;
    }
}