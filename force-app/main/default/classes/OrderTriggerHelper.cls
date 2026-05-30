public class OrderTriggerHelper {
	/*
	 * Write a trigger to update the "Last Order Date" field on Account when a new order is created.
	*/
    public static void updateLastOrderDateOnAccount(List<sObject> newItem){
        Set<Id> accountId = new Set<Id>();
        List<Account> accList = new List<Account>();
        for(Order o : (List<Order>)newItem){
            accountId.add(o.AccountId);
        }
        
        /*for(Account acc : [SELECT Id, Last_Order_Date__c FROM Account WHERE Id IN:accountId]){
            acc.Last_Order_Date__c = Date.today();
            accList.add(acc);
        }*/
        for(Id accId : accountId){
            Account acc = new Account();
            acc.Id = accId;
            acc.Last_Order_Date__c = Date.today();
            accList.add(acc);
        }
        
        if(!accList.isEmpty()){
            update accList;
        }
    }
}