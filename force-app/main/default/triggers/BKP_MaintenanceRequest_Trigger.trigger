trigger BKP_MaintenanceRequest_Trigger on Case (before update, after update) {
    List<case> caseList=new List<case>();
    if(trigger.isUpdate && trigger.isAfter){
        System.debug('Inside the trigger');
        for(Case c1:trigger.new){
            if(c1.IsClosed==true && (c1.Type=='Routine Maintenance' || c1.type=='Repair')){
                System.debug('Case is closed and its type is'+'\t'+c1.type); 
            }//check for type of thecase
            caseList.add(c1);
        }//Outer for loop Checks contact with trigger.new
        SYstem.debug('Passing the refined case list to BKP_MaintenanceRequestHelper class');
        BKP_MaintenanceRequestHelper.updateWorkOrders(caseList);
    } //end of If loop (operation check)
}