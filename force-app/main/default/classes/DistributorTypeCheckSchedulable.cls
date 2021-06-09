global class DistributorTypeCheckSchedulable implements Schedulable{

     global void execute(SchedulableContext sc)
    { 
              Integer a = [Select count() from AsyncApexJob where status = 'Queued' or status ='Processing'];
        if(a <= 5)
        {
            DistributorTypeCheck dtype= new DistributorTypeCheck();                              
            database.executebatch(dtype);
        }
        else{    
           //Standard Object which will give the scheduled time
            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :sc.getTriggerId()];
            system.abortJob(ct.id);//It will delete the old Job           
        
            Schedbatch();//Rescheduling
                                   
        }
    }
    
       public void Schedbatch()
    {
            DistributorTypeCheckSchedulable dtc= new DistributorTypeCheckSchedulable ();
            Datetime dt = datetime.now();
            Datetime dt1 = dt.addMinutes(30);
            String s =dt1.second()+' '+dt1.minute()+' '+dt1.hour()+ ' ' +dt1.day()+ ' ' +dt1.month()+ ' ' + '? '+dt1.year();
           system.schedule('DistributorType',s,dtc);         
    }
    
    
    public String insertSingleQuote(String tempName)
    {
            if(tempName.contains('\'')){
                tempName = tempName.replace('\'','\\\'');
            }
            return tempName;
    }
    
    public String replaceCapitalvalue(String tempName)
    {
            if(tempName.contains('O')){
                tempName = tempName.replace('O','o');
            }
            return tempName;
    }        
}