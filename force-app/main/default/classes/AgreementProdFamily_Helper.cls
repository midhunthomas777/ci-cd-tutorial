/**
Version        Author                Description
Initial        Sai Harish            Update a Mature Products(New Field),Devices,Systems,SPSS,M&SS fields on Agreement 
based on Product Families of Opportunity

1. Helper for "AgreeProdFamily"  trigger
2. trigger UpdateAgreement on OpportunityLineItem
TEST CLASS: PresaleController_Test                                     
**/



Public class AgreementProdFamily_Helper
{ 
    public void updateAgreements(Map<Id,List<Apttus__APTS_Agreement__c>> TempMap)
    {
        
        Map<Id,String> OppMatuProd_org = ProcessOLIS(TempMap.keyset());
        
        System.Debug('OppMatuProd_org ####'+OppMatuProd_org);
        
        List<Apttus__APTS_Agreement__c> AgreeLst_Upd=new List<Apttus__APTS_Agreement__c>();
        
        for(Id TempId:TempMap.keyset()){
            for(Apttus__APTS_Agreement__c AGlst:TempMap.get(TempId)){
                
                System.Debug('OppMatuProd_org.get(TempId)###'+OppMatuProd_org.get(TempId));
                
                
                if(OppMatuProd_org.get(TempId)==null || OppMatuProd_org.get(TempId)==''){
                    AGlst.Mature_Products__c =false;
                    AGlst.Enterprise_Solutions__c=false;
                    AGlst.Radio_Solutions_iDEN__c=false;
                    AGlst.Global_Services__c=false;
                    AGlst.SPSS__c=false;
                } else {
                    if(OppMatuProd_org.get(TempId).contains('Mature:true'))
                    {
                        System.Debug('HARISH ENTERED MATURE TRUE');
                        AGlst.Mature_Products__c =true;
                    }
                    else
                    {
                        System.Debug('HARISH ENTERED MATURE FALSE');
                        AGlst.Mature_Products__c =false;
                    }
                    
                    if(OppMatuProd_org.get(TempId).contains('Infrastructure'))
                    {
                        System.Debug('HARISH ENTERED INFRA TRUE');
                        AGlst.Enterprise_Solutions__c=true;
                    }
                    else
                    {
                        System.Debug('HARISH ENTERED INFRA FALSE');
                        AGlst.Enterprise_Solutions__c=false;
                    }
                    
                    if(OppMatuProd_org.get(TempId).contains('Devices'))
                    {
                        System.Debug('HARISH ENTERED DEVICES TRUE');
                        AGlst.Radio_Solutions_iDEN__c=true;
                    }
                    else
                    {
                        System.Debug('HARISH ENTERED Devices False');
                        AGlst.Radio_Solutions_iDEN__c=false;
                    }
                    
                    if(OppMatuProd_org.get(TempId).contains('Managed and Support Services'))
                    {
                        System.Debug('HARISH ENTERED MANAGE TRUE');
                        AGlst.Global_Services__c=true;
                    }
                    else
                    {
                        System.Debug('HARISH ENTERED MANAGE FALSE');
                        AGlst.Global_Services__c=false;
                    }
                    
                    if(OppMatuProd_org.get(TempId).contains('Smart Public Safety Solutions (SPSS)'))
                    {
                        System.Debug('HARISH ENTERED SPSS TRUE');
                        AGlst.SPSS__c=true;
                    }
                    else
                    {
                        System.Debug('HARISH ENTERED SPSS FALSE');
                        AGlst.SPSS__c=false;
                    }
                    
                }
                System.Debug('AGlst####'+AGlst);
                
                AgreeLst_Upd.add(AGlst);
            }
        }
        
        if(AgreeLst_Upd.size()>0)
            Update AgreeLst_Upd;
        
    }
    
    public Map<Id,String> ProcessOLIS(set<Id> OppIds)
    {
System.debug('OppIds####=>'+OppIds);        
        List<OpportunityLineItem> OLILst=[SELECT Id,OpportunityId ,PricebookEntry.Product2Id,PricebookEntry.Product2.Name,
                                          PricebookEntry.Product2.Agreement_Criteria__c,
                                          PricebookEntry.Product2.Mature_Technology__c,PricebookEntry.Product2.IsActive 
                                          FROM OpportunityLineItem WHERE 
                                          OpportunityId IN :OppIds];
        
        System.debug('OLILst####=>'+OLILst);
        Map<Id,String> OppMatuProd =new Map<Id,String>();
        for(OpportunityLineItem TempLI:OLILst){
            
            if(TempLI.PricebookEntry.Product2.Mature_Technology__c==false) // PricebookEntry.Product2.IsActive check with Rebecca
            {
                OppMatuProd.put( TempLI.OpportunityId,'Mature:false');
            }
            else
            {
                if(!OppMatuProd.keyset().contains(TempLI.OpportunityId))
                {
                    OppMatuProd.put( TempLI.OpportunityId,'Mature:true');    
                }
            }
            
        }
        
        
        for(OpportunityLineItem TempLI:OLILst)
        {
            
            String TempS=OppMatuProd.get(TempLI.OpportunityId);
            
            if(TempLI.PricebookEntry.Product2.Agreement_Criteria__c!=null && TempLI.PricebookEntry.Product2.Agreement_Criteria__c!='')
                OppMatuProd.put(TempLI.OpportunityId,TempLI.PricebookEntry.Product2.Agreement_Criteria__c+';'+TempS);
            
        }
        
        System.debug('OppMatuProd####=>'+OppMatuProd);
        return OppMatuProd;
    }
    
    public void UpdateAgreement_OLI(set<Id> OppIds)
    {
        System.debug('OppIds###=>'+OppIds);
        List<Apttus__APTS_Agreement__c> AgmLst= [Select Id,Name,Apttus__Related_Opportunity__c,Enterprise_Solutions__c,SPSS__c,
                                                 Related_Presales_Resource_Request__c,Radio_Solutions_iDEN__c,Mature_Products__c ,Global_Services__c,Related_Presales_Resource_Request__r.Opportunity__c
                                                 from Apttus__APTS_Agreement__c where (Related_Presales_Resource_Request__r.Opportunity__c IN :OppIds OR Apttus__Related_Opportunity__c IN:OppIds) 
                                                 and recordtype.name='Sales' AND (NOT Name like '%SNPSHOT%') AND Apttus__Status__c!='Previously Approved'];
        // Added by Vineela to bypass Snapshot and Approved Agreements
        System.debug('AgmLst###=>'+AgmLst);
        Map<Id,List<Apttus__APTS_Agreement__c>> TobeSent = new Map<Id,List<Apttus__APTS_Agreement__c>>();
        
        for(Apttus__APTS_Agreement__c AAG:AgmLst)
        {
            if(AAG.Apttus__Related_Opportunity__c!=null) 
            {
                if(!TobeSent .keyset().contains(AAG.Apttus__Related_Opportunity__c))
                {
                    TobeSent.put(AAG.Apttus__Related_Opportunity__c,new List<Apttus__APTS_Agreement__c>());
                }
                TobeSent.get(AAG.Apttus__Related_Opportunity__c).add(AAG);   
            }
            
        }
        
        if(TobeSent!=null) 
            UpdateAgreements(TobeSent);
        
    }  
    
}