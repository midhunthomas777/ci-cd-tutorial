/*******************************************************************************
* Description : GetCaseOwnerFromCaseHistory - used in flow Create case on email closed case
* purpose :
* Jira             Date             Author       Changes
* LUCXBW-785       27/01/2020       Anusuya      To verify whether the case has been assigned to queue atleast oncce in life cycle  
************************************************************************************/
@isTest()
public class ApexActionCallFromFlowTestMethods {  
    @isTest(SeeAllData=true)
    static void GetCaseOwnerFromCaseHistoryTest(){
        List<id> lstCase = new List<id>();
        CaseHistory CaseHistory = [select id,oldvalue,newValue,caseid from casehistory  where field='Owner'limit 1];
        lstCase.add(CaseHistory.caseid);
        GetCaseOwnerFromCaseHistory.getCaseOwner(lstCase);
    }
}