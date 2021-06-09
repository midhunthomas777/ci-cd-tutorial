public class AddendumTriggerHandler implements ITriggerHandler{
    public static Boolean TriggerDisabled = false;
    
    public void BeforeInsert(List<SObject> newItems) { 
        List<Addendum__c> newAddendumList = new List<Addendum__c>();
        if(newItems != null) newAddendumList = (List<Addendum__c>) newItems;
        validateAddendumRecord(newAddendumList,null);
    }
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id, Addendum__c> newAddendumMap = new Map<Id, Addendum__c>();
        Map<Id, Addendum__c> oldAddendumMap = new Map<Id, Addendum__c>();
        if(newItems != null) newAddendumMap = (Map<Id, Addendum__c>) newItems;
        if(oldItems != null) oldAddendumMap = (Map<Id, Addendum__c>) oldItems;
        validateAddendumRecord(newAddendumMap.values(),oldAddendumMap);
        validateRejectedReason(newAddendumMap.values(),oldAddendumMap);
        Id changeRelnRecordTypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Addendum__c','Change_Relationship');
        List<User> partnerUsr = [SELECT Id , UserType FROM User WHERE Id =: UserInfo.getUserId() and UserType = 'PowerPartner' ];
        for(Addendum__c addendum : newAddendumMap.values()){
            Addendum__c oldAdd  = oldAddendumMap.get(addendum.Id);
            if(!partnerUsr.isEmpty() && oldAdd.Status__c !='Submitted' && oldAdd.Status__c !=null && addendum.RecordTypeId == changeRelnRecordTypeId){
                addendum.addError(System.Label.Resubmit_Approval);
            }
        }
    }
    
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id, Addendum__c> newAddendumMap = new Map<Id, Addendum__c>();
        Map<Id, Addendum__c> oldAddendumMap = new Map<Id, Addendum__c>();
        Map<String,Set<String>> programTechnologyMap=new Map<String,Set<String>>();
        if(newItems != null) newAddendumMap = (Map<Id, Addendum__c>) newItems;
        if(oldItems != null) oldAddendumMap = (Map<Id, Addendum__c>) oldItems;  
        Id changeReqAddendum = GlobalUtility.getRecordTypeIdByDeveloperName('Addendum__c', 'Change_Relationship');
        List<Technology_Specialization__c> lstProgramDetails = new List<Technology_Specialization__c> ();
        Map<Id,Id> mapPartnerAccPartnerType = new Map<Id,Id>();
        Map<String,Set<String>> addendumMap=new Map<String,Set<String>>();
        for(Addendum__c addendum : newAddendumMap.values()){
            mapPartnerAccPartnerType.put(addendum.Account__c, NULL);
        }
        for(Partner_Type__c progInfo : [SELECT Id,Account__c FROM Partner_Type__c WHERE Account__c IN : mapPartnerAccPartnerType.keySet()]){
            mapPartnerAccPartnerType.put(progInfo.Account__c,progInfo.Id);
        }
        if(!mapPartnerAccPartnerType.isEmpty()){
            List<Technology_Specialization__c> programList=[SELECT Account__c,Technology_Specialization__c,Community_Type__c FROM Technology_Specialization__c WHERE Account__c=:mapPartnerAccPartnerType.keySet()];
            if(programList.size()>0){
                for(Technology_Specialization__c tech:programList){
                    if(programTechnologyMap.containsKey(tech.Community_Type__c)){
                        List<String> seperateValues=new List<String>();
                        Set<String> techValues=programTechnologyMap.get(tech.Community_Type__c);
                        List<String> seperateTechSegment=new List<String>();
                        if(String.isNotBlank(tech.Technology_Specialization__c)){
                            seperateTechSegment=tech.Technology_Specialization__c.split(';');
                        }
                        seperateValues.addAll(seperateTechSegment);
                        programTechnologyMap.put(tech.Community_Type__c,new set<String>(seperateValues)); 
                    }else{
                        List<String> seperateValues=new List<String>();
                        List<String> seperateTechSegment=new List<String>();
                        if(String.isNotBlank(tech.Technology_Specialization__c)){
                            seperateTechSegment=tech.Technology_Specialization__c.split(';');
                        }
                        seperateValues.addAll(seperateTechSegment);
                        programTechnologyMap.put(tech.Community_Type__c,new set<String>(seperateValues));
                    }
                }
            }
        }
        for(Addendum__c addendum : newAddendumMap.values()){
            Set<String> programTechValues=new Set<String>();
            
            Addendum__c oldAddendum = oldAddendumMap.get(addendum.Id); 
            if(addendum.Status__c != oldAddendum.Status__c && addendum.Status__c == 'Signed' && addendum.RecordTypeId == changeReqAddendum && addendum.Application__c == NULL ){
                if(!programTechnologyMap.isEmpty()){
                    programTechValues =programTechnologyMap.get(addendum.Partner_Community_Type__c);
                }
                if(addendumMap.containsKey(addendum.Partner_Community_Type__c)){
                    List<String> seperateValues=new List<String>();
                    Set<String> techValues=addendumMap.get(addendum.Partner_Community_Type__c);
                    List<String> seperateTechSegment=new List<String>();
                    if(String.isNotBlank(addendum.Technology_Segment__c)){
                        seperateTechSegment=addendum.Technology_Segment__c.split(';');
                    }
                    seperateValues.addAll(seperateTechSegment);
                    addendumMap.put(addendum.Partner_Community_Type__c,new set<String>(seperateValues)); 
                }else{
                    List<String> seperateValues=new List<String>();
                    List<String> seperateTechSegment=new List<String>();
                    if(String.isNotBlank(addendum.Technology_Segment__c)){
                        seperateTechSegment=addendum.Technology_Segment__c.split(';');
                    }
                    seperateValues.addAll(seperateTechSegment);
                    addendumMap.put(addendum.Partner_Community_Type__c,new set<String>(seperateValues));
                }
            }
            
            if(!addendumMap.isEmpty()){
                for(String addendumKey:addendumMap.keyset()){
                    for(String techValue:addendumMap.get(addendumKey)){
                        Technology_Specialization__c programDetail = new Technology_Specialization__c(Account__c = addendum.Account__c,
                                                                                                      Partner_Program__c = mapPartnerAccPartnerType.get(addendum.Account__c),
                                                                                                      Community_Type__c = addendumKey,
                                                                                                      Technology_Specialization__c =techValue,
                                                                                                      TechnologySubSegment__c = addendum.Technology_Sub_Segment__c
                                                                                                     );
                        if(addendum.Partner_Region__c ==  'NA'){
                            programDetail.Technology_Specialization_Level__c = 'Authorized';
                        } else{
                            programDetail.Technology_Specialization_Level__c = NULL;
                        }
                        
                        if(techValue.Contains('Application Partner')){
                            programDetail.Type__c = 'Application';
                        } else if(techValue.Contains('Service Partner')){
                            programDetail.Type__c = 'Service Delivery';
                        } else{
                            programDetail.Type__c = 'Technology';
                        }
                        if(programTechValues!=NULL){
                            if(!programTechValues.contains(techValue)){
                                lstProgramDetails.add(programDetail); 
                            }
                        }else{
                            lstProgramDetails.add(programDetail);  
                        }
                    }
                }
            }
        }
        updateAddendumToApplication(newAddendumMap.values(),oldAddendumMap); 
        if(!lstProgramDetails.isEmpty()){
            insert lstProgramDetails;
        }
    }
    
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
    public void afterInsert(Map<Id, SObject> newItems) {
        Map<Id, Addendum__c> newAddendumMap = new Map<Id, Addendum__c>();
        if(newItems != null) newAddendumMap = (Map<Id, Addendum__c>) newItems;
        
        updateAddendumToApplication(newAddendumMap.values(),null);
        
    }
    public void afterDelete(Map<Id, SObject> oldItems) {
        Map<Id, Addendum__c> oldAddendumMap = new Map<Id, Addendum__c>();
        if(oldItems != null) oldAddendumMap = (Map<Id, Addendum__c>) oldItems;  
        deleteAddendumValues(null,oldAddendumMap);  
    }
    public void afterUndelete(Map<Id, SObject> oldItems){}
    public void validateAddendumRecord(List<Addendum__c> newAddendumList,Map<Id,Addendum__c> oldAddendumMap){
        Id changeReqAddendum = GlobalUtility.getRecordTypeIdByDeveloperName('Addendum__c', 'Change_Relationship');
        List<String> finalTechList=new List<String>();
        List<String> fetchCommunityList=new List<String>();
        Set<String> newTechValues=new Set<String>();
        Set<String> allTechValues=new Set<String>();
        Map<String,List<Addendum__c>> existingAddendumMap=new Map<String,List<Addendum__c>>();
        Map<String,List<Addendum__c>> existingAddendumMapAccount=new Map<String,List<Addendum__c>>();
        Map<String,Map<String,Set<String>>> programTechMap=new Map<String,Map<String,Set<String>>>();
        Map<String,List<String>> newAddendumMap=new Map<String,List<String>>();
        Map<String,String> newMap=new Map<String,String>();
        Set<String> communityValues=new Set<String>();
        Set<String> technologyValues=new Set<String>();
        Set<String> techSubSegmentValues=new Set<String>(); 
        Set<String> communityValuesAccount=new Set<String>();
        Set<String> technologyValuesAccount=new Set<String>();
        Set<String> techSubSegmentValuesAccount=new Set<String>();
        List<String> communityList=new List<String>();
        Set<Id> applicationIds=new Set<Id>();
        Set<Id> accountIds=new Set<Id>();
        Map<String,Empower_Application__c> empowerMap=new Map<String,Empower_Application__c>();
        
        for(Addendum__c addendum:newAddendumList){
            if(addendum.Technology_Segment__c!=NULL){
                List<String> addendumValues=addendum.Technology_Segment__c.split(';');
                newTechValues=new Set<String>(addendumValues); 
            }
            
            applicationIds.add(addendum.Application__c); 
            accountIds.add(addendum.Account__c);
            String partnerType=UserInfo.getUserType();
            if((addendum.Authorized_to_Sign_Legal_Agreement__c=='Yes' && partnerType=='PowerPartner' && String.isNotBlank(addendum.Authorized_to_Sign_Legal_Agreement__c)) || Test.isRunningTest()){
                addendum.Company_Signature_Authority_First_Name__c=UserInfo.getFirstName();
                addendum.Company_Signature_Authority_Last_Name__c=UserInfo.getLastName();
                addendum.Company_Signature_Authority_Email__c=UserInfo.getUserEmail();
            }
            
        }
        
        if(!applicationIds.isEmpty() || !accountIds.isEmpty()){
            for(Empower_Application__c empower:[SELECT Company_Signature_Authority_Email__c,Company_Signature_Authority_First_Name__c,Company_Signature_Authority_Last_Name__c FROM Empower_Application__c WHERE Id IN:applicationIds]){
                empowerMap.put(empower.Id,empower);
            }
            List<Addendum__c> addendumList=[SELECT RecordTypeId,Partner_Region__c,Partner_Applicant_Email_Address__c,Partner_Community_Type__c,Application__r.Applicant_Email_Address__c,Application__c,Account__c,Status__c,Technology_Segment__c,Technology_Sub_Segment__c FROM Addendum__c WHERE ((Application__c=:applicationIds AND Application__c!=NULL) OR (Account__c=:accountIds AND Account__c!=NULL)) LIMIT 100];
            system.debug('test list-->'+addendumList);
            List<Technology_Specialization__c> programList=[SELECT Account__c,Community_Type__c,Technology_Specialization__c,TechnologySubSegment__c FROM Technology_Specialization__c WHERE Account__c=:accountIds];
            system.debug('test programList-->'+programList);
            if(!programList.isEmpty()){
                for(Technology_Specialization__c program:programList){
                    if(programTechMap.containsKey(program.Account__c)){
                        Map<String,Set<String>> programTechList=programTechMap.get(program.Account__c);
                        if(programTechList.containsKey(program.Community_Type__c)){
                            Set<String> techList=programTechList.get(program.Community_Type__c);
                            List<String> allValues=new List<String>();
                            if(String.isNotBlank(program.Technology_Specialization__c)){
                                allValues=program.Technology_Specialization__c.split(';');
                            }
                            techList.addAll(allValues);
                            Set<String> techValues=new Set<String>(techList);
                            system.debug('test all values-->'+techValues);
                            programTechList.put(program.Community_Type__c,techValues); 
                        }else{
                            programTechList.put(program.Community_Type__c,new Set<String>{program.Technology_Specialization__c});
                        }
                        programTechMap.put(program.Account__c,programTechList); 
                    }else{
                        Map<String,Set<String>> programTestMap=new Map<String,Set<String>>();
                        List<String> allValues=new List<String>();
                        if(programTestMap.containsKey(program.Community_Type__c)){
                            Set<String> programTechList=programTestMap.get(program.Community_Type__c);
                            if(String.isNotBlank(program.Technology_Specialization__c)){
                                allValues=program.Technology_Specialization__c.split(';');
                            }
                            programTechList.addAll(allValues);
                            Set<String> techValues=new Set<String>(programTechList);
                            programTestMap.put(program.Community_Type__c,techValues); 
                        }else{
                            programTestMap.put(program.Community_Type__c,new set<String>{program.Technology_Specialization__c});
                        }
                        programTechMap.put(program.Account__c,programTestMap); 
                    }
                }
                
            }
            system.debug('test map of map-->'+programTechMap);
            
            if(!addendumList.isEmpty()){
                for(Addendum__c adm:addendumList){
                    if(String.isNotBlank(adm.Application__c)){
                    newMap.put(adm.Id,adm.Application__r.Applicant_Email_Address__c);
                    }
                    
                    if(adm.Status__c=='Accepted'){
                        if(String.isNotBlank(adm.Application__c)){
                            if(existingAddendumMap.containsKey(adm.Application__c)){
                                List<Addendum__c> addList=existingAddendumMap.get(adm.Application__c);
                                addList.add(adm);
                                existingAddendumMap.put(adm.Application__c,addList);
                            }else{
                                existingAddendumMap.put(adm.Application__c,new List<Addendum__c>{adm}); 
                            }
                        }
                        if(String.isNotBlank(adm.Account__c) && adm.recordTypeId==changeReqAddendum && String.isBlank(adm.Application__c)){
                            system.debug('inside--');
                            if(existingAddendumMapAccount.containsKey(adm.Account__c)){
                                List<Addendum__c> relatedData=existingAddendumMapAccount.get(adm.Account__c);
                                relatedData.add(adm);
                                existingAddendumMapAccount.put(adm.Account__c,relatedData); 
                            }else{
                                existingAddendumMapAccount.put(adm.Account__c,new List<Addendum__c>{adm}); 
                            }
                            
                        }
                    }
                   /* system.debug('inside if');
                    if(String.isNotBlank(adm.Account__c) && adm.recordTypeId==changeReqAddendum && String.isBlank(adm.Application__c)){
                        Set<String> techList=new Set<String>();
                        system.debug('inside map-->'+programTechMap);
                        if(!programTechMap.isEmpty()){
                            if(programTechMap.get(adm.Account__c).get(adm.Partner_Community_Type__c)!=NULL && programTechMap.containsKey(adm.Account__c)){
                                techList=programTechMap.get(adm.Account__c).get(adm.Partner_Community_Type__c);
                            }
                            if(!techList.isEmpty()){
                                finalTechList.addAll(techList);
                            }
                            system.debug('why'+finalTechList);
                        }
                    }*/
                } 
            }
                 
                for(Addendum__c adm:newAddendumList){
                    if(String.isNotBlank(adm.Account__c) && adm.recordTypeId==changeReqAddendum && String.isBlank(adm.Application__c)){
                        Set<String> techList=new Set<String>();
                        Set<String> partnerCommunityList=new Set<String>();
                        if(!programTechMap.isEmpty()){
                            if(programTechMap.get(adm.Account__c).get(adm.Partner_Community_Type__c)!=NULL && programTechMap.containsKey(adm.Account__c)){
                                techList=programTechMap.get(adm.Account__c).get(adm.Partner_Community_Type__c);
                                partnerCommunityList=programTechMap.get(adm.Account__c).keyset();
                            }
                            if(!techList.isEmpty()){
                                finalTechList.addAll(techList);
                                fetchCommunityList.addAll(partnerCommunityList);
                            }
                        }
                    }
                }
        }
        if(!finalTechList.isEmpty()){
            allTechValues=new Set<String>(finalTechList);
        }
        Set<String> allCommunityValues=new Set<String>();
        if(!fetchCommunityList.isEmpty()){
            allCommunityValues=new Set<String>(fetchCommunityList);
        }
        system.debug('all vvv->'+allTechValues);
        if(!existingAddendumMap.isEmpty()){
            for(List<Addendum__c> outerValue:existingAddendumMap.values()){
                for(Addendum__c innerValue:outerValue){
                    communityValues.add(innerValue.Partner_Community_Type__c);  
                    technologyValues.add(innerValue.Technology_Segment__c);
                    techSubSegmentValues.add(innerValue.Technology_Sub_Segment__c);
                    system.debug('commiunity values addendum-->'+communityValues);
                    
                }   
            }
        }
        if(!existingAddendumMapAccount.isEmpty()){
            for(List<Addendum__c> outerValue:existingAddendumMapAccount.values()){
                for(Addendum__c innerValue:outerValue){
                    communityValuesAccount.add(innerValue.Partner_Community_Type__c);                
                    technologyValuesAccount.add(innerValue.Technology_Segment__c);
                    techSubSegmentValuesAccount.add(innerValue.Technology_Sub_Segment__c);
                    system.debug('commiunity values-->'+communityValuesAccount);
                    system.debug('tse-->'+existingAddendumMapAccount);
                }   
            }
        }
        
        for(Addendum__c addendum:newAddendumList){
            if(!newMap.isEmpty()){
            addendum.Partner_Applicant_Email_Address__c=newMap.get(addendum.Id);
            }
            if(!empowerMap.isEmpty()){
                if(String.isBlank(addendum.Company_Signature_Authority_Email__c) || Test.isRunningTest()){
                    addendum.Company_Signature_Authority_Email__c=empowerMap.get(addendum.Application__c).Company_Signature_Authority_Email__c;
                }
                if(String.isBlank(addendum.Company_Signature_Authority_First_Name__c) || Test.isRunningTest()){
                    addendum.Company_Signature_Authority_First_Name__c=empowerMap.get(addendum.Application__c).Company_Signature_Authority_First_Name__c;
                }
                if(String.isBlank(addendum.Company_Signature_Authority_Last_Name__c) || Test.isRunningTest()){
                    addendum.Company_Signature_Authority_Last_Name__c=empowerMap.get(addendum.Application__c).Company_Signature_Authority_Last_Name__c;
                }
            }
            
            if(addendum.Partner_Region__c=='NA' || addendum.Partner_Region__c=='LA'){
                system.debug('test partner region-->'+addendum.Partner_Region__c);
                system.debug('test partner comm type-->'+addendum.Partner_Community_Type__c);
                system.debug('test partner account-->'+addendum.Account__c);
                system.debug('commvalues '+communityValues);
                system.debug('allcomvalues '+allCommunityValues);
                system.debug('programTechMap '+programTechMap);
                set<String> techVal = new set<String>();
                if(string.isNotBlank(addendum.Account__c) && string.isNotBlank(addendum.Partner_Community_Type__c) && !programTechMap.isEmpty()){
                	techVal =programTechMap.get(addendum.Account__c).get(addendum.Partner_Community_Type__c);
                    system.debug('techval inside '+techVal);
                }
                system.debug('techVal '+techVal);
                //if((Trigger.isInsert && String.isNotBlank(addendum.Partner_Community_Type__c) &&
                    //communityValues.contains(addendum.Partner_Community_Type__c) && !communityValues.isEmpty()) || (Trigger.isInsert && String.isNotBlank(addendum.Partner_Community_Type__c) &&
                    //allCommunityValues.contains(addendum.Partner_Community_Type__c) && !allCommunityValues.isEmpty())){
                if((Trigger.isInsert && String.isNotBlank(addendum.Partner_Community_Type__c) &&
                    communityValues.contains(addendum.Partner_Community_Type__c) && !communityValues.isEmpty()) || (Trigger.isInsert && String.isNotBlank(addendum.Partner_Community_Type__c) && String.isNotBlank(addendum.Technology_Segment__c) &&
                    (techVal!= null && techVal.contains(addendum.Technology_Segment__c)))){       
                      addendum.Partner_Community_Type__c.addError('This Community Type is already approved.');
                       } else if((Trigger.isUpdate && String.isNotBlank(addendum.Partner_Community_Type__c) && communityValues.contains(addendum.Partner_Community_Type__c) && oldAddendumMap.get(addendum.Id).Partner_Community_Type__c!=addendum.Partner_Community_Type__c && !communityValues.isEmpty()) || 
                          (Trigger.isUpdate && String.isNotBlank(addendum.Partner_Community_Type__c)  && oldAddendumMap.get(addendum.Id).Partner_Community_Type__c!=addendum.Partner_Community_Type__c &&  String.isNotBlank(addendum.Technology_Segment__c) && (techVal!= null && techVal.contains(addendum.Technology_Segment__c)) )  ){
                           addendum.Partner_Community_Type__c.addError('This Community Type is already approved.');
                      } 
               /* if((Trigger.isInsert && !String.isBlank(addendum.Technology_Segment__c) && technologyValues.contains(addendum.Technology_Segment__c) && !technologyValues.isEmpty())
                   || (Trigger.isInsert && !String.isBlank(addendum.Technology_Segment__c) && technologyValuesAccount.contains(addendum.Technology_Segment__c) && !technologyValuesAccount.isEmpty())
                  ){
                      addendum.Technology_Segment__c.addError('This Technology Segment is already approved.');
                  } else if((Trigger.isUpdate && !String.isBlank(addendum.Technology_Segment__c) && technologyValues.contains(addendum.Technology_Segment__c) && !technologyValues.isEmpty() && oldAddendumMap.get(addendum.Id).Technology_Segment__c!=addendum.Technology_Segment__c)
                            || (Trigger.isUpdate && !String.isBlank(addendum.Technology_Segment__c) && technologyValuesAccount.contains(addendum.Technology_Segment__c) && !technologyValuesAccount.isEmpty() && oldAddendumMap.get(addendum.Id).Technology_Segment__c!=addendum.Technology_Segment__c)
                           ){
                               addendum.Technology_Segment__c.addError('This Technology Segment is already approved.');
                           }*/
                if((Trigger.isInsert && !String.isBlank(addendum.Technology_Sub_Segment__c) && techSubSegmentValues.contains(addendum.Technology_Sub_Segment__c) && !techSubSegmentValues.isEmpty())
                   || (Trigger.isInsert && !String.isBlank(addendum.Technology_Sub_Segment__c) && techSubSegmentValuesAccount.contains(addendum.Technology_Sub_Segment__c) && !techSubSegmentValuesAccount.isEmpty())){
                       addendum.Technology_Sub_Segment__c.addError(system.label.POAddendumTechSegment);
                   } else if((Trigger.isUpdate && !String.isBlank(addendum.Technology_Sub_Segment__c) && techSubSegmentValues.contains(addendum.Technology_Sub_Segment__c) && oldAddendumMap.get(addendum.Id).Technology_Sub_Segment__c!=addendum.Technology_Sub_Segment__c && !techSubSegmentValues.isEmpty())
                             || (Trigger.isUpdate && !String.isBlank(addendum.Technology_Sub_Segment__c) && techSubSegmentValuesAccount.contains(addendum.Technology_Sub_Segment__c) && oldAddendumMap.get(addendum.Id).Technology_Sub_Segment__c!=addendum.Technology_Sub_Segment__c && !techSubSegmentValuesAccount.isEmpty())){
                                 addendum.Technology_Sub_Segment__c.addError(system.label.POAddendumTechSegment); 
                             }
            }
            //if(addendum.Partner_Region__c=='APAC' || addendum.Partner_Region__c=='EMEA'){
                if(!newTechValues.isEmpty()){
                    system.debug('test last-->'+newTechValues);
                    for(String tech:newTechValues){
                        if((Trigger.isInsert && !String.isBlank(addendum.Technology_Segment__c) && technologyValues.contains(addendum.Technology_Segment__c) && !technologyValues.isEmpty())
                           || (Trigger.isInsert && !String.isBlank(addendum.Technology_Segment__c) && technologyValuesAccount.contains(addendum.Technology_Segment__c) && !technologyValuesAccount.isEmpty())
                           || (Trigger.isInsert && String.isNotBlank(tech) && allTechValues.contains(tech) && !allTechValues.isEmpty())){
                                system.debug('error-->'+allTechValues);
                               addendum.Technology_Segment__c.addError(system.label.POAddendumTechSegment);
                           } else if((Trigger.isUpdate && !String.isBlank(addendum.Technology_Segment__c) && technologyValues.contains(addendum.Technology_Segment__c) && !technologyValues.isEmpty() && oldAddendumMap.get(addendum.Id).Technology_Segment__c!=addendum.Technology_Segment__c)
                                     || (Trigger.isUpdate && !String.isBlank(addendum.Technology_Segment__c) && technologyValuesAccount.contains(addendum.Technology_Segment__c) && !technologyValuesAccount.isEmpty() && oldAddendumMap.get(addendum.Id).Technology_Segment__c!=addendum.Technology_Segment__c)
                                     || (Trigger.isUpdate && String.isNotBlank(tech) && allTechValues.contains(tech) && !allTechValues.isEmpty())){
                                         addendum.Technology_Segment__c.addError(system.label.POAddendumTechSegment);
                                     }
                    }
                }
            //}
            
        }
    } 
    
    public void updateAddendumToApplication(List<Addendum__c> newAddendumList,Map<Id,Addendum__c> oldAddendumMap){ 
        Set<String> allCommValues=new set<String>();
        Set<String> allTechValues=new set<String>();
        Set<String> allTechSubValues=new set<String>();
        Map<String,List<Addendum__c>> existingAddendumMap=new Map<String,List<Addendum__c>>();
        List<Empower_Application__c> addendumListToUpdate=new List<Empower_Application__c>();
        Set<Id> applicationIds=new Set<Id>();
        Recursionblocker.flag=false;
        for(Addendum__c addendum:newAddendumList){
            if(addendum.Status__c == 'Accepted' && String.isNotBlank(addendum.Application__c)){
                applicationIds.add(addendum.Application__c);
            }
        }
        if(!applicationIds.isEmpty()){
            for(Addendum__c adm:[SELECT Partner_Community_Type__c,Application__c,Status__c,Technology_Segment__c,Technology_Sub_Segment__c FROM Addendum__c WHERE Application__c=:applicationIds AND Status__c='Accepted' LIMIT 49999]){
                if(existingAddendumMap.containsKey(adm.Application__c)){
                    List<Addendum__c> addList=existingAddendumMap.get(adm.Application__c);
                    addList.add(adm);
                    existingAddendumMap.put(adm.Application__c,addList);
                }else{
                    existingAddendumMap.put(adm.Application__c,new List<Addendum__c>{adm}); 
                }
            } 
        } 
        if(!existingAddendumMap.isEmpty()){
            for(List<Addendum__c> outerValue:existingAddendumMap.values()){
                for(Addendum__c innerValue:outerValue){
                    List<String> techSubVal=new List<String>();
                    List<String> techVal=new List<String>();
                    List<String> communityVal=new List<String>();
                    if(String.isNotBlank(innerValue.Partner_Community_Type__c)){
                        communityVal=innerValue.Partner_Community_Type__c.split(';');
                    }
                    if(String.isNotBlank(innerValue.Technology_Segment__c)){
                        techVal=innerValue.Technology_Segment__c.split(';');
                    }
                    if(String.isNotBlank(innerValue.Technology_Sub_Segment__c)){
                        techSubVal=innerValue.Technology_Sub_Segment__c.split(';');
                    }
                    if(!communityVal.isEmpty()){
                        for(String comm:communityVal){
                            allCommValues.add(comm); 
                        }
                    }
                    if(!techVal.isEmpty()){
                        for(String tech:techVal){
                            allTechValues.add(tech); 
                        }
                    }
                    if(!techSubVal.isEmpty()){
                        for(String techSub:techSubVal){
                            allTechSubValues.add(techSub); 
                        }
                    }
                }            
            }
            
            for(Empower_Application__c empower:[SELECT Approved_Partner_Community_Type__c,Approved_Partner_Technology_Segment__c,Approved_Partner_Technology_Sub_Segment__c FROM Empower_Application__c WHERE Id=:existingAddendumMap.keySet() LIMIT 49999]){                
                empower.Approved_Partner_Community_Type__c=String.join(new List<String>(allCommValues),';');
                empower.Approved_Partner_Technology_Segment__c=String.join(new List<String>(allTechValues),';');
                empower.Approved_Partner_Technology_Sub_Segment__c=String.join(new List<String>(allTechSubValues),';');
                addendumListToUpdate.add(empower);           
            }
        }
        if(!addendumListToUpdate.isEmpty()){
            update addendumListToUpdate;
        }
    }
    public void deleteAddendumValues(List<Addendum__c> newAddendumList,Map<Id,Addendum__c> oldAddendumMap){ 
        Map<String,List<Addendum__c>> existingAddendumMap=new Map<String,List<Addendum__c>>();  
        Set<String> communityValues=new Set<String>();
        Set<String> technologyValues=new Set<String>();
        Set<String> techSubSegmentValues=new Set<String>();
        Set<Id> applicationIds=new Set<Id>(); 
        List<Empower_Application__c> addendumListToUpdate=new List<Empower_Application__c>();
        
        for(Addendum__c addendum : oldAddendumMap.values()){
            applicationIds.add(addendum.Application__c); 
        }
        for(Addendum__c adm : [SELECT Partner_Community_Type__c,Application__c,Status__c,Technology_Segment__c,Technology_Sub_Segment__c FROM Addendum__c WHERE (Application__c=:applicationIds AND Status__c='Accepted') LIMIT 10]){
            if(existingAddendumMap.containsKey(adm.Application__c)){
                List<Addendum__c> addList=existingAddendumMap.get(adm.Application__c);
                addList.add(adm);
                existingAddendumMap.put(adm.Application__c,addList);
            }else{
                existingAddendumMap.put(adm.Application__c,new List<Addendum__c>{adm}); 
            }
        } 
        if(!existingAddendumMap.isEmpty()){
            for(List<Addendum__c> outerValue:existingAddendumMap.values()){
                for(Addendum__c innerValue:outerValue){
                    communityValues.add(innerValue.Partner_Community_Type__c);                
                    technologyValues.add(innerValue.Technology_Segment__c);
                    techSubSegmentValues.add(innerValue.Technology_Sub_Segment__c);
                }   
            }
        }
        for(Empower_Application__c empower:[SELECT Approved_Partner_Community_Type__c,Approved_Partner_Technology_Segment__c,Approved_Partner_Technology_Sub_Segment__c FROM Empower_Application__c WHERE Id=:applicationIds LIMIT 10]){                
            if(communityValues.size()>0){
                empower.Approved_Partner_Community_Type__c=String.join(new List<String>(communityValues),';');
            }else{
                empower.Approved_Partner_Community_Type__c=null;
            }
            if(technologyValues.size()>0){
                empower.Approved_Partner_Technology_Segment__c=String.join(new List<String>(technologyValues),';');
            }else{
                empower.Approved_Partner_Technology_Segment__c=null;  
            }
            if(techSubSegmentValues.size()>0){
                empower.Approved_Partner_Technology_Sub_Segment__c=String.join(new List<String>(techSubSegmentValues),';');
            }else{
                empower.Approved_Partner_Technology_Sub_Segment__c=null;  
            }
            addendumListToUpdate.add(empower);           
        }
        system.debug('test in-->'+addendumListToUpdate);
        if(!addendumListToUpdate.isEmpty()){
            update addendumListToUpdate;
        }
    }
    
     public void validateRejectedReason(List<Addendum__c> lstNewAdd,Map<Id,Addendum__c> oldItems){
        Map<Id, Addendum__c> mapRejectedStatements = new Map<Id, Addendum__c>{};
            for(Addendum__c newAddm:lstNewAdd){
                Addendum__c olddd = (Addendum__c)oldItems.get(newAddm.Id);
                if (olddd.Status__c != 'Denied' && newAddm.Status__c == 'Denied')
                { 
                    mapRejectedStatements.put(newAddm.Id, newAddm);  
                }
            }
       if (!mapRejectedStatements.isEmpty()){
           GlobalUtility.approvalProcessRejectionCmtsMandatory(mapRejectedStatements);
       }
     }
    
    public Boolean isDisabled(){ 
        if (TriggerSettings__c.getValues('AddendumTriggerDisabled').IsActive__c){
            return true;
        } else{
            return TriggerDisabled;
        }
    }
}