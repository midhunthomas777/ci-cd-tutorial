public class OpportunityFxRateFlow
{
    @InvocableMethod
    public static void populateFxRate(List<Id> opportunityIds)
    {
        Map<String,Double> rateMap = new Map<String,Double>();
	
        Map<String,List<Integer>> fxrateCodeYearMap = new Map<String,List<Integer>>();
        List<Integer> yearsList = new List<Integer>();
        set<String> nonUSDCurrencies = new Set<String>();
        List<Opportunity> opps = [SELECT Id, currencyIsoCode, closeDate, FX_Rate__c FROM Opportunity where Id IN:opportunityIds];
        for(Opportunity opp : opps){
            nonUSDCurrencies.add(opp.currencyIsoCode);
        }

        system.debug('nonUSDCurrencies :='+nonUSDCurrencies);
        for(FX_Rate__c fxRate : [SELECT Id, Mashup__c, Conversion_Rate__c, currencyIsoCode,Year__c FROM FX_Rate__c WHERE currencyIsoCode IN: nonUSDCurrencies ORDER BY currencyIsoCode]) {
            rateMap.put(fxRate.Mashup__c,fxRate.Conversion_Rate__c);
            if(!fxrateCodeYearMap.containsKey(fxRate.currencyIsoCode)){
                fxrateCodeYearMap.put(fxRate.currencyIsoCode, new List<Integer>());
                fxrateCodeYearMap.get(fxRate.currencyIsoCode).add(Integer.valueOf(fxRate.Year__c));
            }
            else {
                fxrateCodeYearMap.get(fxRate.currencyIsoCode).add(Integer.valueOf(fxRate.Year__c));
            }
        }
        
        for(Opportunity opp : opps) {
            
            Integer systemYear = Date.Today().Year();
            yearsList.add(systemYear);
            Integer closeDateYear = opp.closeDate.year();
            yearsList.add(closeDateYear);
            Integer fxRateYear;
            Integer searchFxRateYear;

            if(fxrateCodeYearMap.containsKey(opp.currencyIsoCode)){
                List<Integer> dateList = fxrateCodeYearMap.get(opp.currencyIsoCode);
                dateList.sort();
                fxRateYear =  dateList.get(dateList.size()-1);
            }
                
                
            yearsList.add(fxRateYear);
            yearsList.sort();
            searchFxRateYear = yearsList.get(0);
            system.debug(yearsList.get(0));
            system.debug(opp.currencyIsoCode + Integer.valueOf(searchFxRateYear));
            system.debug(rateMap.get(opp.currencyIsoCode + Integer.valueOf(searchFxRateYear)));
            opp.FX_Rate__c = rateMap.get(opp.currencyIsoCode + Integer.valueOf(searchFxRateYear));
        	
        }
        update opps;
    }
}