public class AccountTriggerHandler {
    //Write a trigger to generate custom auto-number for accounts with format "ACC-YYYY-NNNN"
    public static void generateAccountAutoNumber(List<sObject> newItems){
        Integer currentYear = Date.today().year();
        String accNumber = 'ACC-'+String.valueOf(currentYear)+'-%';
        List<Account> accList = [SELECT Id, Account_Number__c FROM Account 
                                 WHERE Account_Number__c 
                                 LIKE: accNumber
                                 ORDER BY CreatedDate DESC LIMIT 1];
        Integer nextNumber = 1;
        if(accList.size() > 0 && !accList.isEmpty()){
            String lastNumber = accList[0].Account_Number__c;
            String numberPart = accList[0].Account_Number__c.split('-')[2];
            nextNumber = Integer.valueOf(numberPart) + 1;
        }
        for(Account acc : (List<Account>)newItems){
            String paddedNumber = String.valueOf(nextNumber).leftPad(4,'0');
            acc.Account_Number__c = String.valueOf('ACC-'+currentYear+'-'+paddedNumber);
            nextNumber++;
        }
    }
}