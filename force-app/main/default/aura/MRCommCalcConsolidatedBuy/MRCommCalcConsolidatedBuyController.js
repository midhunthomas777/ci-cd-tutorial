({
    doInit:function(component,event,helper) {   
        helper.getSitePrefix(component);
    },
    SearchMCN :function(component, event, helper) {
       component.set("v.detailWrap",[]);
       if(helper.validateMCN(component,'None')){
          console.log('test ');
            helper.getAccountDetail(component,helper); 
       } 
        //helper.createObjectData(component,event, helper);
    },
    doCalculate :function(component, event, helper) {
        console.log('mrpartnerlist==='+JSON.stringify(component.get("v.MRPartnerList")));
        //component.set("v.errorMsg",null);
        if(helper.validateForm(component)){
            component.set("v.reset",true);
            component.set("v.showPDFBtn",true);
            console.log("No Error");     
            var TOA = component.find("totalCommissionAmount").get("v.value");
            var OTCD = component.find("overrideTOA").get("v.value");           
            var TCP = (OTCD/TOA) *100;
            component.find("totalCommissionPercentage").set("v.value",TCP);
            component.find("totalCommissionDollars").set("v.value",OTCD);
            
            component.set("v.showPartnerInfo",true); 
            var partnerList = component.get("v.MRPartnerList");
            if(partnerList.length===0){
                helper.createObjectData(component,event, helper);
            }
        }
    },
    addNewRow: function(component, event, helper) {
        // call the comman "createObjectData" helper method for add new Object Row to List  
        helper.createObjectData(component, event);
    },
    // function for delete the row 
    removeDeletedRow: function(component, event, helper) {
        // get the selected row Index for delete, from Lightning Event Attribute  
        var index = event.getParam("indexVar");
        // get the all List (contactList attribute) and remove the Object Element Using splice method    
        var AllRowsList = component.get("v.MRPartnerList");
        AllRowsList.splice(index, 1);
        // set the contactList after remove selected row element  
        component.set("v.MRPartnerList", AllRowsList);
    },
    doReset: function(component, event, helper){
        component.set("v.MRPartnerList", []);
        component.set("v.showPartnerInfo",false);
        component.find("totalCommissionAmount").set("v.value",0.00);
        component.find("overrideTOA").set("v.value",0.00);           
        component.find("totalCommissionPercentage").set("v.value",0.00);
        component.find("totalCommissionDollars").set("v.value",0.00);
        component.find("comments").set("v.value",null); 
        var partnerList = component.get("v.MRPartnerList");
        console.log('partnerList '+partnerList.length);
    },
    doPrint : function(component, event, helper){
        if(helper.validateForm(component)){
        var accName=component.get("v.detailWrap.customerAccount.Parent.Name");
        var mcnNum= component.get("v.detailWrap.customerAccount.Motorola_Customer_Number__c");
        var mcnRTM= component.get("v.detailWrap.customerAccount.Primary_Route_to_Market__c");            
        var baseURL=component.get("v.getURL");
        var TOA = component.find("totalCommissionAmount").get("v.value");
        var OTCD = component.find("overrideTOA").get("v.value");           
        var TCP= component.find("totalCommissionPercentage").get("v.value");
        var TComPer= Math.round(TCP * 100) / 100;
        var TComDolr=component.find("totalCommissionDollars").get("v.value");
        var cmts=component.find("comments").get("v.value"); 
        var pdfBody= JSON.stringify(component.get("v.MRPartnerList"));
        //var pdfPage=baseURL+'/apex/ConsolidatedByCommission?rs='+pdfBody+"&accName="+accName+"&mcnNum="+mcnNum+"&TOA="+TOA+"&OTCD="+OTCD+"&TComPer="+TComPer+"&TComDolr="+TComDolr+"&cmts="+cmts;
        //SF-1643 - INC2030096 : Commission Calculator Issue
        var pdfURL = baseURL+'/apex/ConsolidatedByCommission?rs='+pdfBody+"&accName="+accName+"&mcnNum="+mcnNum+"&TOA="+TOA+"&OTCD="+OTCD+"&TComPer="+TComPer+"&TComDolr="+TComDolr+"&cmts="+cmts+"&mcnRTM="+mcnRTM;
        var pdfPage=encodeURI(pdfURL);
            
        window.open(pdfPage,"_blank");
        console.log('Executed Print');
        }
        
    }
})