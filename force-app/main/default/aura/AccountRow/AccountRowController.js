({
    onload : function(component, event, helper) {
        component.find("checkboxMCN").set("v.value", false);
    },
    showHidePanel : function(component, event, helper) {
        var id=component.get("v.acc.Id");        
        var e=document.getElementById(id); 
        console.log('Value of E' + e.style.display);
        if (e.style.display == 'block' || e.style.display==''){
            e.style.display = 'none';
            component.set("v.ext","plus");
        }else{
            e.style.display = 'block';
            component.set("v.ext","minus");
        } 
    },
    
    select : function(component, event, helper) {
        var account = component.get("v.acc");
        console.log("account: " + account);
        //var selectEvent = $A.get("e.c:selectAccount");       
        //selectEvent.setParams({ "account": account }).fire();
        var myEvent = component.getEvent("myComponentEvent");       
      	var checkCmp = component.find("checkboxMCN");
     	var selectedRec = event.getSource().get("v.value"); 
        myEvent.setParams({"Pass_Selcted_count": selectedRec});
   	    myEvent.setParams({"Pass_Selcted_MCN": checkCmp.get("v.text")});
        myEvent.setParams({"account": account});
        myEvent.fire(); 
    },
    
    onCheck: function(component, event) {
      var myEvent = component.getEvent("myComponentEvent");       
      var checkCmp = component.find("checkboxMCN");
      var selectedRec = event.getSource().get("v.value");        
        
       
      //myEvent.setParams({"Pass_Selcted_count": selectedRec});
   	  //myEvent.setParams({"Pass_Selcted_MCN": checkCmp.get("v.text")});
      //myEvent.fire(); 
     
      var getAllcount = component.get("v.ChildselectedCount");
      //console.log("getAllcount - " + getAllcount);
      ////Tryingstart
        var tempIDs = [];
 
        // get(find) all checkboxes with aura:id "checkBox"
        var getAllId = component.find("checkBox");
 
        // play a for loop and check every checkbox values 
        // if value is checked(true) then add those Id (store in Text attribute on checkbox) in tempIDs var.
        for (var i = 0; i < getAllId.length; i++) {
            
       if (getAllId[i].get("v.value") == true) {
                tempIDs.push(getAllId[i].get("v.text"));
            }
        }
        ////TryingEnd
    }, 
    
    openMCNdetail : function(component, event){        
        var selectedItem = event.currentTarget;
        var oppId = selectedItem.dataset.record; 
        var baseURL = window.location.origin;
        window.location.href =  baseURL +'/'+ oppId
    },
})