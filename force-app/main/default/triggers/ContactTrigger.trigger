trigger ContactTrigger on Contact (before insert, before update, after insert, after update, before delete, 
                                   after delete, after undelete) {
                                       if(Trigger.isInsert && Trigger.isBefore){
                                           ContactTriggerHelper.checkDuplicates(Trigger.new, Trigger.newMap, Trigger.oldMap);
                                           ContactTriggerHelper.ContactDemographicsLifecycle(Trigger.new, Trigger.newMap, Trigger.oldMap);
                                       } else if(Trigger.isUpdate && Trigger.isBefore){
                                           ContactTriggerHelper.checkDuplicates(Trigger.new, Trigger.newMap, Trigger.oldMap);
                                           ContactTriggerHelper.ContactDemographicsLifecycle(Trigger.new, Trigger.newMap, Trigger.oldMap);
                                       } else if(Trigger.isUpdate && Trigger.isAfter){
                                           ContactTriggerHelper.ContactCountUpdateOnAccount(Trigger.oldMap, Trigger.old, Trigger.new);
                                       } else if(Trigger.isInsert && Trigger.isAfter){
                                           ContactTriggerHelper.ContactCountUpdateOnAccount(Trigger.oldMap, Trigger.old, Trigger.new);
                                       } else if(Trigger.isDelete && Trigger.isAfter){
                                           ContactTriggerHelper.ContactCountUpdateOnAccount(Trigger.oldMap, Trigger.old, Trigger.new);
                                       } else if(Trigger.isUndelete && Trigger.isAfter){
                                           ContactTriggerHelper.ContactCountUpdateOnAccount(Trigger.oldMap, Trigger.old, Trigger.new);
                                       }
}