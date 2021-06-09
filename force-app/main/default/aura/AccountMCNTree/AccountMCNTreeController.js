({
     doInit : function(component, event, helper){
        console.log('get list of accounts****');       
        helper.getAccounts(component);      
    },   
  
    handleMyComponentEvent : function(component, event, helper) {
        var value = event.getParam("Pass_Selcted_count");
        var value1 =event.getParam("Pass_Selcted_MCN");
        var Accval=component.get("v.accountId");
        component.set("v.strChkbool", value); 
        
        console.log('Controller accountId - '+ Accval);   
        console.log('Pass_Selcted_MCN - '+ value1);  
        var getSelectedNumber = component.get("v.selectedCount");
        var selected = event.getParam("account");  
        var arr = component.get("v.selected");
        var arr1 = component.get("v.strSelectedMCN");
        var temp=[];
        if (value == true ) {            
   			getSelectedNumber++;           
 			arr.push(selected); 
            arr1.push(value1);
            component.set("v.strSelectedMCN", arr1);
        	component.set("v.selected", arr);            
  		} else {            
   			getSelectedNumber--;
            
            var index = arr.indexOf(selected);
            console.log("index - " + index );
            if (index == -1) {
              arr.splice(index, 1);
              }
           component.set("v.selected",arr);
           var index1 = arr1.indexOf(value1);
           console.log("index1 - " + index1 );
            //if (index1 == -1) {
              arr1.splice(index1, 1);
            //  }
           component.set("v.strSelectedMCN",arr1);
        }
        console.log("arr1.length - " + arr1.length);
        console.log("arr.length - " + arr.length);
        console.log("getSelectedNumber - " + getSelectedNumber);
       
        component.set("v.selectedCount", getSelectedNumber);  
       
    },
    
    Selected : function(component, event, helper){
        var oppId = component.get("v.oppId");
        console.log('Oportunity ID controller'+oppId);
        var arr = component.get("v.selected"); 
        var arr2 = component.get("v.strSelectedMCN");
        //alert("arr2.length - " + arr2.length) 
        var arr2len =parseInt(arr2.length);
        //alert("arr2.length - " + arr2len)
        if(arr2len >1){
			alert("Select only one Motorola Customer Number");        
        }else if(arr2len == 1){ 
             var MCNID = arr2[0];
            //alert("MCN: " + MCNID);
            if(oppId == null || oppId == ''){
            helper.SelectedMCN(component, event, MCNID);  
                    }
            else{
                helper.oppfunction(component, event, MCNID); 
            }
           // helper.SelectedMCN(component, event); 
        }else if(arr2len == 0){
            alert("Select one Motorola Customer Number");
        }
    },
    
    doCancel : function(component, event, helper){      
        var isAccount = component.get("v.isAccount");
        var setNewOppCancelURL = component.get("v.setNewOppCancelURL");
        //alert("isAccount? " +isAccount );
        if(isAccount =="True")
     	{
        	//alert("Cancel Button Account Call");
        	window.close();                    
       	}
 		else if(isAccount =="False"){
            //alert("Cancel Button Opportunity Call " +setNewOppCancelURL );            
			//window.history.back();
            //window.location.href= setNewOppCancelURL; 
           //helper.cancelfun(component,event,helper); 
           var setNewOppCancelURL = component.get("v.setNewOppCancelURL");    
    	   window.close();
    	   window.open(setNewOppCancelURL);        
		}
    },
})