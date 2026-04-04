public class ContactTriggerHelper {
    public static void checkDuplicates(List<sObject> newItems, Map<Id, sObject> newItemsMap){
        Set<String> emailList = new Set<String>();
        Set<String> existingEmailList = new Set<String>();
        List<Contact> conList = new List<Contact>();
        if(newItems != null){
            for(Contact c : (List<Contact>)newItems){
                if(c.Email != null){
                    emailList.add(c.Email.toLowerCase());
                }
        	}
        }
        if(Trigger.isInsert && Trigger.isBefore){
            conList = [
                SELECT Id, Email FROM Contact WHERE Email IN: emailList
            ];
        } else{
            conList = [
                SELECT Id, Email FROM Contact WHERE Email IN: emailList AND Id NOT IN: newItemsMap.keySet()
            ];
        }
        if(conList.size() > 0){
            for(Contact c : conList){
                existingEmailList.add(c.Email.toLowerCase());
            }
        }
        for(Contact c : (List<Contact>)newItems){
            if(c.Email != null && existingEmailList.contains(c.Email.toLowerCase())){
                c.Email.addError('Contact with same Email already present');
            }
        }
    }
}