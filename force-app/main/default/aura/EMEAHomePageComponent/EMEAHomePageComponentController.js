({
	doInit : function(component, event, helper) {
		component.set('v.columnNames',[
            {label: 'Contact Name', fieldName:'Name', type:'text'},
            {label: 'Phone Number', fieldName:'Phone', type:'phone'},
            {label: 'Email' ,fieldName: 'Email' , type:'email'},
        ]);
            helper.getData(component, event, helper);

	},
})