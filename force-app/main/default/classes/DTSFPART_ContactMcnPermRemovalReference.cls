/**
 * Created by QGBC67 on 11.12.2020.
 */

public with sharing class DTSFPART_ContactMcnPermRemovalReference {
    private Set<Id> removeAllByMcn;
    private Map<Id, List<Id>> removeForContactByMcn;

    public DTSFPART_ContactMcnPermRemovalReference() {
        removeAllByMcn = new Set<Id>();
        removeForContactByMcn = new Map<Id, List<Id>>();
    }

    public void add(Id mcnId, Id contactId)
    {
        if(!removeForContactByMcn.containsKey(mcnId))
        {
            removeForContactByMcn.put(mcnId, new List<Id>());
        }
        removeForContactByMcn.get(mcnId).add(contactId);
    }

    public void addAll(Id mcnId)
    {
        removeAllByMcn.add(mcnId);
    }

    public Boolean shouldExist(Contact_Permissions__c contactMcnPermission) {
        return shouldExist(contactMcnPermission.MCN_Account__c, contactMcnPermission.Contact__c);
    }

    public Boolean shouldExist(Id mcnId, Id contactId) {
        return !(removeAllByMcn.contains(mcnId) ||
                (removeForContactByMcn.containsKey(mcnId) && removeForContactByMcn.get(mcnId).contains(contactId)));
    }
}