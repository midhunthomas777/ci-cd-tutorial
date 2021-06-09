public with sharing  class CodeRefactor{
    public static void createnzcontact(string firstname,string lastname,string country,id  accountid)
    {
        try{
            
           contact cont=new contact ();
            cont.FirstName=firstname;
            cont.LastName=lastname;
            cont.COUNTRY__c=country;
            cont.AccountId=accountid;
            insert cont;
        }
            catch(exception e){
                system.debug(e.getMessage());
            }
                
            }
        }