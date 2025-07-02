public with sharing class challenge1 {
    public static void method1(list<case> newList, map<id,Case> oldMap){
        list<case>childCases=new list<case>();
        list<Equipment_Maintenance_Item__c> newEquipItems= new list<Equipment_Maintenance_Item__c>(); 
        set<ID> equipmentIds=new set<ID>();
        for(case req: newList){
            case oldCase=oldMap.get(req.ID);
            if(oldCase.status !='Closed' && req.status=='Closed' && 
            (req.status=='Repair' || req.status=='Routine Maintenance')){
                equipmentIds.add(req.ID);
            }
            else System.debug('The case status arent of the required type');
        }
        if(!equipmentIds.isEmpty()){
            newEquipItems=[select type,
                                  vehicle__c,
                                  origin, status,
                                  (select equipment__c from Equipment_Maintenance_Items__r) 
                                  from case where ID IN: equipmentIds]; 
            System.debug('Equipment items size'+'\t'+newEquipItems.size()); 
        }
        for(case c1: newEquipItems){
            case c= new case();
            c.parentId=c1.id;
            c.type='Routine Maintenance';
            c.vehicle__c=c1.vehicle__c;
        }
    }
}