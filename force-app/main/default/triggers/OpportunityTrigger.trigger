trigger OpportunityTrigger on Opportunity (before insert, before update, after insert, 
                                           after update, before delete, after delete, after undelete) {
    if(Trigger.isBefore && Trigger.isInsert){
        System.debug('in before insert');
    } else if(Trigger.isAfter && Trigger.isInsert){
        OpportunityTriggerHandler.afterInsert(Trigger.new);
    } else if(Trigger.isBefore && Trigger.isUpdate){
        OpportunityTriggerHandler.beforeUpdate(Trigger.oldMap, Trigger.new);
    } else if(Trigger.isAfter && Trigger.isUpdate){
        OpportunityTriggerHandler.afterUpdate(Trigger.oldMap, Trigger.new);
    } else if(Trigger.isBefore && Trigger.isDelete){
        
    } else if(Trigger.isAfter && Trigger.isDelete){
        OpportunityTriggerHandler.afterDelete(Trigger.old);
    } else if(Trigger.isAfter && Trigger.isUndelete){
        OpportunityTriggerHandler.afterUndelete(Trigger.new);
    }
	
}