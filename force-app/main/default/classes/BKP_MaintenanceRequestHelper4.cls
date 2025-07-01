//For original Code refer to Bkp_MaintenanceRequestHelper3
public with sharing class BKP_MaintenanceRequestHelper4{
     public static void updateWorkOrders(List<case>passedCases){
         set<id> idSet=new set<id>();
         map<string,Integer>passMethod2Map=returnMinimumdate(passedCases);
         map<ID,case>caseMap=new map<id,case>();
         List<case>parentCase;
         try{
             for(case tempCase:passedCases){
                 if(tempCase.status=='Closed' && (tempCase.Type=='Repair' || tempCase.type=='Routine Maintenance')){
                     idSet.add(tempCase.Id); 
                 }//first if block inside for
             }//first for loop inside try
             System.debug(idSet.size()+'\t'+'records matched triggering criteria');
             parentCase=[Select origin,status,type,contactId,vehicle__c, productId from case where id IN:idSet];
             System.debug(parentCase.size()+'\t'+'Parent Cases Found');
             for(Case tempCase2:parentCase){
                 Case c= new Case();
                 c.Origin=tempcase2.Origin;
                 c.type='Routine Maintenance';
                 c.Status='New';
                 c.Vehicle__c=tempCase2.Vehicle__c;
                 c.ContactId=tempCase2.ContactId;
                 c.ParentId=tempCase2.id;
                 c.Case_Type__c='Child-Case Of'+'-'+tempCase2.Id;
                 c.Subject='Follow Up Maintenance Request For'+'-'+tempCase2.contact.name+'-'+tempCase2.Vehicle__r.Name; 
                 c.Date_Reported__c=date.today();
                 if(passMethod2Map.get(tempCase2.Id)!=null)
                     c.Date_Due__c=date.today()+passMethod2Map.get(tempCase2.Id);
                 else c.Date_Due__c=date.today();
                 caseMap.put(tempCase2.Id,c);
                 SYstem.debug(caseMap.size()+'\t'+'Child records');
             }//Second for loop
             upsert caseMap.values();
         }//end block of try
         catch(exception e){}
     }    
    public static map<string,Integer> returnMinimumdate(list<case>passedCases1){
        
        Integer addDays=0;
        date currentDate=date.today(), dueDate=null;
        map<string,Integer>result=new map<string,Integer>();
        map<Id,case>caseMap= new map<id,case>(passedCases1);
        List<aggregateResult> aggregates=[Select maintenance_Request__c caseID, 
                                         min(equipment__r.maintenance_Cycle__c) minDays
                                         from equipment_Maintenance_Item__c Where equipment__c!='' and 
                                         maintenance_Request__c IN:caseMap.keySet() Group BY maintenance_Request__c];
        for(AggregateResult agr:aggregates){
            addDays+=Integer.valueOf(agr.get('minDays'));
            dueDate=currentDate.addDays(addDays);
            result.put((string)agr.get('caseID'),addDays);
            System.debug('Minimmum date received'+dueDate);
        }
        return result; 
    }
}