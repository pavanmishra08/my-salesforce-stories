trigger OrderTrigger on Order (before insert,after insert,before update,after update,after delete,before delete,after undelete) {
	if(Trigger.isBefore && Trigger.isInsert){
        System.debug('in before insert');
    } else if(Trigger.isAfter && Trigger.isInsert){
        OrderTriggerHandler.afterInsert(Trigger.new);
    } else if(Trigger.isBefore && Trigger.isUpdate){
        OrderTriggerHandler.beforeUpdate(Trigger.oldMap, Trigger.new);
    } else if(Trigger.isAfter && Trigger.isUpdate){
        OrderTriggerHandler.afterUpdate(Trigger.oldMap, Trigger.new);
    } else if(Trigger.isBefore && Trigger.isDelete){
        
    } else if(Trigger.isAfter && Trigger.isDelete){
        OrderTriggerHandler.afterDelete(Trigger.old);
    } else if(Trigger.isAfter && Trigger.isUndelete){
        OrderTriggerHandler.afterUndelete(Trigger.new);
    }
}