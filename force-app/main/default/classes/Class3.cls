public class Class3 {
    public static void method1(List<case>passedCases){
        Set<id>idSet=new set<Id>();
        List<case>parentCase=new List<case>();
        List<case>passedCase= new List<case>();
        map<string,Integer>passMethod2Map=method2(passedCases);
        map<ID,case>caseMap=new map<id,case>();
        for(Case loopcase:passedCases){
            if(loopcase.status=='Closed' && (loopCase.type=='Repair' || loopcase.type=='Routine Maintenance')){
                idSet.add(loopCase.Id);
            } else System.debug('No records found matching trigger criteria');
        }
        System.debug(idSet.size()+'\t'+'Method-1-Records found matching criteria');
        parentCase=[Select ID,origin,type,status,vehicle__c,contactId,(select equipment__c from Equipment_Maintenance_Items__r) from Case WHERE ID IN:idSet];
        for(case loopCase1:parentCase){
            Case tempCase1= new Case();
            tempCase1.parentId=loopCase1.Id;
            tempCase1.contactId=loopCase1.ContactId;
            tempCase1.Vehicle__c=loopCase1.Vehicle__c;
            tempCase1.origin=loopCase1.Origin;
            tempCase1.Type='Routine Maintenance';
            tempCase1.Status='New';
            tempCase1.Date_Reported__c=date.today();
            tempCase1.Case_Type__c='Child Case Of'+''+loopCase1.ID+''+loopCase1.caseNumber;
            if(passMethod2Map.get(loopCase1.Id)!=null)
                tempCase1.Date_Due__c=date.today()+passMethod2Map.get(loopCase1.Id);
            else tempCase1.date_Due__c=date.today();
            caseMap.put(loopCase1.Id,tempCase1);
        }//End of for loop for child case creation
        insert caseMap.values();
        map<string,string>returnProductMap=method3(caseMap.keyset());
        System.debug('Method-1 Child Case Inserted'+'\n'+'Limits Used - Queries'+'\t'+limits.getQueries()+'\n'+
                    'Limits Used - CPU Time'+'\t'+limits.getCputime()+'\n'+
                    'Limits Used - DML Rows'+'\t'+limits.getDmlRows());
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
            System.debug('Method2 to find Minimmum date received'+dueDate);
        }
        SYstem.debug('Method2 Aggregate Queries Count'+'\t'+limits.getAggregateQueries());
        return result; 
    }
    public static map<String,string>method3(set<ID>passedChildCaseIds){
        map<string,string>productMap=new map<string,string>();
        list<equipment_Maintenance_Item__c>items=[Select equipment__c, maintenance_request__r.parentId,
                                                  maintenance_request__r.parent.case_Type__c from equipment_Maintenance_Item__c
                                                  where equipment__c!=''];
        for(equipment_Maintenance_Item__c emi:items){
            if(passedChildCaseIds.contains(emi.maintenance_request__r.parentId)){
                System.debug('Product related to parent case '+'\t'+emi.Maintenance_Request__c+'Product is'+'\t'+
                            emi.Equipment__c+'\t'+emi.Equipment__r.name);
                productMap.put(emi.Maintenance_Request__c,emi.Equipment__c);
            }
            else System.debug('The product'+'\t'+emi.Equipment__r.name+'\t'+'dosen\'t belong to case'+'\t'+emi.Maintenance_Request__r.caseNumber);
        }
        return productMap;
    }
    
}