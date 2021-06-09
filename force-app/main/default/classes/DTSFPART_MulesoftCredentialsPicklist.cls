global without sharing class DTSFPART_MulesoftCredentialsPicklist extends VisualEditor.DynamicPickList{
    
    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('', '');
        return defaultValue;
    }
    global override VisualEditor.DynamicPickListRows getValues() {
        List<NamedCredential> namedCredentials = [SELECT DeveloperName, MasterLabel FROM NamedCredential WHERE MasterLabel LIKE '%mulesoft%'];
        VisualEditor.DynamicPickListRows values = new VisualEditor.DynamicPickListRows();
        for (NamedCredential namedCredential : namedCredentials) {
            values.addRow(new VisualEditor.DataRow(namedCredential.MasterLabel, namedCredential.DeveloperName));
        }
        return values;
    }
}