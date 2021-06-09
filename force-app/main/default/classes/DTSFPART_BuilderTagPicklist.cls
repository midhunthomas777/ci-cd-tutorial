global class DTSFPART_BuilderTagPicklist extends VisualEditor.DynamicPickList{
    
    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('', '');
        return defaultValue;
    }
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows values = new VisualEditor.DynamicPickListRows();
        values.addRow(new VisualEditor.DataRow('', ''));
        Schema.DescribeFieldResult fieldResult = Contact.Tag__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f : ple) {
            values.addRow(new VisualEditor.DataRow(f.getLabel(), f.getValue()));
        }     
        return values;
    }
}