public with sharing class BKP_MaintenanceHelper2{
    public static void method1(list<case>caseList){
        System.debug('Entered into method'); 
        List<case> childCase;
        set<Id> validIds=new set<ID>();
        for(case tempCase: caseList){
            if(tempCase.status=='Closed' && (tempCase.type=='Repair' || tempCase.Type=='Routine Maintenace')){
                System.debug('Case is closed'+'\t'+tempCase.type);
                validIds.add(tempCase.Id);
            }
        }
        if(!validIds.isEmpty()){
            SYstem.debug('ValidId has Ids in it and its size is'+'\t'+validIds.size());
            for(case temp2:[Select type,
                           origin, status, contactId, accountid,
                           parentId, vehicle__c, vehicle__r.name,date_Reported__c,
                           subject from case where ID IN:validIds]){
                               childCase= new list<case>();
                               Case c= new case(type='Repair Maintenance',
                                               origin=temp2.Origin,
                                               status='New',
                                               contactId=temp2.Id,
                                               accountId=temp2.accountId,
                                               parentId=temp2.parentId,
                                               subject='Follow-Up Maintenance Request For Your Vehicle'+'\t'+temp2.Vehicle__r.Name,
                                               date_Reported__c=date.today(),
                                               vehicle__c=temp2.Vehicle__c); 
                               childCase.add(c);
                               System.debug('Child Case size when not inserted'+'\t'+childCase.size());
                               
                           
        }//Check if validIdsSet is empty
    }
    upsert childCase; 
        system.debug('From Apex Class DML Statement Limit'+'\t'+Limits.getDmlStatements()+'\n'+
                    'From Apex class DML Rows'+'\t'+Limits.getDmlRows()+'\n'+
                    'From Apex class Heap size'+'\t'+limits.getHeapSize()+'\n'+
                    'From Apex class CPU Time'+'\t'+limits.getCpuTime());    
                    //comments added to see if it can be pushed to origin or not    
                    //FGRT_GHTY_KLO_5684_13_45_46
}
}