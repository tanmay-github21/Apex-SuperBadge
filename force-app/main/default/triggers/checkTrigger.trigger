trigger checkTrigger on Case (before insert, after insert, before update, after update) {
    if(trigger.isInsert && trigger.isAfter){
        System.debug('checkTrigger');
    }
}