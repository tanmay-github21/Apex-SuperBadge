trigger MaintenanceRequest on Case (before update, after update) {
    list<case> casesToBeProcessed=new list<case>();
    if(trigger.isUpdate && trigger.isAfter){
        for(Case newcase: trigger.new){
            Case oldcase=trigger.oldMap.get(newcase.ID); 
            if(oldcase.Status!='Closed' && newcase.Status=='Closed' && (newcase.Type=='Repair' || newcase.Type=='Routine Maintenance')){
                casesToBeProcessed.add(newcase);
                SYstem.debug('Trigger case type check did match the requirements');
            }
            else system.debug('Trigger case type check didnt match the requirements');
        }
    }
    System.debug('From trigger case records passed to apex class and size is'+'\t'+casesToBeProcessed.size());
    MaintenanceRequestHelper.updateWorkOrders(casesToBeProcessed, trigger.oldMap); 
    System.debug('From trigger case records passed to apex class and size is'+'\t'+casesToBeProcessed.size());
}