/*******************************************************************************
Copyright © 2014 Motorola Solutions.
Author: Ashish Jain
Email: XPD643@motorolasolutions.com 
Date:  April 2014
Description:  This Controller class is using by the AllContactsVisibility controller.
for See all contact functionality in sharing for user mode for searching the contact
on basis of some filter criteria.
********************************************************************************/
public with sharing class ContactSharingClass{

    public List<Contact> sharedFinalList {get;set;}

     public List<Contact> getListWithOffset(String offsetsoql){
            system.debug('--> Check SOQL In share class getListWithOffset --> '+offsetsoql);
            sharedFinalList = new List<Contact>();
            sharedFinalList = Database.query(offsetsoql);
            return sharedFinalList;
 }
 
      public List<Contact> getListWithoutOffset(String offsetsoql){
            system.debug('--> Check SOQL In share class getListWithoutOffset--> '+offsetsoql);
            sharedFinalList = new List<Contact>();
            sharedFinalList = Database.query(offsetsoql);
            return sharedFinalList;
 }
}