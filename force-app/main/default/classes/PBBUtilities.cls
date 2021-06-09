public with sharing class PBBUtilities {
    
    public static List<String> dedupe(List<String> input){
        Set<String> temp = new Set<String>(input);
        return new List<String>(temp);
    }
   
}