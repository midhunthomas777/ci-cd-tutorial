/*******************************************************************************
Copyright © 2014 Motorola Solutions.
Author: Ashish Jain
Email: XPD643@motorolasolutions.com 
Date:  April 2014
Description:  This Controller class is using by the AllContactsVisibility controller.
for See all contact functionality as a Wrapper class for searching the contact on 
basis of some filter criteria.
********************************************************************************/


public class ContactWrapper{
   
     public String ID {get;set;}
     public String Name {get;set;}
     public String AccountName {get;set;}
     public String AccountId {get;set;}
     public String ContactJobRole {get;set;}
     public String Email {get;set;}
     public String Phone{get;set;}
     public String Theater {get;set;}
     public String Department {get;set;}
     public boolean DoNotCall {get;set;}
     public boolean HasOptedOutOfEmail {get;set;}
     public boolean checkFlag{get;set;} 
     public String ownerEmail { get; set;}  
     public String ownerName { get; set;}   
     public String LdapID {get;set;}
     
   }