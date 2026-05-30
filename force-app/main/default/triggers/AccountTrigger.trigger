trigger AccountTrigger on Account (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
    if(Trigger.isInsert && Trigger.isBefore){
        AccountTriggerHandler.generateAccountAutoNumber(Trigger.new);
        AccountTriggerHandler.dynamicAccountScoring(Trigger.new, null);
    } else if(Trigger.isUpdate && Trigger.isBefore){
        AccountTriggerHandler.dynamicAccountScoring(Trigger.new, Trigger.oldMap);
    }
}