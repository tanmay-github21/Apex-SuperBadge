public with sharing class challenge1 {
    public static void updateWorkOrders(list<case> newList, map<id,Case> oldMap){
        list<case>updatedCases=new list<case>();
        list<case>followupCases=new list<case>();
        map<string, integer> minimumDateMap= method2(newList);
        map<id,case> caseMap=new map<id,case>();
        set<ID> updatedCaseIds= new map <Id,case>(newList).keySet();
        System.debug('From Apex Class'+'\t'+'updatedCaseIds size'+'\t'+updatedCaseIds.size());
        updatedCases=[Select vehicle__c,caseNumber, (select equipment__c from Equipment_Maintenance_Items__r) from case WHERE ID IN:updatedCaseIds];
        for(case tempCase:updatedCases){
            case c= new case();
            c.ParentId=tempcase.Id;
            c.Vehicle__c=tempCase.Vehicle__c;
            c.Type='Routine Maintenance';
            c.Status='New';c.Date_Reported__c=date.today();
            c.Case_Type__c='Child Of'+'\t'+tempcase.CaseNumber;
            if(minimumDateMap.get(tempCase.Id)!=null)
                c.Date_Due__c=date.today()+minimumDateMap.get(tempCase.Id); else c.Date_Due__c=date.today();
            caseMap.put(tempCase.Id,c);
        }
        upsert caseMap.values();
        list<Equipment_Maintenance_Item__c> emi=new list<Equipment_Maintenance_Item__c>(); 
        for(case tempCase:updatedCases){
            case child= caseMap.get(tempCase.Id);
            if(tempCase.equipment_maintenance_Items__r !=null){
                for(Equipment_Maintenance_Item__c oldItem:tempCase.equipment_maintenance_Items__r){
                    Equipment_Maintenance_Item__c newItem= new Equipment_Maintenance_Item__c();
                    newItem.Equipment__c=oldItem.Equipment__c;
                    newItem.Maintenance_Request__c=child.Id;
                    emi.add(newItem);
                }
            }
        }
        insert emi; 
    }
    public static map<string,integer> method2(list<case> miniumDateCaseList){
        integer addDays=0;
        date currentDate=date.today(), dueDate=null;
        map<string,integer>result=new map<string,integer>();
        map<id,case> caseMap=new map<id,case>(miniumDateCaseList);
        list<AggregateResult> results=[select maintenance_Request__c caseId,
                                      min(equipment__r.maintenance_Cycle__c) minimumDays
                                      from equipment_Maintenance_Item__c where equipment__c!='' and
                                      maintenance_Request__c IN: caseMap.keySet()
                                      GROUP BY maintenance_Request__c];
        for(aggregateResult agr: results){
            addDays+=Integer.valueof(agr.get('minimumDays'));
            dueDate=currentDate.addDays(addDays);
            result.put((string)agr.get('caseId'),addDays);
            System.debug('ApexClass method2 calculated'+dueDate);
        }
        SYstem.debug('ApexClass method2 aggregate Queries Count'+'\t'+limits.getAggregateQueries());
        return result;
    }
}