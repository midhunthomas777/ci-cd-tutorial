/****************************************************************************************************************************
* Description	:	Webservice for CPQ to fetch the below Attribute on New Quote Creation for Internal user
* 					AccessLevel; MCN; Sales_Channel	 
* Author		:	Anitha Mohankumar
* Created Date	: 	16th March 2017
* Modified		: 	4th Sep 2018
*				:	Modified webservice for CPQ to fetch below attributes on New Quote Creation from Account for MR Partner
* 					AccessLevel; MCN; Sales_Channel; MR_ID__c; Order_Type__c; Eligible_Percentage__c
*****************************************************************************************************************************/
global class CPQSoApCallForOpportunityAccount {
    
    webservice static String getRecordAccess(String myUser, String mysessionId, Id myAccID, Id myOppID) {        
        String strMCN;
        String strSC;
        String userType;
        String returnCPQValues;
        Id myUserId;
        //Integer  myUserCount = [SELECT count() from User where Core_ID__c = :myUser and IsActive = TRUE];    
        List<User>  myUserCount = [SELECT Id,UserType,FederationIdentifier,Core_ID__c from User where (Core_ID__c = :myUser OR FederationIdentifier =:myUser) and IsActive = TRUE LIMIT 1];    
        System.debug('myUser '+ myUSer);
        System.debug('myOppID '+ myOppID);
        System.debug('myAccID '+ myAccID);     
        if(!myUserCount.isEmpty()) {
            myUserId = myUserCount[0].Id;
            userType = myUserCount[0].UserType;
            //myUserId = [SELECT Id from User where Core_ID__c = :myUser LIMIT 1].Id;
            //userType = [SELECT UserType  from User where Core_ID__c = :myUser LIMIT 1].UserType;
        }else{
            System.debug('User does not exist for '+myUser);            
            returnCPQValues = 'AcessLevel:FALSE;MCN:null;Sales_Channel:null';
            return returnCPQValues;
        }     
        /*if(myUserCount == 0) {
            
        }*/
        System.debug('myUserId===>'+myUserId);
        //Opportunity
        if(String.isNotBlank(myOppID)) {
            String queryOppAccess = 'SELECT RecordId,MaxAccessLevel FROM UserRecordAccess WHERE UserId = \''+myUserId+'\' And RecordId = \''+myOppID + '\' LIMIT 1'; 
            List<UserRecordAccess> MaxAccessLevel = Database.query(queryOppAccess);     
            //Check if Opp exists
            if(MaxAccessLevel.isEmpty()) {
                System.debug('List is empty');                
                returnCPQValues='AcessLevel:FALSE;MCN:null;Sales_Channel:null';
                return returnCPQValues;                         
            } else {
                String oppAccessLevel = MaxAccessLevel[0].MaxAccessLevel;
                System.debug('oppAccessLevel '+ oppAccessLevel);                
                if(oppAccessLevel == 'None') {
                    returnCPQValues = 'AccessLevel:FALSE;MCN:null;Sales_Channel:null';
                    return returnCPQValues;           
                } else {
                    List<Opportunity> opplist = new List<Opportunity>(); 
                    //SF-93-Updated the query to fetch Sales Channel               
                    opplist = [SELECT CDH_Account__r.Motorola_Customer_Number__c,Account.Sales_Channel__c,Account.Prospect_Sales_Channel__c,
                               Account.RecordType.DeveloperName from Opportunity where Id=:myOppID LIMIT 1] ;
                    if(opplist.size() > 0) {
                        ////SF-2509 -Start
                        if(String.isNotBlank(opplist.get(0).CDH_Account__r.Motorola_Customer_Number__c)){
                            strMCN = opplist.get(0).CDH_Account__r.Motorola_Customer_Number__c;
                        }else{
                            List<UserSessionCPQ__c> userSessCPQList = [select CDH_Account_ID__c,MR_ID__c,Order_Type__c,Eligible_Percentage__c,Opportunity_Id__c,Type_of_Quote__c,recordId__c from 
                                                                       UserSessionCPQ__c where User_Id__c=: myUserId and Account_ID__c=: myAccID and Opportunity_Id__c=:myOppID Order by Lastmodifieddate Desc Limit 1 ];   
                            if(userSessCPQList.isEmpty()){ 
                                strMCN =null;
                            }else{
                                strMCN =[SELECT Motorola_Customer_Number__c from Account where Id=:userSessCPQList.get(0).CDH_Account_ID__c  LIMIT 1].Motorola_Customer_Number__c;
                            }                            
                        }
                        ////SF-2509 -End
                        //for(Opportunity Opp : opplist) {                            
                        //SF-93-Push Sales Channel to CPQ
                        if(opplist.get(0).Account.RecordType.DeveloperName == 'Prospect'){
                            //MR Quoting - MR Prospect SalesChannel
                            if(userType == 'Standard'){                    
                                strSC = opplist.get(0).Account.Sales_Channel__c;
                            } else If (userType =='PowerPartner'){
                                strSC= opplist.get(0).Account.Prospect_Sales_Channel__c;
                            }
                        } else {
                            strSC = null;   
                        }
                        //}                        
                        returnCPQValues = 'AccessLevel:TRUE;MCN:' + strMCN + ';Sales_Channel:' + strSC;  
                        System.debug('Opportunity call ReturnString- ' + returnCPQValues);
                        return returnCPQValues;                
                    }          
                }
            }
        }
        //Account Only
        if(String.isNotBlank(myAccID) && String.isBlank(myOppID)) {
            //SF-93-Push Sales_Channel to CPQ
            for(account accSC : [SELECT Sales_Channel__c,Prospect_Sales_Channel__c,RecordType.DeveloperName from Account where Id = :myAccID LIMIT 1]) {
                if(accSC.RecordType.DeveloperName == 'Prospect'){
                    //MR Quoting - MR Prospect SalesChannel
                    if( userType == 'Standard'){                    
                        strSC = accSC.Sales_Channel__c;
                    } else If(userType == 'PowerPartner'){
                        strSC = accSC.Prospect_Sales_Channel__c;
                    }
                } else {
                    strSC = null;   
                }
            }                
            System.debug('Account SC call ReturnString- ' + strSC);                                  
            UserSessionCPQ__c userSessCPQ = [select CDH_Account_ID__c,MR_ID__c,Order_Type__c,Eligible_Percentage__c,Opportunity_Id__c,Type_of_Quote__c,recordId__c from 
                                             UserSessionCPQ__c where User_Id__c=: myUserId and Account_ID__c=: myAccID Order by Lastmodifieddate Desc Limit 1 ];   
            if(userSessCPQ == null){                
                if(userType == 'Standard'){
                    //MR_ID__c;Order_Type__c;Eligible_Percentage__c
                    returnCPQValues = 'AccessLevel:TRUE;MCN:null;Sales_Channel:' + strSC;
                    return returnCPQValues;    
                } else If (userType == 'PowerPartner'){
                    returnCPQValues = 'AccessLevel:TRUE;MCN:null;Sales_Channel:' + strSC  + ';MR_ID__c:null;Order_Type__c:null;Eligible_Percentage__c:null';
                    return returnCPQValues;    
                }                                  
            } else {
                String mrID = userSessCPQ.MR_ID__c;
                String orderType = userSessCPQ.Order_Type__c;
                Double eligiblePercentage = userSessCPQ.Eligible_Percentage__c;                
                List<Account> accMCNlis = new List<account>();
                accMCNlis = [SELECT Motorola_Customer_Number__c from Account where Id=:userSessCPQ.CDH_Account_ID__c  LIMIT 1];
                for(account accMCN: accMCNlis)
                    strMCN =accMCN.Motorola_Customer_Number__c; 
                if( userType == 'Standard'){
                    returnCPQValues = 'AccessLevel:TRUE;MCN:' + strMCN + ';Sales_Channel:' + strSC;
                    if(String.isNotBlank(userSessCPQ.Opportunity_Id__c)) {
                        returnCPQValues = returnCPQValues + ';Opp_Id:' + userSessCPQ.Opportunity_Id__c + ';Opp_Type:' + userSessCPQ.Type_of_Quote__c + ';recordId:' + userSessCPQ.recordId__c;
                    }
                    System.debug('returnCPQValues ##>' + returnCPQValues);
                    return returnCPQValues;
                } else If (userType =='PowerPartner'){
                    returnCPQValues = 'AccessLevel:TRUE;MCN:' + strMCN + ';Sales_Channel:' + strSC  + ';MR_ID__c:' + mrID + ';Order_Type__c:' + orderType + ';Eligible_Percentage__c:' + eligiblePercentage;
                    system.debug('PP returnCPQValues###' + returnCPQValues);
                    return returnCPQValues;                     
                }                        
            }        
        }           
        returnCPQValues='AccessLevel:TRUE;MCN:null;Sales_Channel:null';        
        return returnCPQValues;             
    }
    
    //CPQ Comission Percentage recalculation for OM User Only
    webservice static String commissionPercentRecal(String cpqQuoteNumber, Decimal cpqTotalOrderAmount, Decimal cpqPEDiscount, 
                                                    Boolean cpqServiceFlag, String cpqOrderType)
    {        
        String returnValue = MRCommissionCalculatorCtrl.commissionPercentRecalCPQ(cpqQuoteNumber, cpqTotalOrderAmount,
                                                                                  cpqPEDiscount, cpqServiceFlag, cpqOrderType);        
        System.debug('CPQ returnValue - ' + returnValue);
        return returnValue;
    }
}