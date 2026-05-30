public class OpportunityTriggerHandler {
    public static void beforeInsert(List<sObject> newItem){
        System.debug(JSON.serialize(newItem));
        OpportunityTriggerHelper.comprehensiveValidationTrigger(null,newItem);
    }

    public static void beforeUpdate(Map<Id,sObject> oldItem, List<sObject> newItem){
        System.debug(JSON.serialize(newItem));
        OpportunityTriggerHelper.comprehensiveValidationTrigger(oldItem,newItem);
    }

    public static void afterInsert(List<sObject> newItem){
        System.debug(JSON.serialize(newItem));
        OpportunityTriggerHelper.updateOppAmount(newItem, null, null);
        OpportunityTriggerHelper.sendEmailNotification(newItem);
    }

    public static void afterUpdate(Map<Id,sObject> oldItem, List<sObject> newItem){
        System.debug(JSON.serialize(newItem));
        OpportunityTriggerHelper.updateOppAmount(newItem, null, oldItem);
        OpportunityTriggerHelper.updateOpportunityLineItem(newItem, oldItem);
    }

    public static void afterDelete(List<sObject> oldItem){
        System.debug(JSON.serialize(oldItem));
        OpportunityTriggerHelper.updateOppAmount(null, oldItem, null);
    }

    public static void afterUndelete(List<sObject> newItem){
        System.debug(JSON.serialize(newItem));
        OpportunityTriggerHelper.updateOppAmount(newItem, null, null);
    }
}