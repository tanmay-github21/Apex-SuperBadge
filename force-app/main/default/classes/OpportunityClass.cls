public with sharing class OpportunityClass {
    public static void createChildOpportunity(List<Opportunity> triggerOpty){
        SYstem.debug('Entered into apex class');
        List<Opportunity> opty=new list<opportunity>();
        for(Opportunity t1:triggerOpty){
            System.debug('Entered into for opportunity loop');
            opty.add(new opportunity(name=t1.Name+'Child-Opportunity',
                                    type='ECU',
                                    stageName='Prospecting',
                                    contactId=t1.contactId,
                                    accountId=t1.accountId,
                                    Description=t1.name+'Child Opportunity having parent id as'+'\t'+t1.Id,
                                    closeDate=t1.closedate.addMonths(5)));
        }
        upsert opty;
        System.debug('Inserted records'+'\t'+opty.size());
        system.debug('From Apex Class DML Statement Limit'+'\t'+Limits.getDmlStatements()+'\n'+
                    'From Apex class DML Rows'+'\t'+Limits.getDmlRows()+'\n'+
                    'From Apex class Heap size'+'\t'+limits.getHeapSize()+'\n'+
                    'From Apex class CPU Time'+'\t'+limits.getCpuTime());
    }
}