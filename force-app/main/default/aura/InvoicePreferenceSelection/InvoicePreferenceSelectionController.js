({
	getValue : function (component, event, helper) {
    	var src = event.getSource();
        var name = src.get("v.name");
        var email = src.get("v.value");
        
        if(name.includes("email")){
            helper.enabledisableEmails(component, event, email, name);
        }if(name.includes("name")){
            helper.enabledisableNames(component, event, email, name);
        }
    },
    
})