/*******************************************************************************
* Description : GetCaseOwnerFromCaseHistory - used in flow Create case on email closed case
* purpose :
* Jira             Date             Author       Changes
* LUCXBW-785       27/01/2020       Anusuya      To verify whether the case has been assigned to queue atleast oncce in life cycle  
************************************************************************************/
public class GetCaseOwnerFromCaseHistory {
    @InvocableMethod
    Public Static List<String> getCaseOwner(List<Id> caseId){
        List<String> lstCaseOwner= new List<String>();
        String strCaseOwner = '';
        List<CaseHistory> lstCaseHistory= new List<CaseHistory>();
        if(caseId!=null && caseId.size()>0){
            
            lstCaseHistory = [select id,oldvalue,newValue from casehistory where caseid=:caseId[0] and field='Owner' order by createddate desc];
            String strOldValue = '';           
            for(CaseHistory objCaseHistory: lstCaseHistory){
                strOldValue = (string)objCaseHistory.oldvalue;
                if(strOldValue.startsWith('00G') ){
                    strCaseOwner = strOldValue;
                    break;
                }                
            }
        }
      
        if(lstCaseHistory.size() > 0){
            if(String.isBlank(strCaseOwner)){
                strCaseOwner = (string)lstCaseHistory[0].oldvalue; //However parent's caseowner will be assigned in FLOW if there is no Queue matched here
            }
        }
       
        lstCaseOwner.add(strCaseOwner);
        return lstCaseOwner;
    }
    
    
}