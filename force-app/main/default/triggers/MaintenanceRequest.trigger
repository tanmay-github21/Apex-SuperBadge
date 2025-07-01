trigger MaintenanceRequest on Case (before update, after update) {
    /*if(trigger.isUpdate && trigger.isAfter){
        MaintenanceRequestHelper.updateWorkOrders(trigger.new, trigger.oldMap); 
        System.debug('Trigger Passing Date Apex Class');
    }*/
    Class3.method1(trigger.new);
    System.debug('From trigger'+'\t'+'Passed to apex class'); 
}