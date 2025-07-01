public class BKP_Case_Class {
    public static void updateWorkOrders(list<case>triggerCase){
        System.debug('Entered Into BKP_MaintenanceRequestHelper updateWorkOrders method');
        List<case>followupCases=new list<case>();
        for(case l:[select caseNumber,contactId, vehicle__c,productId from case where id IN:triggerCase]){
            SYstem.debug('Case Found'+'\t'+l.caseNumber+'\t'+'Vehicle'+'\t'+l.vehicle__r.name+'\t'+'Equipment'+'\t'+l.product.name);
                case fc= new case(status='New',
                type='Routine Maintenance',
                vehicle__c=l.Vehicle__c,
                origin='Web',                  
                Date_Reported__c=date.today(),                  
                Subject='Followup Maintainace on your'+''+l.Vehicle__r.Name,
                case_Type__c='Demo-Update',
                parentId=l.Id); 
            followupCases.add(fc);
        }
        //upsert followupCases;
        //System.debug('Apex Class Child Case'+'\t'+followupCases[0].ID);
    }//end of method
}