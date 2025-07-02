trigger MaintenanceRequest on Case (before update, after update) {
    if(trigger.isUpdate && trigger.isAfter){
        MaintenanceRequestHelper.updateWorkOrders(trigger.new, trigger.oldMap); 
        System.debug('Trigger Passing Date Apex Class'+'\n'+
        'Trigger.new size'+'\t'+trigger.new.size()+'\n'+
        'Trigger.old size'+'\t'+trigger.old.size());
    }
}