public with sharing class Class2 {
    public static void method1(List<case>cases){
        Set<ID>idset= new set<ID> ();
        list<Case> c1= new list<Case>(); 
        list<Case> c2= new list<Case>(); 
        map<ID,case>caseMap=new map<Id,Case>(); 
        //map<String,Integer>minimumDateMap=returnMinimumDate(cases); 
        for(Case l1:cases){
            if(l1.Status=='Closed' && (l1.type=='Repair' || l1.type=='Routine Maintenance')){
                idset.add(l1.id);
            } 
        }
        System.debug('Apex Class Id Set Size'+'\t'+idset.size());
        //c1=[Select caseNumber,origin,type,status,contactId,vehicle__c,subject from case where ID=:idset];
        c1=[Select caseNumber,origin,type,status,contactId,contact.name,vehicle__c,vehicle__r.name from case where ID IN: idset];
        System.debug('Apex SOQL Records Found'+'\t'+c1.size());
        for(case temp:c1){
            case tp=new case(origin=temp.Origin,status='New',
                             contactId=temp.ContactId, vehicle__c=temp.Vehicle__c,
                             case_Type__c='Child Case Of'+'-'+temp.Id,
                             parentId=temp.ID,
                             Subject='Follow Up Maintenance Request for'+'-'+temp.contact.name+'\'s'+temp.Vehicle__r.name
                             /*if(minimumDateMap.get(temp.Id)!=null)tp.Date_Due__c=date.today()*/);
            
            caseMap.put(temp.ID,tp);
        }//Child case for loop
        upsert caseMap.values();
        for(case gt:caseMap.values()){
            if(string.isNotBlank(gt.parentId)){
                System.debug('Parent Record'+'\t'+gt.parentId+'\n'+
                            'Record Id'+'\t'+gt.Id);
            }
            else System.debug('Apex Class No Parent Records Found');
        }
    }//end of the method loop
    /*public static map<string,Integer> returnMinimumDate(List<case>passedCases){
        map<string,integer>result=new map<string,integer>(); 
        map<Id,case> caseMap=new map<id,case>(passedCases); 
        List<aggregateResult>agrResult=[select sourceProductId caseId, min(	Maintenance_Cycle__c) mincycle from Product2
                                       where sourceProductId IN:caseMap.keySet() group by sourceProductId];
        System.debug('Apex Class Aggregate result output'+'\t'+agrResult.size());
        for(AggregateResult agr:agrResult){
            Integer addDays=0;
            //Below line not required bcoz anyway even if one record is there we still have a record
            if(agr.get('mincycle')!=null){
                addDays+=Integer.valueof(agr.get('mincycle'));
                System.debug('From Apex Class Minimum'+'\t'+addDays);
            }
            else System.debug('From Apex Class Minimum method'+'\t'+'No minimum value found'); 
            result.put((string)agr.get('caseId'),addDays);
        }
        return result;
    }*/
    public static map<string,Integer>minimumDateMap2(list<case>passedCases){
        map<string,integer>minimumTimeMap=new map<string,integer>();
        map<id,Case>caseKeys=new map <id,Case>();
        list<case> parents=new list<case>();
        list<Equipment_Maintenance_Item__c> childs= new list<Equipment_Maintenance_Item__c>();
        List<case> minimumTime=[Select ID,(select Id, 
                                           equipment__r.Maintenance_Cycle__c 
                                           from Equipment_Maintenance_Items__r 
                                           where equipment__c!='' 
                                           order by equipment__r.maintenance_Cycle__c ASC LIMIT 1) 
                                from case where ID IN:passedCases];
        for(Case min:minimumTime){
             parents.add(min);
             childs.addAll(min.Equipment_Maintenance_Items__r);
             System.debug('For Case'+'\t'+'Minimum date is'+'\t'+min.equipment_maintenance_Items__r);
        }
        System.debug('DML Queries Issued'+'\t'+Limits.getQueries());   
        return null;
    }
}//end of the class loop