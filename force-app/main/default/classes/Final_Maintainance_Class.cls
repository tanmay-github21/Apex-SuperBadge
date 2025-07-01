//This class Insert Child case records with the exact due date inserted into child case record.
public with sharing class Final_Maintainance_Class{
     public static void updateWorkOrders(List<case>passedCases){
     set<id>idSet=new set<id>();
     list<case>parentCase;
     map<string,integer>passMethod2Map=method2(passedCases);
     map<id,Case>caseMap=new map<id,Case>();
     try{
        for(Case c:passedCases){
           if(c.status=='Closed' && (c.type=='Repair'||c.type=='Routine Maintenance')){
               idSet.add(c.Id);
           }
           else {System.debug('No records were found that matched the trigerring condition');}
        }
        System.debug(idSet.size()+'records found matching trigger criteria');
        parentcase=[Select ID,origin,type,status,vehicle__c,contactId,productId from Case WHERE ID IN:idSet];
        for(case loopCase1:parentCase){
            case tempCase1=new case();
            tempCase1.parentId=loopCase1.Id;
            tempCase1.contactId=loopCase1.ContactId;
            tempCase1.Vehicle__c=loopCase1.Vehicle__c;
            tempCase1.origin=loopCase1.Origin;
            tempCase1.Type='Routine Maintenance';
            tempCase1.Status='New';
            tempCase1.Date_Reported__c=date.today();
            tempCase1.Case_Type__c='Child Case Of'+''+loopCase1.ID;
            if(passMethod2Map.get(loopCase1.Id)!=null)
            tempCase1.date_Due__c=date.today()+passMethod2Map.get(loopCase1.Id);
            else tempCase1.date_Due__c=date.today();
            caseMap.put(loopCase1.Id,tempCase1);
            insert caseMap.values();
        }
     }
     catch(exception e){
       
     }
     }
     public static map<string,Integer> method2(List<case>method1Cases){
        Integer addDays=0;
        date currentDate=date.today(), dueDate=null;
        map<string,Integer>result=new map<string,Integer>();
        map<Id,case>caseMap= new map<id,case>(method1Cases);
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
        SYstem.debug('Aggregate Queries Count'+'\t'+limits.getAggregateQueries());
        return result; 
    }
}