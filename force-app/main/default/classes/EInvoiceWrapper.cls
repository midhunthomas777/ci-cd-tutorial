public class EInvoiceWrapper {
    
    public CUSTOMER_DATA CUSTOMER_DATA;
    public List<CONTACT_ROLE_DATA> CONTACT_ROLE_DATA;
    
    public EInvoiceWrapper(CUSTOMER_DATA header, List<CONTACT_ROLE_DATA> lines){
        this.CUSTOMER_DATA = header;
        this.CONTACT_ROLE_DATA = lines;  
    }
    
    public class CONTACT_ROLE_DATA {
        public String P_ACTION_TYPE;
        public String P_CUSTOMER_SITE;
        public String P_CONTACT_FIRST_NAME;
        public String P_CONTACT_LAST_NAME;
        public String P_EMAIL;
        public String P_CONTACT_ROLE;
        public String P_CONTACT_REFERENCE;
    }
    
    public class CUSTOMER_DATA {
        public String P_CURR_INV_PREFERENCE;
        public String P_NEW_INV_PREFERENCE;
        public String P_SOURCE_SYSTEM;
        public String P_SOURCE_SYSTEM_REF;
        public String P_REQUESTOR_EMAIL;
        public String P_REQUESTOR_COREID;
        public String P_GF_CUSTOMER_NUMBER;
        public String P_GF_CUSTOMER_NAME;
        public String P_FLIP_ALL_ACCTS;
    }
}