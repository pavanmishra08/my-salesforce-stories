public class LeadTriggerHandler {
	public static void beforeInsert(List<sObject> newItem){
        System.debug(JSON.serialize(newItem));
        LeadTriggerHelper.updateOwnerInfo(null, newItem);
    }

    public static void beforeUpdate(Map<Id,sObject> oldItem, List<sObject> newItem){
        System.debug(JSON.serialize(newItem));
        LeadTriggerHelper.updateOwnerInfo(oldItem, newItem);
    }

    public static void afterInsert(List<sObject> newItem){
        System.debug(JSON.serialize(newItem));
    }

    public static void afterUpdate(Map<Id,sObject> oldItem, List<sObject> newItem){
        System.debug(JSON.serialize(newItem));
        LeadTriggerHelper.taskCreationOnLeadStatus(oldItem,newItem);
    }

    public static void afterDelete(List<sObject> oldItem){
        System.debug(JSON.serialize(oldItem));
    }

    public static void afterUndelete(List<sObject> newItem){
        System.debug(JSON.serialize(newItem));
    }
}