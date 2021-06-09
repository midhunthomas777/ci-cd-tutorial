/*************************************************************************************************************
Name     : CombinedDashboardsController.cls
Copyright @ 2014 Motorola Solutions
Author(s): Sarika Gaikwad 
Purpose  : This Controller is used for developing a functionality for Combined Dashboards and Trend Dashboards. 
Version  : 1.0
*************************************************************************************************************/

public class CombinedDashboardsController {

    Public Boolean disp{get;set;}
    Public boolean DisplayError{get;set;}
    Public Boolean YTD{get;set;}
    Public Date MRRefreshDate{get;set;}
    Public Date MRFEDRefreshDate{get;set;}
    Public Date JuiceRefreshDate{get;set;}
    Public Date SIRefreshDate{get;set;}
    Public Date APORefreshDate{get;set;}
    Public Date SDFRefreshDate{get;set;} 
    Public String TrendR1{get;set;}
    Public String TrendR2{get;set;}
    Public String TrendR3{get;set;}
    Public String TrendR4{get;set;}
    Public String ServiceR1{get;set;}
    Public String ServiceR2{get;set;}
    Public String ServiceR3{get;set;}
    Public String ServiceR4{get;set;}
    public AggregateResult e;
    Public EDW_SDS_Extract__c acc{get;set;}
    Public List<AggregateResult> AgrYear; 
    Public List<EDW_SDS_Extract__History> HistoryList = new List<EDW_SDS_Extract__History>();
    Public List<EDW_SDS_Extract__c> e1 {get;set;}
    Public List<AggregateResult> e2 ;
    Public List<EDW_SDS_Extract__c> TrendData {get;set;}
    Public folder Reportfolder{get;set;}
    Public List<Report> ReportList{get;set;}
    Public integer SI_MR,SI_FED,SER_MR,SER_FED,Deal,WT_tot,Main_tot,INST_tot,SF_tot,Grand_tot,Equip_MR,Equip_MRF,Hard,Ser_Juice;
    
    
    Public CombinedDashboardsController(){
        acc= new EDW_SDS_Extract__c();
        e1 = new List<EDW_SDS_Extract__c>();
        
        TrendData = new List<EDW_SDS_Extract__c>();
        DisplayError = false;
        disp = false; 
        YTD = false;
               
    }
    Public void DisplayGraphs(){
       disp = true;
 /*****-------------------Used to get the report ids for generating the dynamic report links.-----------********/
        Reportfolder = [select id from folder where developername = 'Service_Delivery_and_Trend_Reports'];
        if(Reportfolder != null){
            ReportList = [SELECT DeveloperName,Id,Name,NamespacePrefix,ownerid FROM Report WHERE Ownerid =: Reportfolder.id];
        }
        if(ReportList != null){
            for(Report r:ReportList ){
                if(r.DeveloperName == 'Services_Sales_by_Year'){
                    TrendR1 = r.id;
                }
                else if(r.DeveloperName == 'Service_Spend_by_Year'){
                    TrendR3 = r.id;
                }
                else if(r.DeveloperName == 'Equipment_Sales_by_Year'){
                    TrendR2 = r.id;
                }
                else if(r.DeveloperName == 'Service_Contribution_By_Year'){
                    TrendR4 = r.id;
                }
                else if(r.DeveloperName == 'Up_Sales_Graph'){
                    ServiceR2 = r.id;
                }
                else if(r.DeveloperName == 'Up_Motorola_Spend'){
                    ServiceR3 = r.id;
                }
                else if(r.DeveloperName == 'Service_Contribution'){
                    ServiceR4 = r.id;
                }
                else if(r.DeveloperName == 'Up_Equipment_Sales1'){
                    ServiceR1 = r.id;
                }
            
            }       
        }
        
        try{
            if(acc.Account__c !=null && acc.Year__c == null){
              Date expected = System.today();
             string year = string.valueof(expected.year());
             e1 = [select id,Account__C,Year__c,lastmodifieddate,SI_MR__c,SI_MRF__c,Service_MR__c,Service_MRF__c,WT_Total__c,Maintenance_Total__c,Install_Total__c,
                      Total_SF_Paid_YTD__c,Sum_of_Grand_Total__c,Equipment_MR__c,Equipment_MRF__c,Hardware__c,Service_Juice__c,
                      MR_Detail_Refresh_Date__c,MR_FED_Refresh_Date__c,SDF_Paid_Refresh_Date__c,SI_Spend_Refresh_Date__c,Juice_Refresh_Date__c,APO_Refresh_Date__c from EDW_SDS_Extract__c where Account__c =:acc.Account__c AND year__c =: year limit 1];
              e = [select Account__c,year__c ,sum(SI_MR__c) S1,sum(SI_MRF__c) s2,sum(Service_MR__c) s3,sum(Service_MRF__c) s4,
                       sum(WT_Total__c) s6,sum(Maintenance_Total__c) s7,sum(Install_Total__c) s8,sum(Total_SF_Paid_YTD__c) s9,sum(Sum_of_Grand_Total__c) s10,sum(Equipment_MR__c) s11,sum(Equipment_MRF__c) s12,sum(Hardware__c) s13,sum(Service_Juice__c) s14
                       from EDW_SDS_Extract__c where Account__c =:acc.Account__c and year__c =: year group by Account__c,Year__c]; 
                       system.debug('****E'+e);                    
               SI_MR = (integer.valueof(e.get('s1')) != null) ? integer.valueof(e.get('s1')) : 0 ;
               SI_FED = (integer.valueof(e.get('s2')) != null) ? integer.valueof(e.get('s2')) : 0 ;
               SER_MR = (integer.valueof(e.get('s3')) != null) ? integer.valueof(e.get('s3')) : 0 ;
               SER_FED= (integer.valueof(e.get('s4')) != null) ? integer.valueof(e.get('s4')) : 0 ;
               WT_tot= (integer.valueof(e.get('s6')) != null) ? integer.valueof(e.get('s6')) : 0 ;
               Main_tot= (integer.valueof(e.get('s7')) != null) ? integer.valueof(e.get('s7')) : 0 ;
               INST_tot= (integer.valueof(e.get('s8')) != null) ? integer.valueof(e.get('s8')) : 0 ;
               SF_tot= (integer.valueof(e.get('s9')) != null) ? integer.valueof(e.get('s9')) : 0 ;
               Grand_tot= (integer.valueof(e.get('s10')) != null) ? integer.valueof(e.get('s10')) : 0 ;
               Equip_MR= (integer.valueof(e.get('s11')) != null) ? integer.valueof(e.get('s11')) : 0 ;
               Equip_MRF= (integer.valueof(e.get('s12')) != null) ? integer.valueof(e.get('s12')) : 0 ;
               Hard= (integer.valueof(e.get('s13')) != null) ? integer.valueof(e.get('s13')) : 0 ;
               Ser_Juice= (integer.valueof(e.get('s14')) != null) ? integer.valueof(e.get('s14')) : 0 ;
               EDW_SDS_Extract__c Refreshinfo =[select Account__c,year__c ,MR_Detail_Refresh_Date__c,MR_FED_Refresh_Date__c,SDF_Paid_Refresh_Date__c,SI_Spend_Refresh_Date__c,Juice_Refresh_Date__c,APO_Refresh_Date__c from EDW_SDS_Extract__c where Account__c =:acc.Account__c and year__c =: year limit 1];
               system.debug('Refreshinfo-->'+Refreshinfo);
               
                MRRefreshDate = Refreshinfo.MR_Detail_Refresh_Date__c;
                MRFEDRefreshDate = Refreshinfo.MR_FED_Refresh_Date__c;
                SDFRefreshDate = Refreshinfo.SDF_Paid_Refresh_Date__c;
                SIRefreshDate = Refreshinfo.SI_Spend_Refresh_Date__c;
                JuiceRefreshDate = Refreshinfo.Juice_Refresh_Date__c;
                APORefreshDate = Refreshinfo.APO_Refresh_Date__c;
                system.debug('MRRefreshDate-->'+MRRefreshDate);
             }
        }
        catch(Exception e){
            System.debug('The following exception has occurred: ' + e.getMessage());
        }

        if(acc.Account__c !=null && acc.Year__c!= null){
            Date expected = System.today();
             string year = string.valueof(expected.year());
             if(acc.Year__c == year){
                 YTD = true;
             }
             else{            
                 YTD = false;
             }
             string y = string.valueof(integer.valueof(acc.Year__c) - 3);
         e1 = [select id,Account__C,Year__c,lastmodifieddate,SI_MR__c,SI_MRF__c,Service_MR__c,Service_MRF__c,WT_Total__c,Maintenance_Total__c,Install_Total__c,
                      Total_SF_Paid_YTD__c,Sum_of_Grand_Total__c,Equipment_MR__c,Equipment_MRF__c,Hardware__c,Service_Juice__c,
                      MR_Detail_Refresh_Date__c,MR_FED_Refresh_Date__c,SDF_Paid_Refresh_Date__c,SI_Spend_Refresh_Date__c,Juice_Refresh_Date__c,APO_Refresh_Date__c from EDW_SDS_Extract__c where Account__c =:acc.Account__c AND Year__c <=: acc.Year__c AND Year__c >: y order by lastmodifieddate DESC limit 3];
         System.debug('e1------->'+e1);
         
         AgrYear = [select Account__c,Year__c,sum(SI_MR__c) S1,sum(SI_MRF__c) s2,sum(Service_MR__c) s3,sum(Service_MRF__c) s4,
                   sum(WT_Total__c) s6,sum(Maintenance_Total__c) s7,sum(Install_Total__c) s8,sum(Total_SF_Paid_YTD__c) s9,sum(Sum_of_Grand_Total__c) s10,sum(Equipment_MR__c) s11,sum(Equipment_MRF__c) s12,sum(Hardware__c) s13,sum(Service_Juice__c) s14 
                   from EDW_SDS_Extract__c where Account__c =:acc.Account__c AND Year__c <=: acc.Year__c AND Year__c >: y  group by Account__c,Year__c order by Year__c limit 3];
                   System.debug('****AgrYear****'+AgrYear);
                   
             if(e1.size() != null && e1.size() >0){
                disp = true;             
                MRRefreshDate = e1[0].MR_Detail_Refresh_Date__c;
                MRFEDRefreshDate = e1[0].MR_FED_Refresh_Date__c;
                SDFRefreshDate = e1[0].SDF_Paid_Refresh_Date__c;
                SIRefreshDate = e1[0].SI_Spend_Refresh_Date__c;
                JuiceRefreshDate = e1[0].Juice_Refresh_Date__c;
                APORefreshDate = e1[0].APO_Refresh_Date__c;
                system.debug('MRRefreshDate-->'+e1[0].MR_FED_Refresh_Date__c);
            }
            else{
            
                disp = true;             
                MRRefreshDate = null ;
                MRFEDRefreshDate = null ;
                SDFRefreshDate = null ;
                SIRefreshDate = null ;
                JuiceRefreshDate = null ;
                APORefreshDate = null ;
              //  system.debug('MRRefreshDate-->'+e1[0].MR_FED_Refresh_Date__c);
            
            
            
            
            }
          /*  if(AgrYear != null && AgrYear.size() > 0){
              disp = true; 
            }
            else{
                disp = false;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Data is Not Present for Selected Account and Selected Year'));           
            }*/
        }
       
    }

    Public class data{
        public Decimal v { get; private set; }
        public Decimal a { get; private set; }
        public Decimal b { get; private set; }
        public Decimal c { get; private set; }
        public Decimal d { get; private set; }
        public Decimal e { get; private set; }
        public Decimal t { get; private set; }
        public String n { get; private set; }              
        public String p { get; private set; }
        public String q { get; private set; }
        public String r { get; private set; }
        public String t1 { get; private set; }

           data(String n, Decimal v) {
            this.n = n;
            this.v = v;                       
        }
        data(String n, integer v,string p) {
           
            this.n = n;
            this.v = v;  
            this.p = p;                     
        }
        data(String t1,integer a , integer b, integer c){
            this.t1 = t1;
            this.a = a;
            this.b = b;
            this.c = c;      
       
        }  
        data(String t1,integer a , integer b, integer c, integer d, integer e){
          
            this.t1 = t1;
            this.a = a;
            this.b = b;
            this.c = c;
            this.d = d;
            this.e = e;
                 
       
        }
        data(integer t,String t1,integer a , integer b, integer c, integer d, integer e){
            this.t = t;
            this.t1 = t1;
            this.a = a;
            this.b = b;
            this.c = c;
            this.d = d;
            this.e = e;      
       
        }  
        data(String t1,integer a ,integer b,integer c, string p, string q,string r){
            this.t1 = t1;
            this.a = a;
            this.b = b;
            this.c = c;
            this.p = p; 
            this.q = q;
            this.r = r;       
       
        }
    }
    
/*------------------- Add data for Contribution Equipment Chart--------------------*/  
    public data[] getContributionEquipment() {
        if(disp == true && e != null){
            integer tot = Equip_MR + Equip_MRF + Hard;
            return new data[] {
                new data(String.valueof(zConvert.CurrencyToString(tot,'$')),Equip_MR,Equip_MRF,Hard,String.valueof(zConvert.CurrencyToString(Equip_MR,'$')),String.valueof(zConvert.CurrencyToString(Equip_MRF,'$')),String.valueof(zConvert.CurrencyToString(Hard,'$')))         
            };
        }
        else 
            return new data[]{};
     }
/*------------------  Add data for Equipment Sales Chart----------------------------*/  
     public data[] getEquipmentSales() {
        if(disp == true && e != null){
            integer tot = Equip_MR + Equip_MRF + Hard;
            return new data[] {
            new data('',Equip_MR,String.valueof(zConvert.CurrencyToString(Equip_MR,'$'))),
            new data(String.valueof(zConvert.CurrencyToString(tot,'$')),Equip_MRF ,String.valueof(zConvert.CurrencyToString(Equip_MRF,'$'))),
            new data('', Hard,String.valueof(zConvert.CurrencyToString(Hard,'$')))                    
            };
        }
        else 
            return new data[]{};
      }
/*------------------  Add data for Services Sales Chart----------------------------*/  
      public data[] getServiceSales() {
        if(disp == true && e != null){
           integer tot = SI_MR + SI_FED + SER_MR +SER_FED+ Ser_Juice;
            return new data[] {            
                new data('', SER_MR,String.valueof(zConvert.CurrencyToString(SER_MR,'$'))),
                new data('', SI_MR ,String.valueof(zConvert.CurrencyToString(SI_MR,'$'))),
                new data(String.valueof(zConvert.CurrencyToString(tot,'$')), SER_FED,String.valueof(zConvert.CurrencyToString(SER_FED,'$'))),
                new data('', SI_FED,String.valueof(zConvert.CurrencyToString(SI_FED,'$'))),
                new data('', Ser_Juice,String.valueof(zConvert.CurrencyToString(Ser_Juice,'$')))                      
            };
        }
        else 
            return new data[]{};
        }
/*------------------  Add data for Contribution Service Chart----------------------------*/  
        public data[] getContributionService() {
            if(disp == true && e != null){
                integer tot = SI_MR + SI_FED + SER_MR +SER_FED+ Ser_Juice;
                return new data[] {
                new data(String.valueof(zConvert.CurrencyToString(tot,'$')),SER_MR,SI_MR,SER_FED,SI_FED,Ser_Juice)           
                };
            }
            else 
                return new data[]{};
        }
/*------------------  Add data for Motorola Spend Chart----------------------------*/  
       public data[] getMotorolaSpend() {
        if(disp == true && e != null){
            integer tot = WT_tot+Main_tot+INST_tot+SF_tot+Grand_tot;
            return new data[] {
            new data('', WT_tot,String.valueof(zConvert.CurrencyToString(WT_tot,'$'))),
            new data('', Main_tot,String.valueof(zConvert.CurrencyToString(Main_tot,'$'))),
            new data(String.valueof(zConvert.CurrencyToString(tot,'$')),INST_tot,String.valueof(zConvert.CurrencyToString(INST_tot,'$'))),
            new data('', SF_tot,String.valueof(zConvert.CurrencyToString(SF_tot,'$'))),
            new data('', Grand_tot,String.valueof(zConvert.CurrencyToString(Grand_tot,'$')))          
            
            };
        }
        else 
            return new data[]{};
        }
/*------------------  Add data for Service Contribution Chart----------------------------*/  
        public data[] getServiceContribution() {
        if(disp == true && e != null){
            decimal a1,a2,a3,a4,a5;
            if(SER_MR >0 && Equip_MR >0){  
                 a1=((SER_MR)*100/(Equip_MR));
            }
            else{
                a1 = 0;
            }
            if(SI_MR  >0 && Equip_MR >0){
                a2=((SI_MR)*100/(Equip_MR));
                System.debug('A1---->'+a2);
            }
            else{
                a2 = 0;
            }
            if(SER_FED >0 && Equip_MRF >0){
                a3=((SER_FED)*100/(Equip_MRF));
                System.debug('A1---->'+a3);
            }
            else{
                a3 = 0;
            }
            if(SI_FED >0 && Equip_MRF >0){
                a4=((SI_FED)*100/(Equip_MRF));
                System.debug('A1---->'+a4);
            }
            else{
                a4 = 0;
            }
            if(Ser_Juice >0 && Hard >0){
                a5=((Ser_Juice)*100/(Hard));
                System.debug('A1---->'+a5);
            }
            else{
                a5 = 0;
            }
            System.debug('A1---->'+a1);
            System.debug('A1---->'+a2);
            System.debug('A1---->'+a3);
            System.debug('A1---->'+a4);
            System.debug('A1---->'+a5);
            return new data[] {
            new data('', a1),
            new data('', a2),
            new data('', a3),
            new data('', a4),
            new data('', a5)          
            
            };
        }
        else 
            return new data[]{};
        }
        
/*----------- -----------Trend charts-------------------------------- */ 
  
   
    public List<data> getServiceSalesbyYear() {
        List<data> data1 = new List<data>();
        List<data> data2 = new List<data>();
        if(disp == true && AgrYear != null){
             for(AggregateResult a:AgrYear){
             system.debug('###In ServicesSales'+a);
                  SI_MR = (integer.valueof(a.get('s1')) != null) ? integer.valueof(a.get('s1')) : 0 ;
                  SI_FED = (integer.valueof(a.get('s2')) != null) ? integer.valueof(a.get('s2')) : 0 ;
                  SER_MR = (integer.valueof(a.get('s3')) != null) ? integer.valueof(a.get('s3')) : 0 ;
                  SER_FED= (integer.valueof(a.get('s4')) != null) ? integer.valueof(a.get('s4')) : 0 ; 
                  Ser_Juice= (integer.valueof(a.get('s14')) != null) ? integer.valueof(a.get('s14')) : 0 ; 
                 integer tot =  SI_MR + SI_FED + SER_MR +SER_FED + Ser_Juice;
                 data1.add(new data(tot,String.valueof(a.get('Year__c')),SER_MR,SI_MR,SER_FED,SI_FED,Ser_Juice));          
              }
              return data1;
        }
        else {
            return data2;
        }
    }
    public List<data> getEquipmentSalesbyYear() {
        List<data> data1 = new List<data>();
        List<data> data2 = new List<data>();
        if(disp == true && AgrYear != null){
            for(AggregateResult a:AgrYear){
                Equip_MR= (integer.valueof(a.get('s11')) != null) ? integer.valueof(a.get('s11')) : 0 ;
                Equip_MRF= (integer.valueof(a.get('s12')) != null) ? integer.valueof(a.get('s12')) : 0 ;
                Hard= (integer.valueof(a.get('s13')) != null) ? integer.valueof(a.get('s13')) : 0 ;
                integer tot =  Equip_MR + Equip_MRF + Hard;
                data1.add(new data(String.valueof(a.get('Year__c')),Equip_MR,Equip_MRF,Hard));          
            }
        return data1;
        }
        else {
            return data2;
        }
    }
    public List<data> getServiceSpendbyYear() {
        List<data> data1 = new List<data>();
        List<data> data2 = new List<data>();
        if(disp == true && AgrYear != null && TrendData !=null){
            for(AggregateResult a:AgrYear){
                 WT_tot= (integer.valueof(a.get('s6')) != null) ? integer.valueof(a.get('s6')) : 0 ;
                 Main_tot= (integer.valueof(a.get('s7')) != null) ? integer.valueof(a.get('s7')) : 0 ;
                 INST_tot= (integer.valueof(a.get('s8')) != null) ? integer.valueof(a.get('s8')) : 0 ;
                 SF_tot= (integer.valueof(a.get('s9')) != null) ? integer.valueof(a.get('s9')) : 0 ;
                 Grand_tot= (integer.valueof(a.get('s10')) != null) ? integer.valueof(a.get('s10')) : 0 ;
                integer tot = WT_tot + Main_tot + INST_tot + SF_tot + Grand_tot;
                data1.add(new data(tot,String.valueof(a.get('Year__c')),WT_tot,Main_tot,INST_tot,INST_tot,Grand_tot));          
            }
            system.debug('*****data1'+data1);
            return data1;
        }
        else {
            return data2;
        }
    }
    public List<data> getServiceContributionbyYear() {
        List<data> data1 = new List<data>();
        List<data> data2 = new List<data>();
        if(disp == true && AgrYear != null){
            for(AggregateResult a:AgrYear){
                SER_MR = (integer.valueof(a.get('s3')) != null) ? integer.valueof(a.get('s3')) : 0 ;
                Equip_MR= (integer.valueof(a.get('s11')) != null) ? integer.valueof(a.get('s11')) : 0 ;
                SI_MR = (integer.valueof(a.get('s1')) != null) ? integer.valueof(a.get('s1')) : 0 ;
                SER_FED= (integer.valueof(a.get('s4')) != null) ? integer.valueof(a.get('s4')) : 0 ;
                Equip_MRF= (integer.valueof(a.get('s12')) != null) ? integer.valueof(a.get('s12')) : 0 ;
                SI_FED = (integer.valueof(a.get('s2')) != null) ? integer.valueof(a.get('s2')) : 0 ;
                Hard= (integer.valueof(a.get('s13')) != null) ? integer.valueof(a.get('s13')) : 0 ;
                Ser_Juice= (integer.valueof(a.get('s14')) != null) ? integer.valueof(a.get('s14')) : 0 ;
                WT_tot= (integer.valueof(a.get('s6')) != null) ? integer.valueof(a.get('s6')) : 0 ;
                Main_tot= (integer.valueof(a.get('s7')) != null) ? integer.valueof(a.get('s7')) : 0 ;
                INST_tot= (integer.valueof(a.get('s8')) != null) ? integer.valueof(a.get('s8')) : 0 ;
                SF_tot= (integer.valueof(a.get('s9')) != null) ? integer.valueof(a.get('s9')) : 0 ;
                Grand_tot= (integer.valueof(a.get('s10')) != null) ? integer.valueof(a.get('s10')) : 0 ;


                integer tot = WT_tot + Main_tot + INST_tot + SF_tot + Grand_tot;
                Integer a1,a2,a3,a4,a5;
                if(SER_MR >0 && Equip_MR >0){  
                 a1=((SER_MR)*100/(Equip_MR));
                }
                else{
                    a1 = 0;
                }
                if(SI_MR >0 && Equip_MR >0){
                    a2=((SI_MR)*100/(Equip_MR));
                    System.debug('A1---->'+a2);
                }
                else{
                    a2 = 0;
                }
                if(SER_FED >0 && Equip_MRF >0){
                    a3=((SER_FED)*100/(Equip_MRF));
                    System.debug('A1---->'+a3);
                }
                else{
                    a3 = 0;
                }
                if(SI_FED >0 && Equip_MRF >0){
                    a4=((SI_FED)*100/(Equip_MRF));
                    System.debug('A1---->'+a4);
                }
                else{
                    a4 = 0;
                }
                if(Ser_Juice >0 && Hard >0){
                    a5=((Ser_Juice )*100/(Hard));
                    System.debug('A1---->'+a5);
                }
                else{
                    a5 = 0;
                }
                    data1.add(new data(tot,String.valueof(a.get('Year__c')),a1,a2,a3,a4,a5));          
                }
                return data1;
            }
        else {
            return data2;
        }
    }             

}