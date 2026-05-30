public class OrderTriggerHandler {
	public static void beforeInsert(List<sObject> newItem){
        System.debug(JSON.serialize(newItem));
    }

    public static void beforeUpdate(Map<Id,sObject> oldItem, List<sObject> newItem){
        System.debug(JSON.serialize(newItem));
    }

    public static void afterInsert(List<sObject> newItem){
        System.debug(JSON.serialize(newItem));
        OrderTriggerHelper.updateLastOrderDateOnAccount(newItem);
    }

    public static void afterUpdate(Map<Id,sObject> oldItem, List<sObject> newItem){
        System.debug(JSON.serialize(newItem));
    }

    public static void afterDelete(List<sObject> oldItem){
        System.debug(JSON.serialize(oldItem));
    }

    public static void afterUndelete(List<sObject> newItem){
        System.debug(JSON.serialize(newItem));
    }
}