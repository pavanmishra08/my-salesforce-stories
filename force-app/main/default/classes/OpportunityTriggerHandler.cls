public class OpportunityTriggerHandler {
    public static void beforeInsert(List<sObject> newItem){
        System.debug(JSON.serialize(newItem));
    }

    public static void beforeUpdate(Map<Id,sObject> oldItem, List<sObject> newItem){
        System.debug(JSON.serialize(newItem));
    }

    public static void afterInsert(List<sObject> newItem){
        System.debug(JSON.serialize(newItem));
        OpportunityTriggerHelper.updateOppAmount(newItem, null, null);
    }

    public static void afterUpdate(Map<Id,sObject> oldItem, List<sObject> newItem){
        System.debug(JSON.serialize(newItem));
        OpportunityTriggerHelper.updateOppAmount(newItem, null, oldItem);
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