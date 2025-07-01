public with sharing class BKP_MaintenanceRequestHelper {
    public static void updateWorkOrders(list<case>triggerCase){
        System.debug('Entered Into BKP_MaintenanceRequestHelper updateWorkOrders method');
        List<case>followupCases=new list<case>();
        for(case c:triggerCase)
        {
			followupCases.add(new case(type='Routine Maintenance',
                                      vehicle__c=c.Vehicle__c,
                                      contactId=c.ContactId,
                                      accountId=c.AccountId,
                                      subject='Follow-Up Maintenance On Your'+'\t'+c.Vehicle__r.Name,
                                      status='New',
                                      origin='Web',parentId=c.Id,
                                      date_reported__c=date.today()));           
        }
        upsert followupCases;
        System.debug('Child records created'+'\t'+followupCases.size());
        system.debug('From Apex Class DML Statement Limit'+'\t'+Limits.getDmlStatements()+'\n'+
                    'From Apex class DML Rows'+'\t'+Limits.getDmlRows()+'\n'+
                    'From Apex class Heap size'+'\t'+limits.getHeapSize()+'\n'+
                    'From Apex class CPU Time'+'\t'+limits.getCpuTime());
    }
}