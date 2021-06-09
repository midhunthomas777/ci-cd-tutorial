public class CaseResponseWrapper {
    public CaseResponseWrapper() {
        
    }
    
    public String errorCode;
    public CaseResponseHandler result;
    
    
    //Defining response parameters
    public class CaseResponseHandler{
        public String caseId;
        public String casenumber;
        public String caseStatus;
        public String errorCode;
        public Boolean isClosed;
         public string message;
        public String warningMessage;
    }
    
   
           

}