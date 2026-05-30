trigger LeadTrigger on Lead (before insert, before update, after insert, 
                                           after update, before delete, after delete, after undelete) {
	if(Trigger.isBefore && Trigger.isInsert){
        System.debug('in before insert');
        LeadTriggerHandler.beforeInsert(Trigger.new);
    } else if(Trigger.isAfter && Trigger.isInsert){
        LeadTriggerHandler.afterInsert(Trigger.new);
    } else if(Trigger.isBefore && Trigger.isUpdate){
        LeadTriggerHandler.beforeUpdate(Trigger.oldMap, Trigger.new);
    } else if(Trigger.isAfter && Trigger.isUpdate){
        LeadTriggerHandler.afterUpdate(Trigger.oldMap, Trigger.new);
    } else if(Trigger.isBefore && Trigger.isDelete){
        
    } else if(Trigger.isAfter && Trigger.isDelete){
        LeadTriggerHandler.afterDelete(Trigger.old);
    } else if(Trigger.isAfter && Trigger.isUndelete){
        LeadTriggerHandler.afterUndelete(Trigger.new);
    }
}