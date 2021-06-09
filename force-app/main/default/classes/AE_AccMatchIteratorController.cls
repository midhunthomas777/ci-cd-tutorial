public class AE_AccMatchIteratorController {

    // Binds with the user provided value
    public Account_Match__c[] userCollection {get;set 
    {
       wrappedCollection = toCollectionOfCollection(value);       
    }
    }

    // derived collection created, from user provided collection 
    // of upto 10000 items
    transient public List<List<Account_Match__c>> wrappedCollection  {get; private set;}
    
    /*
        Converts a collection of Object to 
        collection of collection with parent collection holding upto 1000 items
    */
  public static List<List<Account_Match__c>> toCollectionOfCollection(List<Account_Match__c> coll){
        List<List<Account_Match__c>> mainList = new List<List<Account_Match__c>>();
        List<Account_Match__c> innerList = null;
        Integer idx = 0;
        for(Account_Match__c acc:coll){
            if (Math.mod(idx++, 1000) == 0 ) {
                innerList = new List<Account_Match__c>();
                mainList.add(innerList);
            }
            innerList.add(acc);            
        } 
        System.debug('************ mainlist*****************'+mainlist);       
        return mainList;
    }    
}