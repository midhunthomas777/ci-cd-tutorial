public class Apex3 {
    public Consultant__c insertcc(string Sname,string Skill ){
        Consultant__c cc=new Consultant__c();
cc.name=sname;
cc.SkillSet__c=skill;
insert cc;
 return cc;       
        
       

        
    }

}