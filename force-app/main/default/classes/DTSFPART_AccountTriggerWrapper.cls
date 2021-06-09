public with sharing class DTSFPART_AccountTriggerWrapper {
    public Id id { get; private set; }
    public Id parentId { get; private set; }
    public Id assignedMrId { get; private set; }
    public Account newAccount { get; private set; }
    public Account oldAccount { get; private set; }
    public Account parent { get; private set; }

    public DTSFPART_AccountTriggerWrapper(Account newAccount) {
        this(newAccount, null);
    }

    public DTSFPART_AccountTriggerWrapper(Account newAccount, Account oldAccount) {
        this(newAccount, oldAccount, null);
    }

    public DTSFPART_AccountTriggerWrapper(Account newAccount, Account oldAccount, Account parent) {
        this.id = newAccount.Id;
        this.parentId = newAccount.ParentId;
        this.assignedMrId = newAccount.Assigned_MR__c;
        this.newAccount = newAccount;
        this.oldAccount = oldAccount;
        this.parent = parent;
    }

    public Boolean needsPermissionRecalculation() {
        return newAccount.ERP_Active__c &&
            (isActivated() ||
            isParentChanged() ||
            isAssignedMRChanged() ||
            isRouteToMarketChangedToMrLed() ||
            isRouteToMarketChangedFromMrLedToOpen() ||
            isRouteToMarketChangedFromMrLedToMsiLed() ||
            isMCNNumberChanged());
    }

    public Boolean needsMRPermissionRecalculation() {
        return isCustomerFieldsPopulated() &&
            (isActivated() ||
            isRouteToMarketChangedToMrLed() ||
            isAssignedMRChanged() ||
            isAssignedMRPersonChanged() ||
            isMCNNumberChanged());
    }

    public Boolean needsPermissionRecalculationForMRPerson() {
        return isRouteToMarketChangedFromMrLed() || isDeactivated() || isAssignedMRChanged();
    }

    public Boolean isParentChanged() {
        return newAccount.ParentId != oldAccount.ParentId;
    }

    public Boolean isAssignedMRChanged() {
        return newAccount.Assigned_MR__c != oldAccount.Assigned_MR__c;
    }

    public Boolean isRouteToMarketChangedToMrLed() {
        return newAccount.Primary_Route_to_Market__c == DTSFPART_CommonStrings.MR_LED && oldAccount.Primary_Route_to_Market__c != DTSFPART_CommonStrings.MR_LED;
    }

    public Boolean isRouteToMarketChangedFromMrLed() {
        return newAccount.Primary_Route_to_Market__c != DTSFPART_CommonStrings.MR_LED && oldAccount.Primary_Route_to_Market__c == DTSFPART_CommonStrings.MR_LED;
    }

    public Boolean isRouteToMarketChangedFromMrLedToOpen() {
        return newAccount.Primary_Route_to_Market__c == DTSFPART_CommonStrings.OPEN && oldAccount.Primary_Route_to_Market__c == DTSFPART_CommonStrings.MR_LED;
    }

    public Boolean isRouteToMarketChangedFromMrLedToMsiLed() {
        return newAccount.Primary_Route_to_Market__c == DTSFPART_CommonStrings.MSI_LED && oldAccount.Primary_Route_to_Market__c == DTSFPART_CommonStrings.MR_LED;
    }

    public Boolean isMCNNumberChanged() {
        return newAccount.Motorola_Customer_Number__c != oldAccount.Motorola_Customer_Number__c;
    }

    public Boolean isActivated() {
        return newAccount.ERP_Active__c && !oldAccount.ERP_Active__c;
    }

    public Boolean isDeactivated() {
        return !newAccount.ERP_Active__c && oldAccount.ERP_Active__c;
    }

    public Boolean isPartnerRT() {
        return parent != null && DTSFPART_Utils.isPartnerRecordType(parent.RecordTypeId);
    }

    public Boolean isAssignedMRPersonChanged() {
        return newAccount.Assigned_MR_Sales_Person__c != oldAccount.Assigned_MR_Sales_Person__c;
    }

    public Boolean isCustomerFieldsPopulated() {
        return newAccount.Primary_Route_to_Market__c == DTSFPART_CommonStrings.MR_LED && newAccount.Assigned_MR__c != null;
    }

    public Boolean hadCustomerFieldsPopulated() {
        return oldAccount.Primary_Route_to_Market__c == DTSFPART_CommonStrings.MR_LED && oldAccount.ERP_Active__c == true && oldAccount.Assigned_MR__c != null;
    }
}