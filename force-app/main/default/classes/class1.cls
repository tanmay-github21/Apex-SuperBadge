public class class1 {
    public static void method1(list<case>cases){
        List<case> c1,c2,c3,c4; 
        set<ID> idSet=new set<ID> ();
        for(case temp:cases){
            if(temp.Status=='Closed' && (temp.type=='Repair' || temp.Type=='Routine Maintenance')){
                 idSet.add(temp.ID);
                 System.debug('Clas-Trigger conditions matched');
            }
            if(!idSet.isEmpty()){
                System.debug('Idset isnt blank'+'\t'+idSet.size());
                c1=new list<case>();
                for(Case temp1:[Select type,origin,status,vehicle__c,vehicle__r.name,contactID,date_Reported__c,subject,parentId from case 
                                where id IN:idSet]){
                                    Case c= new case(type='Routine Maintenance',status='New',
                                                    origin='Web',contactId=temp1.ContactId,
                                                    vehicle__c=temp1.Vehicle__c,
                                                    date_Reported__c=date.today(),
                                                    Subject='Child Case'+''+temp1.id+''+'Contact Name'+contact.name+temp1.vehicle__r.name);
                                    c1.add(c);
                                    
                                }
            }
            upsert c1; 
            for(case d:c1)
            {
                if(!string.isEmpty(d.ParentId) && string.isNotBlank(d.parentID)){
                    System.debug('class child id'+'\t'+d.id);
                }
                else System.debug('The child case doesnt have a parent');
            }
        }
    }
}