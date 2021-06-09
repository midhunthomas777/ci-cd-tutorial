/************************************************************************************
Creator                   : Rajesh Kumar
Method                    : AccountTriggerHanlder
Created Date              : 25-3-2017   
Desc                      : Whenever child Account is inserted or updated,Customer Number is updated on parent Account.

************************************************************************************/
public without sharing class AccountMCNTriggerHandler{
    /************************
Method  : Recursive Method  
Desc    : To call this Method trigger will be run only once.

*************************/
    public static boolean insertmethodAlreadyCalled=true;
    public static boolean updatemethodAlreadyCalled=true;
    public static boolean futurecalloutflag=false;
    @testvisible
    private static boolean run = true;
    public static boolean runOnce(){
        if(run){
            system.debug('handler method ');
            run=false;
            return true;
            
        }else{
            return run;
        }
    }  
    
    /************************
Method  : Insert Method 

Desc    : Insert the Child Motorola Customer Number,ERP Active and Primary Route to Market fields are concatenate to Customer Number field In  Parent . 

*************************/  
    public static void onBeforeInsert(List<Account> Accountlist) {
        try{ 
            Set<Id> parentIdSet = new Set<Id>();
            for(Account ac : Accountlist){
                //system.debug('start here ');
                string recordtypename = Schema.SObjectType.Account.getRecordTypeInfosById().get(ac.RecordTypeId).getname();
                if(String.isNotBlank(ac.Motorola_Customer_Number__c) && String.isNotBlank(ac.ParentId) && recordtypename.equalsignorecase('Motorola Customer Number')){
                    //system.debug('ac.parentId'+ac.parentId+'ac.Motorola_Customer_Number__c'+ac.Motorola_Customer_Number__c+'RecordType.name'+ac.RecordType.name);
                    parentIdSet.add(ac.ParentId);
                    //system.debug('parentIdSet'+parentIdSet);
                }
            }
            if(parentIdSet.size()>0){
                Map<Id,Account> allParentRecords = new Map<Id,Account>([select Id,MCN_Account_Number__c,Primary_Route_to_Market__c from Account where id in: parentIdSet AND  RecordType.name in('Customer','Prospect')]);
                //system.debug('allParentRecords '+allParentRecords );
                if(allParentRecords.size() >0){
                    for(Account chilac :Accountlist){
                        //system.debug('chilac'+chilac);
                        if(allParentRecords.size() > 0 && allParentRecords.containsKey(chilac.parentId)){
                            String ERPActive='';
                            if(chilac.ERP_Active__c)
                                ERPActive='Active';
                            else
                                ERPActive='Inactive';
                            if(String.isNotBlank(chilac.Motorola_Customer_Number__c)&&String.isBlank(chilac.Primary_Route_to_Market__c)){
                                
                                if(String.isBlank(allParentRecords.get(chilac.ParentId).MCN_Account_Number__c))
                                    allParentRecords.get(chilac.ParentId).MCN_Account_Number__c =chilac.Motorola_Customer_Number__c +' '+'('+ ERPActive+')';
                                else                            
                                    allParentRecords.get(chilac.ParentId).MCN_Account_Number__c=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c+'\n'+chilac.Motorola_Customer_Number__c + ' ' +'('+ ERPActive+')';                   
                            }
                            else{
                                
                                if(String.isNotBlank(chilac.Motorola_Customer_Number__c)){                          
                                    if(String.isBlank(allParentRecords.get(chilac.ParentId).MCN_Account_Number__c))
                                        allParentRecords.get(chilac.ParentId).MCN_Account_Number__c =chilac.Motorola_Customer_Number__c +' '+'('+ ERPActive+')' + ' '+ '|' + ' '+ chilac.Primary_Route_to_Market__c; 
                                    else 
                                        allParentRecords.get(chilac.ParentId).MCN_Account_Number__c=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c+'\n'+chilac.Motorola_Customer_Number__c + ' ' +'('+ ERPActive+')' + ' '+ '|' + ' '+ chilac.Primary_Route_to_Market__c;  
                                } 
                            }
                            
                        }
                    }
                    system.debug('allParentRecords.values().size()===>'+(allParentRecords.values().size()));
                    if(allParentRecords.values().size() > 0){
                        insertmethodAlreadyCalled=false;
                        update allParentRecords.values();
                    }
                    system.debug('allParentRecords.values()===>'+allParentRecords.values());
                }
            }
        }
        catch(Exception e) {
            system.debug('Insert Method is Failed =====>'+e.getMessage());
        }   
        
    }
    /************************
Method  : Upate  Method 

Desc    : a)Updated the Child Motorola Customer Number,ERP Active and Primary Route to Market fields are concatenate to Customer Number field In  Parent . 
or Changing the one Motorola child Account from One parent to another Parent.
*************************/
    
    public static void onAfterUpdate(List<Account> Accountlist) {
        try{
            system.debug('Accountlist@@@@@'+Accountlist);
            Set<Id> parentIdSet = new Set<Id>();
            Set<Id> parentIdOldAccSet = new Set<Id>();
            for(Account ac:Accountlist){
                Account objOldAcc= (Account) Trigger.oldMap.get(ac.Id);
                string recordtypename = Schema.SObjectType.Account.getRecordTypeInfosById().get(ac.RecordTypeId).getname();
                if(String.isNotBlank(ac.ParentId) && recordtypename.equalsignorecase('Motorola Customer Number') && (ac.Motorola_Customer_Number__c != objOldAcc.Motorola_Customer_Number__c || ac.Primary_Route_to_Market__c != objOldAcc.Primary_Route_to_Market__c || ac.ERP_Active__c != objOldAcc.ERP_Active__c ||  ac.ParentId != objOldAcc.ParentId)){
                    parentIdSet.add(ac.ParentId);  
                    system.debug('parentIdSet-->'+parentIdSet);
                }
                //*******************to change child acc from one parent  to  parent another acount*******************//      
                system.debug('objOldAcc@@@@@'+objOldAcc);
                if(String.isNotBlank(ac.ParentId) && recordtypename.equalsignorecase('Motorola Customer Number') && ac.ParentId != objOldAcc.ParentId){
                    parentIdOldAccSet.add(objOldAcc.ParentId); 
                    system.debug('parentIdOldAccSet-->'+parentIdOldAccSet);                  
                }
            } 
            if(parentIdSet.size()>0){
                Map<Id,Account> allParentRecords = new Map<Id,Account>([select Id,MCN_Account_Number__c,Primary_Route_to_Market__c from Account where id in: parentIdSet AND  RecordType.name in('Customer','Prospect')]);
                system.debug('allParentRecords1-->'+allParentRecords);
                if(allParentRecords.size() >0){
                    for(Account chilac :Accountlist){
                        system.debug('parentIdSet'+chilac.parentId);
                        if(allParentRecords.size() > 0 && allParentRecords.containsKey(chilac.parentId)){
                            system.debug('allParentRecords 2-->'+allParentRecords);
                            String ERPActive='';
                            if(chilac.ERP_Active__c)
                                ERPActive='Active';
                            else
                                ERPActive='Inactive';
                            
                            
                            if(String.isBlank(chilac.Primary_Route_to_Market__c)){
                                if(String.isNotBlank(chilac.Motorola_Customer_Number__c) &&String.isBlank(allParentRecords.get(chilac.ParentId).MCN_Account_Number__c)){
                                    allParentRecords.get(chilac.ParentId).MCN_Account_Number__c =chilac.Motorola_Customer_Number__c +' '+'('+ ERPActive+')'; 
                                    system.debug('allParentRecords 3-->'+ allParentRecords.get(chilac.ParentId).MCN_Account_Number__c );
                                }
                                else{  
                                    system.debug('else part with Primary null------>');
                                    Account OldvalChild= (Account) Trigger.oldMap.get(chilac.Id);    
                                    if((OldvalChild.Motorola_Customer_Number__c != null && allParentRecords.get(chilac.ParentId).MCN_Account_Number__c.contains(OldvalChild.Motorola_Customer_Number__c))                
                                       && ((OldvalChild.Motorola_Customer_Number__c != chilac.Motorola_Customer_Number__c) || 
                                           (OldvalChild.ERP_Active__c!=Chilac.ERP_Active__c) || (OldvalChild.Primary_Route_to_Market__c != Chilac.Primary_Route_to_Market__c)))
                                    {
                                        if(String.isNotBlank(allParentRecords.get(chilac.ParentId).MCN_Account_Number__c)){
                                            system.debug('main if condition 1--->');
                                            if((OldvalChild.Motorola_Customer_Number__c != chilac.Motorola_Customer_Number__c)){
                                                
                                                if(String.isNotBlank(OldvalChild.Primary_Route_to_Market__c)){
                                                    system.debug('OldvalChild.Primary_Route_to_Market__c1');
                                                    allParentRecords.get(chilac.ParentId).MCN_Account_Number__c=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c.remove(OldvalChild.Motorola_Customer_Number__c+ ' ' +'('+ 'Active'+')' + ' '+ '|' + ' '+OldvalChild.Primary_Route_to_Market__c);
                                                    allParentRecords.get(chilac.ParentId).MCN_Account_Number__c=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c.remove(OldvalChild.Motorola_Customer_Number__c + ' ' +'('+ 'Inactive'+')' + ' '+ '|' + ' '+OldvalChild.Primary_Route_to_Market__c);
                                                }
                                                else{
                                                    system.debug('OldvalChild.Primary_Route_to_Market__c2');
                                                    allParentRecords.get(chilac.ParentId).MCN_Account_Number__c=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c.remove(OldvalChild.Motorola_Customer_Number__c+ ' ' +'('+ 'Active'+')');
                                                    allParentRecords.get(chilac.ParentId).MCN_Account_Number__c=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c.remove(OldvalChild.Motorola_Customer_Number__c+ ' ' +'('+ 'Inactive'+')');
                                                }
                                                system.debug('main if condition  2 second one--->');
                                                
                                            }
                                            
                                            if(OldvalChild.ERP_Active__c!=Chilac.ERP_Active__c && OldvalChild.Primary_Route_to_Market__c == Chilac.Primary_Route_to_Market__c){
                                                
                                                allParentRecords.get(chilac.ParentId).MCN_Account_Number__c=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c.remove(OldvalChild.Motorola_Customer_Number__c+ ' ' +'('+ 'Active'+')');
                                                allParentRecords.get(chilac.ParentId).MCN_Account_Number__c=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c.remove(OldvalChild.Motorola_Customer_Number__c + ' ' +'('+ 'Inactive'+')');
                                                system.debug('main if condition  3--->');
                                                
                                            }
                                            // third if condition //
                                            if(OldvalChild.Primary_Route_to_Market__c !=Chilac.Primary_Route_to_Market__c && OldvalChild.ERP_Active__c == Chilac.ERP_Active__c ){
                                                system.debug('main if condition 4 primary --->'+OldvalChild.Primary_Route_to_Market__c);
                                                system.debug('main if condition 4 Motorola--->'+OldvalChild.Motorola_Customer_Number__c);
                                                allParentRecords.get(chilac.ParentId).MCN_Account_Number__c=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c.remove(OldvalChild.Motorola_Customer_Number__c+ ' ' +'('+ 'Active'+')' + ' '+ '|' + ' '+ OldvalChild.Primary_Route_to_Market__c);
                                                allParentRecords.get(chilac.ParentId).MCN_Account_Number__c=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c.remove(OldvalChild.Motorola_Customer_Number__c + ' ' +'('+ 'Inactive'+')' + ' '+ '|' + ' '+OldvalChild.Primary_Route_to_Market__c);
                                                
                                            }
                                            // third if condition //
                                            if(OldvalChild.Primary_Route_to_Market__c !=Chilac.Primary_Route_to_Market__c && OldvalChild.ERP_Active__c != Chilac.ERP_Active__c ){
                                                system.debug('main if condition 4 primary last --->'+OldvalChild.Primary_Route_to_Market__c);
                                                system.debug('main if condition 4 Motorola--->'+OldvalChild.Motorola_Customer_Number__c);
                                                allParentRecords.get(chilac.ParentId).MCN_Account_Number__c=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c.remove(OldvalChild.Motorola_Customer_Number__c+ ' ' +'('+ 'Active'+')' + ' '+ '|' + ' '+ OldvalChild.Primary_Route_to_Market__c);
                                                allParentRecords.get(chilac.ParentId).MCN_Account_Number__c=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c.remove(OldvalChild.Motorola_Customer_Number__c + ' ' +'('+ 'Inactive'+')' + ' '+ '|' + ' '+OldvalChild.Primary_Route_to_Market__c);
                                                
                                            } 
                                            // four th if condition //
                                            if(!String.isBlank(chilac.Motorola_Customer_Number__c)){
                                                allParentRecords.get(chilac.ParentId).MCN_Account_Number__c=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c+'\n'+chilac.Motorola_Customer_Number__c+ ' ' +'('+ ERPActive+')';
                                                
                                            }
                                            else{
                                                allParentRecords.get(chilac.ParentId).MCN_Account_Number__c=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c.remove(OldvalChild.Motorola_Customer_Number__c+ ' ' +'('+ 'Active'+')');
                                                allParentRecords.get(chilac.ParentId).MCN_Account_Number__c=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c.remove(OldvalChild.Motorola_Customer_Number__c+ ' ' +'('+ 'Inactive'+')' );
                                                
                                            }
                                        }                                                 
                                        
                                    }
                                    else{
                                        system.debug('last if check0');
                                        if (String.isNotBlank(chilac.Motorola_Customer_Number__c)){   
                                            system.debug('last if check1');   
                                            if(!(allParentRecords.get(chilac.ParentId).MCN_Account_Number__c.contains(chilac.Motorola_Customer_Number__c))){                                               
                                                allParentRecords.get(chilac.ParentId).MCN_Account_Number__c=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c+'\n'+chilac.Motorola_Customer_Number__c+ ' ' +'('+ ERPActive+')';
                                                system.debug('last if check2'+allParentRecords.get(chilac.ParentId).MCN_Account_Number__c);
                                            }
                                        }  
                                        
                                        
                                    }
                                    
                                    // remove blank values //
                                    if (String.isNotBlank(allParentRecords.get(chilac.ParentId).MCN_Account_Number__c)){
                                        List<String> RemoveBreaktag=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c.split('\n');
                                        allParentRecords.get(chilac.ParentId).MCN_Account_Number__c='';
                                        if(RemoveBreaktag.size()>0){
                                            for(String rem: RemoveBreaktag){
                                                // acp.MCN_Account_Number__c='';
                                                if(!string.isblank(rem))
                                                {
                                                    if(allParentRecords.get(chilac.ParentId).MCN_Account_Number__c == ''){
                                                        allParentRecords.get(chilac.ParentId).MCN_Account_Number__c =rem;                                               
                                                    }
                                                    else{
                                                        allParentRecords.get(chilac.ParentId).MCN_Account_Number__c=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c+'\n'+ rem;
                                                    }
                                                }
                                            }
                                        } 
                                    }
                                    // End of remove breank tag//         
                                } 
                                
                            }
                            else{
                                system.debug('------------else part update Method1--------------');
                                if(String.isNotBlank(chilac.Motorola_Customer_Number__c)&& String.isBlank(allParentRecords.get(chilac.ParentId).MCN_Account_Number__c)){
                                    allParentRecords.get(chilac.ParentId).MCN_Account_Number__c =chilac.Motorola_Customer_Number__c +' '+'('+ ERPActive+')' + ' '+ '|' + ' '+ chilac.Primary_Route_to_Market__c; 
                                    system.debug('allParentRecords 3-->'+ allParentRecords.get(chilac.ParentId).MCN_Account_Number__c );
                                }
                                else{  
                                    system.debug('------------else part update Method2--------------');
                                    Account OldvalChild= (Account) Trigger.oldMap.get(chilac.Id);                                   
                                    if((OldvalChild.Motorola_Customer_Number__c != null && allParentRecords.get(chilac.ParentId).MCN_Account_Number__c.contains(OldvalChild.Motorola_Customer_Number__c))                
                                       && ((OldvalChild.Motorola_Customer_Number__c != chilac.Motorola_Customer_Number__c) || 
                                           (OldvalChild.ERP_Active__c!=Chilac.ERP_Active__c) || (OldvalChild.Primary_Route_to_Market__c != Chilac.Primary_Route_to_Market__c))){
                                               system.debug('main if condition 1--->');
                                               if(String.isNotBlank(allParentRecords.get(chilac.ParentId).MCN_Account_Number__c)){
                                                   if((OldvalChild.Motorola_Customer_Number__c != chilac.Motorola_Customer_Number__c)){
                                                       system.debug('main if condition 2--->');
                                                       if(String.isNotBlank(OldvalChild.Primary_Route_to_Market__c)){
                                                           system.debug('OldvalChild.Primary_Route_to_Market__c');
                                                           allParentRecords.get(chilac.ParentId).MCN_Account_Number__c=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c.remove(OldvalChild.Motorola_Customer_Number__c+ ' ' +'('+ 'Active'+')' + ' '+ '|' + ' '+OldvalChild.Primary_Route_to_Market__c);
                                                           allParentRecords.get(chilac.ParentId).MCN_Account_Number__c=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c.remove(OldvalChild.Motorola_Customer_Number__c + ' ' +'('+ 'Inactive'+')' + ' '+ '|' + ' '+OldvalChild.Primary_Route_to_Market__c);
                                                       }
                                                       else{
                                                           allParentRecords.get(chilac.ParentId).MCN_Account_Number__c=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c.remove(OldvalChild.Motorola_Customer_Number__c+ ' ' +'('+ 'Active'+')');
                                                           allParentRecords.get(chilac.ParentId).MCN_Account_Number__c=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c.remove(OldvalChild.Motorola_Customer_Number__c+ ' ' +'('+ 'Inactive'+')');
                                                       }
                                                   }
                                                   
                                                   //second if condition //
                                                   if((OldvalChild.ERP_Active__c!=Chilac.ERP_Active__c)){
                                                       system.debug('main if condition 3--->');
                                                       allParentRecords.get(chilac.ParentId).MCN_Account_Number__c=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c.remove(OldvalChild.Motorola_Customer_Number__c+ ' ' +'('+ 'Active'+')' + ' '+ '|' + ' '+ OldvalChild.Primary_Route_to_Market__c);
                                                       allParentRecords.get(chilac.ParentId).MCN_Account_Number__c=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c.remove(OldvalChild.Motorola_Customer_Number__c + ' ' +'('+ 'Inactive'+')'+ ' '+ '|' + ' '+OldvalChild.Primary_Route_to_Market__c);
                                                       
                                                   }
                                                   
                                                   // third if condition //
                                                   if((OldvalChild.Primary_Route_to_Market__c !=Chilac.Primary_Route_to_Market__c)){
                                                       system.debug('main if condition 4--->');
                                                       if(String.isNotBlank(OldvalChild.Primary_Route_to_Market__c)){
                                                           allParentRecords.get(chilac.ParentId).MCN_Account_Number__c=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c.remove(OldvalChild.Motorola_Customer_Number__c+ ' ' +'('+ 'Active'+')' + ' '+ '|' + ' '+OldvalChild.Primary_Route_to_Market__c);
                                                           allParentRecords.get(chilac.ParentId).MCN_Account_Number__c=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c.remove(OldvalChild.Motorola_Customer_Number__c + ' ' +'('+ 'Inactive'+')' + ' '+ '|' + ' '+OldvalChild.Primary_Route_to_Market__c);
                                                       }
                                                       else{
                                                           allParentRecords.get(chilac.ParentId).MCN_Account_Number__c=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c.remove(OldvalChild.Motorola_Customer_Number__c+ ' ' +'('+ 'Active'+')');
                                                           allParentRecords.get(chilac.ParentId).MCN_Account_Number__c=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c.remove(OldvalChild.Motorola_Customer_Number__c+ ' ' +'('+ 'Inactive'+')');
                                                       }
                                                   }
                                                   // four th if condition //
                                                   if(!String.isBlank(chilac.Motorola_Customer_Number__c)){
                                                       system.debug('main if condition 5--->');
                                                       allParentRecords.get(chilac.ParentId).MCN_Account_Number__c=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c+'\n'+chilac.Motorola_Customer_Number__c+ ' ' +'('+ ERPActive+')' + ' '+ '|' + ' '+chilac.Primary_Route_to_Market__c;
                                                       System.debug('step2'+OldvalChild.Motorola_Customer_Number__c);
                                                   }
                                                   
                                                   else{
                                                       allParentRecords.get(chilac.ParentId).MCN_Account_Number__c=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c.remove(OldvalChild.Motorola_Customer_Number__c+ ' ' +'('+ 'Active'+')' + ' '+ '|' + ' '+OldvalChild.Primary_Route_to_Market__c);
                                                       allParentRecords.get(chilac.ParentId).MCN_Account_Number__c=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c.remove(OldvalChild.Motorola_Customer_Number__c+ ' ' +'('+ 'Inactive'+')' + ' '+ '|' + ' '+OldvalChild.Primary_Route_to_Market__c);
                                                       
                                                       system.debug('Motrola number is null value');
                                                   }
                                               }
                                               
                                           }
                                    else{
                                        system.debug('check map-->');
                                        if(String.isNotBlank(chilac.Motorola_Customer_Number__c)){
                                            if(!(allParentRecords.get(chilac.ParentId).MCN_Account_Number__c.contains(chilac.Motorola_Customer_Number__c))){                                               
                                                allParentRecords.get(chilac.ParentId).MCN_Account_Number__c=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c+'\n'+chilac.Motorola_Customer_Number__c+ ' ' +'('+ ERPActive+')'+ ' '+ '|' + ' '+ chilac.Primary_Route_to_Market__c;
                                                System.debug('last else part===>'+allParentRecords.get(chilac.ParentId).MCN_Account_Number__c);
                                            }
                                        } 
                                    }                                          
                                    // remove blank values //
                                    if(allParentRecords.get(chilac.ParentId).MCN_Account_Number__c != null){
                                        List<String> RemoveBreaktag=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c.split('\n');                                   
                                        allParentRecords.get(chilac.ParentId).MCN_Account_Number__c='';
                                        if(RemoveBreaktag.size()>0){
                                            for(String rem: RemoveBreaktag){
                                                // acp.MCN_Account_Number__c='';
                                                if(!string.isblank(rem)){
                                                    if(allParentRecords.get(chilac.ParentId).MCN_Account_Number__c == ''){
                                                        allParentRecords.get(chilac.ParentId).MCN_Account_Number__c =rem;                                               
                                                    }
                                                    else{
                                                        system.debug('remove method====>'+allParentRecords.get(chilac.ParentId).MCN_Account_Number__c+'\n'+ rem);
                                                        allParentRecords.get(chilac.ParentId).MCN_Account_Number__c=allParentRecords.get(chilac.ParentId).MCN_Account_Number__c+'\n'+ rem;
                                                    }
                                                }
                                            }
                                        } 
                                    }
                                    
                                    // End of remove breank tag//         
                                }
                                
                            } // else part without Primary route to Market field //
                            
                        } // End of parentacc size check //
                    }
                    system.debug('allParentRecords.values()update====>'+allParentRecords.values());
                    if(allParentRecords.values().size() > 0){
                        updatemethodAlreadyCalled=false;
                        system.debug('allParentRecords.values()update====>'+allParentRecords.values().size());
                        update allParentRecords.values();
                    }
                }
                
            }
            //**********Remove the  child Motorola number in old Parent acc*********************//
            if(parentIdOldAccSet.size() > 0){    
                Map<Id,Account> ParentOldAccMap = new Map<Id,Account>([select id,MCN_Account_Number__c,Primary_Route_to_Market__c  from Account where id in: parentIdOldAccSet  AND  RecordType.name in('Customer','Prospect')]);
                system.debug('ParentOldAccMap  soql ========>'+ParentOldAccMap);
                if(ParentOldAccMap.size() >0){
                    for(Account chilac :Accountlist){                         
                        Account objOldAcc= (Account) Trigger.oldMap.get(chilac.Id);
                        if(ParentOldAccMap.size() > 0 && ParentOldAccMap.containsKey(objOldAcc.ParentId)  && ParentOldAccMap.get(objOldAcc.ParentId).MCN_Account_Number__c != null){
                            if(String.isBlank(chilac.Primary_Route_to_Market__c)){
                                String MCNActive='';
                                String MCNInActive='';
                                MCNActive=objOldAcc.Motorola_Customer_Number__c+ ' ' +'('+ 'Active'+')';
                                MCNInActive=objOldAcc.Motorola_Customer_Number__c + ' ' +'('+ 'Inactive'+')';
                                ParentOldAccMap.get(objOldAcc.ParentId).MCN_Account_Number__c=ParentOldAccMap.get(objOldAcc.ParentId).MCN_Account_Number__c.remove(MCNActive);                                    
                                ParentOldAccMap.get(objOldAcc.ParentId).MCN_Account_Number__c=ParentOldAccMap.get(objOldAcc.ParentId).MCN_Account_Number__c.remove(MCNInActive);
                            }
                            else{
                                String MCNActive='';
                                String MCNInActive='';
                                MCNActive=objOldAcc.Motorola_Customer_Number__c+ ' ' +'('+ 'Active'+')' + ' '+ '|' + ' '+ objOldAcc.Primary_Route_to_Market__c;
                                MCNInActive=objOldAcc.Motorola_Customer_Number__c + ' ' +'('+ 'Inactive'+')'+ ' '+ '|' + ' '+ objOldAcc.Primary_Route_to_Market__c;
                                ParentOldAccMap.get(objOldAcc.ParentId).MCN_Account_Number__c=ParentOldAccMap.get(objOldAcc.ParentId).MCN_Account_Number__c.remove(MCNActive);                                    
                                ParentOldAccMap.get(objOldAcc.ParentId).MCN_Account_Number__c=ParentOldAccMap.get(objOldAcc.ParentId).MCN_Account_Number__c.remove(MCNInActive);
                            }
                            if(String.isNotBlank(ParentOldAccMap.get(objOldAcc.ParentId).MCN_Account_Number__c)) {                                 
                                List<String> RemoveBreaktag=ParentOldAccMap.get(objOldAcc.ParentId).MCN_Account_Number__c.split('\n');
                                ParentOldAccMap.get(objOldAcc.ParentId).MCN_Account_Number__c='';
                                if(RemoveBreaktag.size()>0){
                                    for(String rem: RemoveBreaktag){
                                        // acp.MCN_Account_Number__c='';
                                        if(!string.isblank(rem)){
                                            if(ParentOldAccMap.get(objOldAcc.ParentId).MCN_Account_Number__c== ''){
                                                ParentOldAccMap.get(objOldAcc.ParentId).MCN_Account_Number__c=rem;
                                            }
                                            else{
                                                ParentOldAccMap.get(objOldAcc.ParentId).MCN_Account_Number__c=ParentOldAccMap.get(objOldAcc.ParentId).MCN_Account_Number__c+'\n'+ rem;
                                            }
                                        }
                                    }
                                } 
                            }
                        }
                    }
                    system.debug(' old one parent to another ParentOldAccMap.values()-->'+ParentOldAccMap.values());
                    if(ParentOldAccMap.values().size() > 0){
                        updatemethodAlreadyCalled=false;
                        update ParentOldAccMap.values();
                    }                      
                } 
            }
            
        }  
        catch(Exception e){ 
            system.debug('Update Method is Failed =====>'+e.getMessage());
            
        }
        
    } 
    
    /************************
Method  : Delete   Method 

Desc    : Delete  the Child Motorola Customer Number from parent Account.

*************************/
    public static void onAfterDelete(List<Account> Accountlist) {
        try{        
            Set<Id> DelParentIdset = new Set<Id>();
            for(Account accdel: Accountlist){
                string recordtypename = Schema.SObjectType.Account.getRecordTypeInfosById().get(accdel.RecordTypeId).getname();   
                if(String.isNotBlank(accdel.ParentId) && String.isNotBlank(accdel.Motorola_Customer_Number__c)&& recordtypename.equalsignorecase('Motorola Customer Number')){ 
                    DelParentIdset.add(accdel.ParentId);
                }
            }
            if(DelParentIdset != null && DelParentIdset.size() >0){
                Map<Id,Account> DelParentRecords = new Map<Id,Account>([select Id,MCN_Account_Number__c,Primary_Route_to_Market__c from Account where id in: DelParentIdset AND  RecordType.name in('Customer','Prospect')]);
                if(DelParentRecords.size() >0){
                    for(Account chilac :Accountlist){
                        system.debug('parentIdSet'+chilac.parentId);
                        if(DelParentRecords.size() > 0 && DelParentRecords.containsKey(chilac.parentId) && DelParentRecords.get(chilac.ParentId).MCN_Account_Number__c != null){                             
                            if(String.isBlank(chilac.Primary_Route_to_Market__c)){
                                
                                DelParentRecords.get(chilac.ParentId).MCN_Account_Number__c=DelParentRecords.get(chilac.ParentId).MCN_Account_Number__c.remove(chilac.Motorola_Customer_Number__c+ ' ' +'('+ 'Active'+')');                                    
                                DelParentRecords.get(chilac.ParentId).MCN_Account_Number__c=DelParentRecords.get(chilac.ParentId).MCN_Account_Number__c.remove(chilac.Motorola_Customer_Number__c + ' ' +'('+ 'Inactive'+')'); 
                                
                            }
                            else{
                                DelParentRecords.get(chilac.ParentId).MCN_Account_Number__c=DelParentRecords.get(chilac.ParentId).MCN_Account_Number__c.remove(chilac.Motorola_Customer_Number__c+ ' ' +'('+ 'Active'+')' + ' '+ '|' + ' '+ Chilac.Primary_Route_to_Market__c);                                    
                                DelParentRecords.get(chilac.ParentId).MCN_Account_Number__c=DelParentRecords.get(chilac.ParentId).MCN_Account_Number__c.remove(chilac.Motorola_Customer_Number__c + ' ' +'('+ 'Inactive'+')'+ ' '+ '|' + ' '+Chilac.Primary_Route_to_Market__c);  
                                
                            }                            
                            // remove blank values //
                            if(String.isNotBlank(DelParentRecords.get(chilac.ParentId).MCN_Account_Number__c)) {
                                List<String> RemoveBreaktag=DelParentRecords.get(chilac.ParentId).MCN_Account_Number__c.split('\n');
                                DelParentRecords.get(chilac.ParentId).MCN_Account_Number__c='';
                                if(RemoveBreaktag.size()>0){
                                    for(String rem: RemoveBreaktag){
                                        // acp.MCN_Account_Number__c='';
                                        if(!string.isblank(rem))
                                        {
                                            if(String.isBlank(DelParentRecords.get(chilac.ParentId).MCN_Account_Number__c))
                                            {
                                                DelParentRecords.get(chilac.ParentId).MCN_Account_Number__c=rem;
                                                
                                            }
                                            else{
                                                DelParentRecords.get(chilac.ParentId).MCN_Account_Number__c=DelParentRecords.get(chilac.ParentId).MCN_Account_Number__c+'\n'+ rem;
                                            }
                                        }
                                    }  
                                } 
                            }
                        }
                        
                    }               
                    if(DelParentRecords.values().size() > 0)
                        update DelParentRecords.values();  
                }
            }
        }
        catch(Exception e){ 
            system.debug('Delete Method is Failed =====>'+e.getMessage());
            
        }   
        
        
    }  
    
    @future
    public static void onMergeAccount(List<String> Mergeacclist){ 
        try{  
            system.debug('Mergeacclist======>'+Mergeacclist); 
            string MergeAccountValue='';
            list<Account>Mergeaclist=new list<Account>();
            list<Account>aclist=new list<Account>();
            Map<String,String> accMergeMap=new Map<String,String>();
            if(Mergeacclist.size()>0){
                aclist=[select id,Motorola_Customer_Number__c,ERP_Active__c,Primary_Route_to_Market__c,MasterRecordId,parentid from Account where parentid in: Mergeacclist AND Motorola_Customer_Number__c <> null];
                system.debug('aclistSize = '+aclist.size());
                system.debug('aclistValues = '+aclist);
                if(aclist.size() >0){   
                    for(Account ac:aclist){
                        string ERPActive='';
                        if(ac.ERP_Active__c)
                            ERPActive='Active';
                        else
                            ERPActive='Inactive';
                        if(String.isBlank(ac.Primary_Route_to_Market__c)){
                            if(String.IsBlank(MergeAccountValue)) 
                                MergeAccountValue=ac.Motorola_Customer_Number__c+' '+'('+ERPActive+')';
                            else
                                MergeAccountValue=MergeAccountValue+'\n'+ac.Motorola_Customer_Number__c+' '+'('+ERPActive+')';              
                        }
                        else{
                            if(String.IsBlank(MergeAccountValue))
                                MergeAccountValue=ac.Motorola_Customer_Number__c+' '+'('+ERPActive+')'+' '+'|'+' '+ac.Primary_Route_to_Market__c; 
                            else
                                MergeAccountValue=MergeAccountValue+'\n'+ac.Motorola_Customer_Number__c+' '+'('+ERPActive+')'+' '+'|'+' '+ac.Primary_Route_to_Market__c; 
                            
                        }
                    }
                }
                system.debug('motCustNoSaveValue '+MergeAccountValue);
                list<Account> winnerAccMerge=new list<Account>();
                winnerAccMerge= [select id,MCN_Account_Number__c from Account where id in:Mergeacclist];
                if(winnerAccMerge.size()>0){
                    for (account wi: winnerAccMerge){
                        wi.MCN_Account_Number__c=MergeAccountValue;
                        Mergeaclist.add(wi);
                    }
                    if(Mergeaclist.size()>0){
                        futurecalloutflag=true;
                        update Mergeaclist;
                        system.debug('futurecalloutflag--->'+futurecalloutflag);
                    }
                    
                }
                system.debug('MergeaclistValue '+Mergeaclist);
            }
        }
        catch(Exception e) {  
            system.debug('Merge Method is Failed =====>'+e.getMessage());
        }
    }                                                    
}