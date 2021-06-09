({  
    getSitePrefix : function(component){        
        var action = component.get("c.fetchSitePrefix");       
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.getURL",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);  
    },    
    getAccountDetail : function(component,helper) {
        //component.set("v.calculatorRecordProcessing",true);
        var action = component.get("c.fetchAccountDetails"); 
        var motoNum = component.find("MotorolaCustomerNumber").get("v.value");
        console.log('#######motoNum##########');
        console.log(motoNum);
        action.setParams({
            motoNum : motoNum            
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            console.log('state is'+state);
            if( state === "SUCCESS"){
                component.set('v.detailWrap', actionResult.getReturnValue());
                console.log('apex result'+component.get('v.detailWrap'));
                if(helper.validateMCN(component,state)){
                   // component.set('v.detailWrap', actionResult.getReturnValue());
                    component.set("v.calculatorRecordProcessing",false);
                    component.set("v.showAccountDetails",true);
                    component.set("v.showCommCalc",true);  
                }
            } 
            else{
                component.set("v.calculatorRecordProcessing",false);
            }
        });
        $A.enqueueAction(action);
    },
    validateMCN : function(component,state)  {
        var validForm = true;
        var errorMessage = []; 
        var errorString = '';
        var motoCustNum = component.find("MotorolaCustomerNumber").get("v.value");
        var res = component.get('v.detailWrap');
        if(($A.util.isUndefined(motoCustNum) || $A.util.isEmpty(motoCustNum))){
            validForm = false;
            errorString = "Please Enter Motrola Customer Number";
        }else if(isNaN(motoCustNum)){
            console.log('checking for number');
            validForm = false;
            errorString = "Please Enter Numeric Number";
        }else if(state!='None' && res === null){
            console.log('No MSI found'+state);
            validForm = false;
            errorString = "No MSI LED Found";
            component.set("v.calculatorRecordProcessing",false);
        }
        if(!validForm){
            errorMessage.push(["aura:unescapedHtml", {
                value : "<h2 Style=\"font-size:20px\">"+errorString+"</h2>"
            }]);
            this.createProductAlertBox(component, errorMessage);
        }
        else{
            errorString = ""; 
        }       
        return(validForm);
    },
    validateForm : function(component)  {
        var validForm = true;
        var errorMessage = [];
        var errorString = '';
        var totalDollarAmount = 0;
        var totalCommissionAmount = 0;
        var MRPartnerList = [];
        var TOA = component.find("totalCommissionAmount").get("v.value");
        var OTCD = component.find("overrideTOA").get("v.value");
        var comments = component.find("comments").get("v.value");
        
        
        MRPartnerList = component.get("v.MRPartnerList");
        console.log('MRPartnerList###########=>' + MRPartnerList.length);
        for(var i=0; i<MRPartnerList.length ; i++){
            console.log('MRPartnerList[i]###########=>' + MRPartnerList[i].MR_name__c);
            console.log('MRPartnerList[i].Dollar_amount_to_be_associated_to_MR__c###########=>' + MRPartnerList[i].Dollar_amount_to_be_associated_to_MR__c);
            console.log('MRPartnerList[i].Commission_amount_to_be_associated_to_MR__c###########=>' + MRPartnerList[i].Commission_amount_to_be_associated_to_MR__c);
            totalDollarAmount = totalDollarAmount + Number(MRPartnerList[i].Dollar_amount_to_be_associated_to_MR__c);
            totalCommissionAmount = totalCommissionAmount + Number(MRPartnerList[i].Commission_amount_to_be_associated_to_MR__c); 
            console.log('totalDollarAmount###########=>' + totalDollarAmount);
            console.log('totalCommissionAmount###########=>' + totalCommissionAmount);
            if(MRPartnerList[i].MR_Name__c == null || MRPartnerList[i].MR_Name__c == '' )
            {
                validForm = false;
                errorString = "Name of partners should not be left blank";
                console.log('errorString###########=>' + errorString);
            } else if(MRPartnerList[i].Dollar_amount_to_be_associated_to_MR__c == null || MRPartnerList[i].Dollar_amount_to_be_associated_to_MR__c == '' )
            {
                validForm = false;
                errorString = "Dollar Amount should not be left blank";
                console.log('errorString###########=>' + errorString);
            } 
             else if(MRPartnerList[i].Commission_amount_to_be_associated_to_MR__c == null || MRPartnerList[i].Commission_amount_to_be_associated_to_MR__c == '' )
            {
                validForm = false;
                errorString = "Commission Amount should not be left blank";
                console.log('errorString###########=>' + errorString);
            } 
        }

        if(TOA<=0){
            validForm = false;
            errorString = "Please Enter Total Order Amount to Calculate the Commission";
        }
        else if(($A.util.isUndefined(OTCD) || $A.util.isEmpty(OTCD) || OTCD<=0)){
            validForm = false;
            errorString = "Please Enter Override Total Commission Dollars (USD)";
        }
        else if(($A.util.isUndefined(comments) || $A.util.isEmpty(comments))){
            validForm = false;
            errorString = "Please Enter Comments";
        }
        else if(totalDollarAmount > TOA){
            validForm = false;
            errorString = "Add up of dollar amount for all partners should equal the total order amount";
        }
        else if(totalCommissionAmount > OTCD){
            validForm = false;
            errorString = "Add up of Commission amount for all partners should equal the Override Total Commission Dollars(OTCD)";
        }
       
        
        if(!validForm){
            errorMessage.push(["aura:unescapedHtml", {
                value : "<h2 Style=\"font-size:20px\">"+errorString+"</h2>"
            }]);
            this.createProductAlertBox(component, errorMessage);
        }
        else{
            errorString = "";
        }       
        return(validForm);
    },    
    createProductAlertBox : function(component, modalBody){
        
        $A.createComponents(modalBody,
                            function(newComponents){
                                var appProdValidationModal = component.find("goButtonValidation");
                                appProdValidationModal.set('v.body',newComponents);
                                appProdValidationModal.open();
                            });
    }, 
    createObjectData: function(component,helper,event) {
        // get the MRPartnerList from component and add(push) New Object to List  
        var RowItemList = component.get("v.MRPartnerList");
        RowItemList.push({
            'sobjectType': 'ConsolidatedBy_Partner_Information__mdt',
            'MR_Name__c': '',
            'MRID__c': '',
            'End_user_Customer_number__c': '',
            'End_user_Customer_name__c':'',
            'Dollar_amount_to_be_associated_to_MR__c':'',
            'Commission_amount_to_be_associated_to_MR__c':''
        });
        // set the updated list to attribute (MRPartnerList) again    
        component.set("v.MRPartnerList", RowItemList);
    },
    
})