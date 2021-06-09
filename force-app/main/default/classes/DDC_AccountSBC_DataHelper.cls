/***************************************************8
    Creator                 : Manjunath C Sarashetti
    Class                   : DDC_AccountSBC_DataHelper
    Created Date            : 27-03-2017     
    Desc                    : This is used has Helper for data wrapping and Data loading in UI.
                                
*****************************************************/

public class DDC_AccountSBC_DataHelper {
     /************************************************************************************
    Creator                 : Manjunath C Sarashetti
    Class                   : requestWrapperDataObj
    Created Date            : 27-03-2017     
    Desc                    : This used to hold the request data for a call
                                
    ************************************************************************************/
    public class requestWrapperDataObj{
        @AuraEnabled public string Name {get;set;}
        @AuraEnabled public string Country {get;set;}
        @AuraEnabled public string City {get;set;}
        @AuraEnabled public string State {get;set;}
        //raquib
        //@AuraEnabled public string Owner__c {get;set;}
    
    }  
    // need to be carefull we might hit view state
    /************************************************************************************
    Creator                 : Manjunath C Sarashetti
    Class                   : DisplayDataObj
    Created Date            : 27-03-2017     
    Desc                    : This used to hold the supporting data for a row
                                
    ************************************************************************************/
    public class DisplayDataObj{
        @AuraEnabled public boolean selected {get;set;}
        @AuraEnabled public Account Account{get;set;}
        @AuraEnabled public string ImgUrl {get;set;}
        @AuraEnabled  public string SecondaryImgUrl {get;set;}
        @AuraEnabled public string AccountType {get;set;}  // Exact Type; Fuzzy; D&B - 
        @AuraEnabled public string SecondaryImgUrlHelpText {get;set;}
        @AuraEnabled public string ImgUrlHelpText {get;set;}  // Exact Type; Fuzzy; D&B -
        //SF-1892: SBC allowing creation of duplicates on Lead Conversion--Start
        @AuraEnabled public boolean exactMatch {get;set;}
        //SF-1892: SBC allowing creation of duplicates on Lead Conversion--End
        @AuraEnabled public boolean fuzzyMatch {get;set;}
        public DisplayDataObj(){
            selected = false;
            Account = new Account();
            exactMatch = false;//SF-1892: SBC allowing creation of duplicates on Lead Conversion            
            fuzzyMatch = false;
        }
    }
    /************************************************************************************
    Creator                 : Manjunath C Sarashetti
    Class                   : LstDisplayData 
    Created Date            : 27-03-2017     
    Desc                    : This used to displaying the data
                                
    ************************************************************************************/
    public class LstDisplayData {
        @AuraEnabled public list<DisplayDataObj> dataList {get;set;}
        @AuraEnabled public Map<String,DisplayDataObj> dataListExactMatchNotMatchWithDNB {get;set;} // to display Exatch Match SFDC not match with DNB in First now//
        @AuraEnabled public Map<String,DisplayDataObj> dataListFuzyyMatchNotMatchWithDNB {get;set;} // to display Fuzzy Match SFDC not match with DNB in First now//
        @AuraEnabled public Map<String,DisplayDataObj> dataListExactMatch {get;set;}
        @AuraEnabled public Map<String,DisplayDataObj> dataListFuzzyMatch {get;set;}
        @AuraEnabled public Map<String,DisplayDataObj> dnsResponse{get;set;}
        @AuraEnabled public Map<String,DisplayDataObj> dnsResponseNonDup{get;set;}
        @AuraEnabled public Map<String,integer> indexIdentifier{get;set;}
        @AuraEnabled public integer dnsResponseCount {get;set;}
        @AuraEnabled public integer ExactMatchCount {get;set;}
        @AuraEnabled public integer FuzzyMatchCount {get;set;}
        //SF-1892: SBC allowing creation of duplicates on Lead Conversion--Start
        @AuraEnabled public boolean exactMatch {get;set;}
        //SF-1892: SBC allowing creation of duplicates on Lead Conversion--End
        @AuraEnabled public boolean fuzzyMatch {get;set;}
        public LstDisplayData (){
            dataList = new list<DDC_AccountSBC_DataHelper.DisplayDataObj> ();
            dataListExactMatchNotMatchWithDNB =new Map<String,DDC_AccountSBC_DataHelper.DisplayDataObj>();
            dataListFuzyyMatchNotMatchWithDNB =new Map<String,DDC_AccountSBC_DataHelper.DisplayDataObj>();
            dataListExactMatch =  new Map<String,DDC_AccountSBC_DataHelper.DisplayDataObj>();
            dataListFuzzyMatch =  new  Map<String,DDC_AccountSBC_DataHelper.DisplayDataObj>();
            dnsResponse =  new  Map<String,DDC_AccountSBC_DataHelper.DisplayDataObj>();
            dnsResponseNonDup =  new  Map<String,DDC_AccountSBC_DataHelper.DisplayDataObj>(); // non dup
            indexIdentifier = new Map<string,integer>();
            dnsResponseCount =0;
            ExactMatchCount =0;
            FuzzyMatchCount =0;           
            exactMatch = false;//SF-1892: SBC allowing creation of duplicates on Lead Conversion
            fuzzyMatch = false;//SF-1950 - Don't allow selection of a fuzzy match Account when an exact match exists            
        }
    }
}