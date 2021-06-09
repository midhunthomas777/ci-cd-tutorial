public class Bank {
    public string name='xyz';
        public string accountno='47733';
    Public String TransferAccountnumber='473773';
    public integer withdrawamount=500;
    public integer balance=1000;
    public integer AmountDeposit=1000;
    public integer salary=5000;
    public Decimal Intrestrate=8.5;
    public string street='32 butterbut lane';
    public string city='Newington';
    public string Country='india';
    public void withdraw(){
        if(balance >withdrawamount){
            integer balancetemp=balance-withdrawamount;
            balance=balancetemp;
            
        } 
        else{
            
        }
        
        
    }
    public void Deposit(){
        system.debug('Balance'+Balance);
        integer BalanceTemp=balance+amountdeposit;
       balance=balancetemp;
        system.debug('Balance'+balance);
        
    }
    Public Void Balance(){
        
    }
    

}