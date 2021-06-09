/**
 * @author       Sagar Sindhi
 * @created      2020-08-06
 * @updated      2021-02-03
 * @description  Wrapper class for DTSFPART_PartnerAdminController
 */
public class DTSFPART_PartnerAdminControllerWrapper {
    public class ContactWrapper {
        @AuraEnabled
        public String salutation {get;set;}
        @AuraEnabled
        public String firstName {get;set;}
        @AuraEnabled
        public String lastName {get;set;}
        @AuraEnabled
        public String email {get;set;}
        @AuraEnabled
        public String mpeStatus {get;set;}
        @AuraEnabled
        public String recordTypeId {get;set;}
        @AuraEnabled
        public String partnerAdminId {get;set;}
        @AuraEnabled
        public String countrycode {get;set;}
        @AuraEnabled
        public String mobile {get;set;}
        @AuraEnabled
        public String phone {get;set;}
        @AuraEnabled
        public String fax {get;set;}
        @AuraEnabled
        public String preferredLanguage {get;set;}

        public ContactWrapper(
            String salutation,
            String firstName,
            String lastName,
            String email,
            String mpeStatus,
            String recordTypeId,
            String partnerAdminId,
            String countrycode,
            String mobile,
            String phone,
            String fax,
            String preferredLanguage
        ) {
            this.salutation = salutation;
            this.firstName = firstName;
            this.lastName = lastName;
            this.email = email;
            this.mpeStatus = mpeStatus;
            this.recordTypeId = recordTypeId;
            this.partnerAdminId = partnerAdminId;
            this.countrycode = countrycode;
            this.mobile = mobile;
            this.phone = phone;
            this.fax = fax;
            this.preferredLanguage = preferredLanguage;
        }
    }
}