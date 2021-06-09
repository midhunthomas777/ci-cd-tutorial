/*  
 * File Name  : AgreementCreateDispute_Extension
 * Description: This class creates a new Dispute Agreement record and sets the Parentid to the id of the
 *              current agreement
 * Author     : Subu Iyer
 * Modification Log 
 * ===========================================================================================================
 * Ver   Date         Author                         Modification 
 * -----------------------------------------------------------------------------------------------------------
 * 1.0   4/28/2014   Subu Iyer                      Initial Code
 */
public class AgreementCreateDispute_Extension
{        
    private final Apttus__APTS_Agreement__c agreement;        
    private ApexPages.StandardController stdController;    
    private ID agRecordTypeID = [select Id from RecordType where Name = 'Dispute' and SobjectType = 'Apttus__APTS_Agreement__c' Limit 1].id;
    
    public AgreementCreateDispute_Extension(ApexPages.StandardController controller) {
        stdController = controller;            
        agreement = (Apttus__APTS_Agreement__c) stdController.getRecord();  
    }    
    
  
    public PageReference createDisputeAgreement() {      
        System.debug('Inside Apex class');
        try{                    
            Apttus__APTS_Agreement__c childAgreement = new Apttus__APTS_Agreement__c(Name='Dispute',RecordTypeID=agRecordTypeID,Apttus__Parent_Agreement__c=agreement.id);
            insert childAgreement;  
            childAgreement.Related_Contract_Type__c='Procurement';
            update childAgreement;
            System.debug('After insert');
            //return new ApexPages.StandardController(childAgreement).edit();        
            return new PageReference('/'+childAgreement.id+'/e?retURL=/'+childAgreement.id);     
            } //end try
        catch (Exception e) { 
            agreement.adderror('There are errors in the Agreement record. Please correct them before proceeding further.');
            ApexPages.addmessages(e);    
            return ApexPages.currentPage();     
        } //end catch  
    }    
    
  }