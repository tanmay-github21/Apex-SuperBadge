public with sharing class challenge1 {
    public static void method1(list<case> newList, map<id,Case> oldMap){
        list<case>newRequests=new list<case>();
        list<Equipment_Maintenance_Item__c> newEquipItems= new list<Equipment_Maintenance_Item__c>(); 
        set<ID> equipmentIds=new set<ID>();
        for(case req: newList){
            case oldCase=oldMap.get(req.ID);
            System.debug('Within For Loop'+'\t'+'oldCase Casenumber'+'\t'+oldCase.caseNumber);
            if(oldCase.status !='Closed' && req.status=='Closed' && 
            (req.status=='Repair' || req.status=='RoRoutine Maintenance')){
                 equipmentIds.add(req.id);
            }
            else System.debug('Case closed earlier');
            if(!equipmentIds.isEmpty()){
                newEquipItems=[];
            }
        }
    }
}