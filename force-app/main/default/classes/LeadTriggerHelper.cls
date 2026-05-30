public class LeadTriggerHelper {
    /*
     * Write a trigger to create a follow up task 
     * when a lead's status change to Qualified
	*/
    public static void taskCreationOnLeadStatus(Map<Id,sObject> oldItem, List<sObject> newItem){
        List<Task> listOfFollowUpTask = new List<Task>();
        for(Lead l : (List<Lead>)newItem){
            Lead oldLead = (Lead)oldItem.get(l.Id);
            if(l.Status != oldLead.Status && l.Status == 'Closed - Converted'){
                Task t = new Task();
                t.WhoId = l.Id;
                t.OwnerId = l.OwnerId;
                t.Subject = 'Follow Up with Qualified Lead';
                t.Status = 'Not Started';
                t.Priority = 'High';
                t.ActivityDate = Date.today().addDays(1);
                
                listOfFollowUpTask.add(t);
            }
        }
        
        if(listOfFollowUpTask.size() > 0 && !listOfFollowUpTask.isEmpty()){
            insert listOfFollowUpTask;
        }
    }
    public static void updateOwnerInfo(Map<Id,sObject> oldItems, List<sObject> newItems){
        Set<Id> userIds = new Set<Id>();
        for(Lead l : (List<Lead>)newItems){
            if(l.OwnerId != null){
                userIds.add(l.OwnerId);
            }
        }
        
        Map<Id, User> userMap = new Map<Id,User>([SELECT Id, Email, Name
                                                  FROM User WHERE Id IN:userIds]);
        for(Lead l : (List<Lead>)newItems){
            if(l.OwnerId != null && userMap.containsKey(l.OwnerId)){
                l.Owner_Email__c = userMap.get(l.OwnerId).Email;
                l.Owner_Name__c = userMap.get(l.OwnerId).Name;
            }
        }
    }
}