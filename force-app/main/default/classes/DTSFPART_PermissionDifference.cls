/**
 * Created by  on .
 */

public with sharing class DTSFPART_PermissionDifference {
    public Set<String> addedMcnPermissions { get; set; }
    public Set<String> addedContactMcnPermissions { get; set; }
    public Set<String> removedMcnPermissions { get; set; }
    public Set<String> removedContactMcnPermissions { get; set; }


    public Set<String> addedMrMcnPermissions { get; set; }
    public Set<String> addedMrContactMcnPermissions { get; set; }
    public Set<String> removedMrMcnPermissions { get; set; }
    public Set<String> removedMrContactMcnPermissions { get; set; }

    public DTSFPART_PermissionDifference() {
        this.addedMcnPermissions = new Set<String>();
        this.addedContactMcnPermissions = new Set<String>();
        this.removedMcnPermissions = new Set<String>();
        this.removedContactMcnPermissions = new Set<String>();
        this.addedMrMcnPermissions = new Set<String>();
        this.addedMrContactMcnPermissions = new Set<String>();
        this.removedMrMcnPermissions = new Set<String>();
        this.removedMrContactMcnPermissions = new Set<String>();
    }

    public void removePermissions(Set<String> mcn, Set<String> contactMcn, Boolean isMr) {
        if (isMr) {
            removedMrMcnPermissions.addAll(mcn);
            removedMrContactMcnPermissions.addAll(contactMcn);
        } else {
            removedMcnPermissions.addAll(mcn);
            removedContactMcnPermissions.addAll(contactMcn);
        }
    }

    public void addPermissions(Set<String> mcn, Set<String> contactMcn, Boolean isMr) {
        if (isMr) {
            addedMrMcnPermissions.addAll(mcn);
            addedMrContactMcnPermissions.addAll(contactMcn);
        } else {
            addedMcnPermissions.addAll(mcn);
            addedContactMcnPermissions.addAll(contactMcn);
        }
    }

    public void revokeAddPermissions(Set<String> mcn, Set<String> contactMcn, Boolean isMr) {
        if (isMr) {
            addedMrMcnPermissions.removeAll(mcn);
            addedMrContactMcnPermissions.removeAll(contactMcn);
        } else {
            addedMcnPermissions.removeAll(mcn);
            addedContactMcnPermissions.removeAll(contactMcn);
        }
    }

    public void revokeRemovePermissions(Set<String> mcn, Set<String> contactMcn, Boolean isMr) {
        if (isMr) {
            removedMrMcnPermissions.removeAll(mcn);
            removedMrContactMcnPermissions.removeAll(contactMcn);
        } else {
            removedMcnPermissions.removeAll(mcn);
            removedContactMcnPermissions.removeAll(contactMcn);
        }
    }

    public Set<String> getRemovedMcnPermissions(Boolean isMr) {
        if (isMr) {
            return removedMrMcnPermissions;
        } else {
            return removedMcnPermissions;
        }
    }

    public Set<String> getRemovedContactMCNPermissions(Boolean isMr) {
        if (isMr) {
            return removedMrContactMcnPermissions;
        } else {
            return removedContactMcnPermissions;
        }
    }

    public Set<String> getAddedMcnPermissions(Boolean isMr) {
        if (isMr) {
            return addedMrMcnPermissions;
        } else {
            return addedMcnPermissions;
        }
    }

    public Set<String> getAddedContactMcnPermissions(Boolean isMr) {
        if (isMr) {
            return addedMrContactMcnPermissions;
        } else {
            return addedContactMcnPermissions;
        }
    }
}