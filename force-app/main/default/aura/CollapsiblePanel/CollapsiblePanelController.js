({
    doInit:function(component,event,helper) {
       // alert('Body of collapse is');
        console.log('Body of collapse is'+component.get("v.body"));
        var outBody=component.get("v.outbody");
        console.log('outBody'+component.get("v.outBody"));
        if(outBody===true){
            var container = component.find("containerCollapsable") ;
                component.set("v.collpaseText","[ - ] ");
                $A.util.toggleClass(container, 'hide');  
        }
    },
	ToggleCollapse : function(component, event, helper) { 
		helper.ToggleCollapseHandler(component, event);
	},
    handleSectionHeaderClick : function(component, event, helper) {
        var button = event.getSource();
        button.set('v.state', !button.get('v.state'));

        var sectionContainer = component.find('collapsibleSectionContainer');
        $A.util.toggleClass(sectionContainer, "slds-is-open");
    },
     doPrint: function(component, event) {  
         console.log('print#####'+component.get("v.body") );
        
       $A.createComponent(
            "c:MRCommissionCalculatorPDF",
            {
                "body": component.get("v.body") //you can add more variables here
            },
            function(newTab, status, errorMessage){
                //Add the new tab to the body array
                if (status === "SUCCESS") {
                    console.log('Body created');
                    var body = component.get("v.body");
                    //body.push(newTab);
                    //component.set("v.body", newTab);
                    //window.open("https://motorolasolutions--sfcpqdev.lightning.force.com/c/MRCommissionCalculatorPDFApp.app","_blank");
                }
            }
        );
        
        var pdfbody= component.get("v.body");
        console.log('pdfbody is'+pdfbody);
        window.open("MRCommissionCalculatorPDFApp.app?body="+pdfbody,"_blank");
     }
})