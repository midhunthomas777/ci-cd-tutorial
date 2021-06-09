public class AcccountIteratorController {
	//Commented by Satish as part of SF-512
    // Binds with the user provided value
    /*public Account_Identifier__c[] userCollection {get;set 
    {
       wrappedCollection = toCollectionOfCollection(value);       
    }*/
    public Account[] userCollection {get;set {
       		wrappedCollection = toCollectionOfCollection(value);       
    	}
    }

    // derived collection created, from user provided collection 
    // of upto 10000 items
    // Commented by satish
    //transient public List<List<Account_Identifier__c>> wrappedCollection  {get; private set;}
    transient public List<List<Account>> wrappedCollection  {get; private set;}
    
    /*
        Converts a collection of Object to 
        collection of collection with parent collection holding upto 1000 items
    */
  /* Commented by satish
   public static List<List<Account_Identifier__c>> toCollectionOfCollection(List<Account_Identifier__c> coll){
        List<List<Account_Identifier__c>> mainList = new List<List<Account_Identifier__c>>();
        List<Account_Identifier__c> innerList = null;
        Integer idx = 0;
        for(Account_Identifier__c acc:coll){
            if (Math.mod(idx++, 1000) == 0 ) {
                innerList = new List<Account_Identifier__c>();
                mainList.add(innerList);
            }
            innerList.add(acc);            
        } 
        System.debug('************ mainlist*****************'+mainlist);       
        return mainList;
    }*/
    public static List<List<Account>> toCollectionOfCollection(List<Account> coll){
        List<List<Account>> mainList = new List<List<Account>>();
        List<Account> innerList = null;
        Integer idx = 0;
        for(Account acc : coll){
            if (Math.mod(idx++, 1000) == 0 ) {
                innerList = new List<Account>();
                mainList.add(innerList);
            }
            innerList.add(acc);            
        } 
        System.debug('************ mainlist*****************'+mainlist);       
        return mainList;
    }
}