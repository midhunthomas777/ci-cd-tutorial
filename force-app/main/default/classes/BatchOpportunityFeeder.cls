global class BatchOpportunityFeeder implements Iterator<Opportunity>, Iterable<Opportunity> {
    List<Opportunity> source;
    
    global Iterator<Opportunity> iterator() {
        return this;
    }
    
    public BatchOpportunityFeeder(List<Opportunity> source) {
        this.source = source;
    }
    
    public Opportunity next() {
        return source.remove(0);
    }
    
    global boolean hasNext() {
        return source!=null && !source.isempty();
    }
}