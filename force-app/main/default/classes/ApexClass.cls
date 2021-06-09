public class ApexClass {
    public string name='Thomas';
    public string AccountNumber='1234884';
    public string TransferAccount='123t';
    public integer TransferAmount=500;
    public string branch='xyz';
    Public integer balance=100;
    Public Integer AmountDeposited =1000;
    public integer withdrawamount=500;
    Public decimal intrestrare=9.85;
        public string street='32 butternut lane';
    public string city='Neington';
    public string State='ct';
    public string Contry='usa';
    
    public void Deposit(){
        system.debug('balance'+Balance);
            integer intialbalance=balance+AmountDeposited;
            balance=intialbalance;
        system.debug('Balanc'+balance);
            
        }
    public void Withdraw(){
        if(balance > withdrawamount){
            integer balancetemp=balance-withdrawamount;
            balance=balancetemp;
        }
        
    }
    public void Trasfer(){
        if(TransferAccount=='123t' ){
            if(balance>TransferAmount){
                balance=balance-TransferAmount;
            }
        }
        
           
           
           
           }
           }