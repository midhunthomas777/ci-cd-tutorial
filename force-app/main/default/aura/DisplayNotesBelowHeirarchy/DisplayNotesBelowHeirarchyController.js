({
    doInit : function(component, event, helper) {
        component.set("v.loadSpinner", true);
        component.set('v.columns', [
            {label: 'Title', fieldName: 'Id', type: 'url',typeAttributes: {label: { fieldName: 'Title' },target: '_blank'}},
            {label: 'Text Preview', fieldName: 'TextPreview', type: 'text',editable:true},
            {label: 'Created By', fieldName: 'CreatedByName', type: 'text', initialWidth: 300},
            {label: 'Last Modified By', fieldName: 'LastModifiedByName', type: 'text', initialWidth: 300}
           /* {type: "button"  , typeAttributes: {
                label: 'Edit',
                name: 'Edit',
                title: 'Edit',
                disabled: false,
                value: 'edit',
                iconPosition: 'left'
            }}*/
            //{label: 'Last Viewed Date', fieldName: 'LastViewedDate', type: 'text', initialWidth: 300}
        ]);
        
        helper.fetchNotes(component, event, helper);
    },
 
})