//this case will show the lowest date for the maintenance cycle
public class Class4 {
    public static void method1(List<case>passedRecords){
        Integer days=0;
        map<String,Integer> caseMinimumValue=new map<string,Integer>();
        list<equipment_Maintenance_Item__c>itemList= [select ID, maintenance_Request__c,
                                  equipment__r.maintenance_Cycle__c from
                                  equipment_Maintenance_Item__c 
                                  where equipment__c!='' and maintenance_Request__c IN:passedRecords
                                  order by equipment__r.maintenance_Cycle__c ASC Limit 1];
        for(equipment_Maintenance_Item__c emi:itemList){
            string recId=emi.Id;
            days+=Integer.valueof(emi.Equipment__r.Maintenance_cycle__c);
            caseminimumValue.put(emi.Maintenance_Request__c,days);
        }
            
    }
    public static map<string,string> method2(list<ID>passedCases2){
        SYstem.debug('Method executed');
        map<string,string> productMap=new map<string,string>();
        List<equipment_Maintenance_Item__c>itemList=[select ID,equipment__c,maintenance_request__c from equipment_Maintenance_Item__c
                                        where equipment__c!=''];
        for(equipment_Maintenance_Item__c emi:itemList){
            if(passedCases2.contains(emi.Maintenance_Request__c)){
                System.debug('Passed list has related products');
                productMap.put(emi.Maintenance_Request__c,emi.Equipment__c);
                System.debug(productMap.values()+'\t'+productMap.keyset());
            }
            else System.debug('The product'+'\t'+emi.Equipment__r.name+'\t'+'dosen\'t belong to case'+'\t'+emi.Maintenance_Request__r.caseNumber);
        }
        return productMap;
    }
    public static void method3(List<case>cases12)
    {
        
    }
}