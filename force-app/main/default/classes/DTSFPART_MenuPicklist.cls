global without sharing class DTSFPART_MenuPicklist extends VisualEditor.DynamicPickList{
    
    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('', '');
        return defaultValue;
    }
    global override VisualEditor.DynamicPickListRows getValues() {
        List<NavigationLinkSet> navigationLinks = [SELECT Id, DeveloperName, MasterLabel, Network.Name FROM NavigationLinkSet];
        VisualEditor.DynamicPickListRows values = new VisualEditor.DynamicPickListRows();
        for (NavigationLinkSet navigationLink : navigationLinks) {
            values.addRow(new VisualEditor.DataRow(navigationLink.Network.Name + ' - ' + navigationLink.MasterLabel, navigationLink.DeveloperName));
        }
        return values;
    }
}