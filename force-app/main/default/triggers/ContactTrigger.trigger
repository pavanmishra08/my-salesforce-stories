trigger ContactTrigger on Contact (before insert, before update, after insert, after update, before delete, 
                                   after delete, after undelete) {
                                       if(Trigger.isInsert && Trigger.isBefore){
                                           ContactTriggerHelper.checkDuplicates(Trigger.new, Trigger.newMap);
                                       } else if(Trigger.isUpdate && Trigger.isBefore){
                                           ContactTriggerHelper.checkDuplicates(Trigger.new, Trigger.newMap);
                                       }
}