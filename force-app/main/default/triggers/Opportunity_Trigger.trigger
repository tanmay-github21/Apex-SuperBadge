trigger Opportunity_Trigger on Opportunity (after insert, after update) {
    List<opportunity> ol=new list<opportunity>(); 
    if(trigger.isUpdate && trigger.isAfter){
        System.debug('Trigger operation matches');
        for(Opportunity temp:trigger.new){
            if(temp.StageName=='Prospecting' && (temp.Type=='NC' || temp.Type=='ECR')){
                ol.add(temp);
                SYstem.debug('Condition matched for passing to apex class'+'\t'+temp.stageName+'\t'+temp.type);
            }
        }
        System.debug('Passing Opportunity to Apex class existing trigger'); 
        opportunityClass.createChildOpportunity(ol);
    }
}