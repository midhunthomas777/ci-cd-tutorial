/*
* Name : BatchRRDFeeder
* Description: This class is used to iterate over Run Rate record sequentially
* Author : Adilraza Shaikh, Afzal Wasi
* Date : 6/1/2020
*/
global class BatchRRDFeeder implements Iterator<Run_Rate_Definition__c>, Iterable<Run_Rate_Definition__c> {
    List<Run_Rate_Definition__c> source;
    
    global Iterator<Run_Rate_Definition__c> iterator() {
        return this;
    }
    
    public BatchRRDFeeder(List<Run_Rate_Definition__c> source) {
        this.source = source;
    }
    
    public Run_Rate_Definition__c next() {
        return source.remove(0);
    }
    
    global boolean hasNext() {
        return source!=null && !source.isempty();
    }
}