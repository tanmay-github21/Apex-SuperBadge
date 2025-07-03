trigger MaintenanceRequest on Case (before update, after update) {
    /*if(trigger.isUpdate && trigger.isAfter){
        MaintenanceRequestHelper.updateWorkOrders(trigger.new, trigger.oldMap); 
        System.debug('Trigger Passing Date Apex Class');
    }*/
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
    //challenge1.method1(trigger.new, trigger.oldMap);
    System.debug('From trigger case records passed to apex class and size is'+'\t'+casesToBeProcessed.size());
    challenge1.method1(casesToBeProcessed, trigger.oldMap);
    System.debug('From trigger case records passed to apex class and size is'+'\t'+casesToBeProcessed.size());
}