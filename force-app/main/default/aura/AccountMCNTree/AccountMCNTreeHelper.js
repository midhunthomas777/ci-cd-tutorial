({
    getAccounts : function(component){
        $A.util.removeClass(component.find('loadingSpinner'), 'slds-hide');
        $A.util.addClass(component.find('loadingSpinner'), 'slds-show');         
        var action = component.get('c.getAccounts');       
        var accountId = component.get("v.accountId");        
        console.log('Helper accountId - '+ accountId);
        action.setParams({"accountId": accountId});
       
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state==="SUCCESS"){
                $A.util.removeClass(component.find('loadingSpinner'), 'slds-show');
                $A.util.addClass(component.find('loadingSpinner'), 'slds-hide');
                component.set("v.accounts",response.getReturnValue());
                
                console.log('Helper accountId middle - '+ accountId);
                
            }
        });
        console.log('Helper accountId end - '+ accountId);
        $A.enqueueAction(action);
    },
     SelectedMCN : function (component, event,MCNID) {
         
	   var myWindow = component.get("v.myWindow");
       var isAccount = component.get("v.isAccount");
       var setNewOppURL = component.get("v.setNewOppURL");  
       var oppId = component.get("v.oppId");  
         console.log('Opportunity ID -->>'+oppId);
             
       //alert(myWindow);       
       console.log('myWindow - '+ myWindow);
       var action = component.get('c.LtnSelectedMCN'); 
     
      //   debugger ;
       var pAccountId = component.get("v.accountId").toString();
       console.log('PA accountId - '+ pAccountId);
         
       action.setParams({ "MCNId": MCNID                          
                        });        
       action.setCallback(this, function(response) {
          var state = response.getState();
          if(component.isValid() && state==="SUCCESS"){
              console.log("Response SUCCESS" );
              if(isAccount =="True")
              	{
                    //alert("Account Call " + myWindow);
                    window.close();
                    window.open(myWindow); 
              	}
              else if(isAccount =="False") {
                  
                     window.location.href= setNewOppURL+"&cdhAccId="+MCNID;               
                   
                  
              }
          }         
      });
      $A.enqueueAction(action);      
    },
    
   cancelfun : function (component, event, helper) {
    
  	var urlEvent = $A.get("e.force:navigateToURL");
    if(urlEvent) {
      urlEvent.setParams({
        "url": "/home/home.jsp"
      });

      urlEvent.fire();
    } else {
      window.location.href = "/home/home.jsp"
    }
  
    
    
},
    
    oppfunction : function(component, event, MCNId){
       var setNewOppURL = component.get("v.setNewOppURL");  
       var isAccount = component.get("v.isAccount");
       var oppId = component.get("v.oppId");
        console.log('Op ID @@@@'+oppId);
        console.log('MCN ID --->>>'+ MCNId);
       var action = component.get('c.updateOpp'); 
            action.setParams({ "oppId" : oppId,"MCNId": MCNId     
                        }); 
        action.setCallback(this, function(response) {
          var state = response.getState();
           console.log('******Valid And State'+'ss'+state); 
          
           if(state==="SUCCESS"){
              //console.log("Response SUCCESS" );
                   if(isAccount =="False") {
                     //updateOpp(oppId,MCNID);
                     console.log('Entered setNewOppURL');
                    // window.location.href= setNewOppURL;   
                       window.close();
    	   window.open(setNewOppURL);
                   
             }
          }         
      });
      $A.enqueueAction(action);  
    },

                        
})