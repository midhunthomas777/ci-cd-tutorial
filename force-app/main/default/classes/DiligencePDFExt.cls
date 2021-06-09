public class DiligencePDFExt {
    
    private Id appId;
        
        public DiligencePDFExt(ApexPages.StandardController c) {
            this.appId = (Id) c.getId();
            String todayDate = String.valueOf(date.today().year())+'_'+String.valueOf(date.today().month())+'_'+String.valueOf(date.today().day());
            String AgreName = Request.Name;
            AgreName = AgreName.replace(',','');
            String yourFileNameName = AgreName  + '_Original_Certificate of Due Diligence_'+ todayDate +'.pdf' ;
            Apexpages.currentPage().getHeaders().put( 'content-disposition', 'inline; filename=' + yourFileNameName );
        }
 
        
        public Apttus__APTS_Agreement__c Request {
            get {                    
                return [SELECT Name, Id                                                                   
                        FROM Apttus__APTS_Agreement__c 
                        Where Id =:this.appId];
                        
            }
        }
    }