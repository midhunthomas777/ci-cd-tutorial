public inherited sharing class DTSFPART_PermissionContactCalc {
    private Map<String, List<Default_Communities_Permissions__mdt>> permissionsByPersona = DTSFPART_PermissionUtils.getPermissionsByPersona();
    private Map<String, List<Default_Communities_Permissions__mdt>> permissionsByRegion = DTSFPART_PermissionUtils.getPermissionsByRegion();
    // private Contact contact;
    // private Account account;
    public Boolean isChanged = false;

    public DTSFPART_PermissionContactCalc(Contact contact,  Account account){
        calculatePermissions(contact,  account);
    }

    private void calculatePermissions(Contact contact,  Account account){
        Set<String> communityTypes = DTSFPART_PermissionUtils.getCommunityTypes(account);
        if(communityTypes.isEmpty()){
            return;
        }

        if (String.isNotBlank(contact.Persona__c) && permissionsByPersona.containsKey(contact.Persona__c)) {
            PermissionAccumulator accumulator = new PermissionAccumulator();

            if(String.isNotBlank(contact.Persona__c)){
                sumPermissions(permissionsByPersona.get(contact.Persona__c), communityTypes, accumulator);
                System.debug('Persona Perms summed: ' + permissionsByPersona.get(contact.Persona__c));
            }
            if(String.isNotBlank(account.BillingCountry)){
                sumPermissions(permissionsByRegion.get(account.BillingCountry), communityTypes, accumulator);
                System.debug('Country Perms summed: ' + permissionsByRegion.get(account.BillingCountry)[0].Contact_Mcn_Permissions__c);
            }
            if(String.isNotBlank(account.Theater_Emp__c)){
                sumPermissions(permissionsByRegion.get(account.Theater_Emp__c), communityTypes, accumulator);
                System.debug('Region Perms summed: ' + permissionsByRegion?.get(account.Theater_Emp__c)[0]?.Contact_Mcn_Permissions__c);
            }

            if(!accumulator.modifiedPermissions(contact)) {
                saveContactPermissions(contact, accumulator);
                isChanged = true;
            }
        } else if(contact.Contact_MCN_Permissions__c != '' || contact.Contact_level_Internal_permissions__c != '') {
            clearContactPermissions(contact);
            isChanged = true;
        }
    }

    private void saveContactPermissions(Contact contact, PermissionAccumulator accumulator){
        contact.Contact_MCN_Permissions__c = accumulator.getContactMCNPermissions();
        contact.Contact_level_Internal_permissions__c = accumulator.getContactInternalPermissions();
        if(String.isNotBlank(contact.Tag__c)){
            accumulator.addTags(contact.Tag__c.split('[;,]')); // https://jira.mot-solutions.com/browse/DTPART-1366
        }
        contact.Tag__c = accumulator.getTags();
        contact.Enterprise_Permission_Status__c = 'In Progress';
    }

    private void clearContactPermissions(Contact contact){
        contact.Contact_MCN_Permissions__c = '';
        contact.Contact_level_Internal_permissions__c = '';
        contact.Enterprise_Permission_Status__c = 'In Progress';
    }

    private static void sumPermissions(List<Default_Communities_Permissions__mdt> source, Set<String> communityTypes, PermissionAccumulator accumulator){
        if(source != null){
            for (Default_Communities_Permissions__mdt permission : source) {
                if (!communityTypes.contains(permission.Community_Type__c)) {
                    continue;
                }
    
                if (String.isNotBlank(permission.Contact_Mcn_Permissions__c)) {
                    accumulator.addContactMCNPermissions(permission.Contact_Mcn_Permissions__c.split('[;,]'));
                }
                if (String.isNotBlank(permission.Contact_Internal_Permissions__c)) {
                    accumulator.addInternalPermissions(permission.Contact_Internal_Permissions__c.split('[;,]'));
                }
                if (String.isNotBlank(permission.Tags__c)) {
                    accumulator.addTags(permission.Tags__c.split('[;,]'));
                }
            }
        }
    }

    class PermissionAccumulator {
        Set<String> contactMCNPermissions;
        Set<String> contactInternalPermissions;
        Set<String> tags;
        
        public PermissionAccumulator(){
            contactMCNPermissions = new Set<String>();
            contactInternalPermissions = new Set<String>();
            tags = new Set<String>();
        }

        public void addContactMCNPermissions(List<String> permissions){
            System.debug('Add permissions: ' + permissions);
            addAll(contactMCNPermissions, permissions);
        }

        public void addInternalPermissions(List<String> permissions){
            addAll(contactInternalPermissions, permissions);
        }

        public void addTags(List<String> permissions){
            addAll(tags, permissions);
        }

        public String getContactMCNPermissions(){
            return String.join((Iterable<String>) contactMCNPermissions, ';');
        }

        public String getContactInternalPermissions(){
            return String.join((Iterable<String>) contactInternalPermissions, ';');
        }

        public String getTags(){
            return String.join((Iterable<String>) tags, ';');
        }

        public Boolean modifiedPermissions(Contact contact){
            return DTSFPART_PermissionUtils.permisionsEquals(contact.Contact_MCN_Permissions__c, getContactMCNPermissions())
                    && DTSFPART_PermissionUtils.permisionsEquals(contact.Contact_level_Internal_permissions__c, getContactInternalPermissions())
                    && DTSFPART_PermissionUtils.permisionsEquals(contact.Tag__c, getTags());
        }

        private void addAll(Set<String> target, List<String> permissions){
            if(target == null){
                target = new Set<String>();
            }

            target.addAll(permissions);
        }
    }
}