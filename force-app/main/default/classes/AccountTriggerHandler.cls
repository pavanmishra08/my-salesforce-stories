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
    /*
     * Dynamic Account Scoring system
     * 1. If account revenue greater than 1 cr 40 pts, > 50 lakhs 35 points, > 10 lakhs 30 points, > 5 lakhs 25 points
     * 2. NoOfEmployee > 1000 20 pts, > 500 15 pts, > 100 10 pts, > 50 5 pts
     * 3. Industry Tech, Finance = 15 pts, Healthcare 10 pts, else 5
     * 4. If number of opp => 2 = 10 pts OR 5 pts
     * 5. Total values of Opp > 500000 = 10 pts, >100000 = 5 pts
	*/
    public static void dynamicAccountScoring(List<sObject> newItems, Map<Id, sObject> oldItems){
        Set<Id> accIds = new Set<Id>();
        Map<Id,Integer> accVsOppCount = new Map<Id,Integer>();
        Map<Id,Decimal> accVsOppAmount = new Map<Id,Decimal>();
        if( Trigger.isUpdate ){
            for(Account acc : (List<Account>)newItems){
                accIds.add(acc.Id);
            }
        }
        if(!accIds.isEmpty()){
            for(AggregateResult agr : [SELECT AccountId, COUNT(Id) oppCount, SUM(Amount) oppAmount
                                       FROM Opportunity WHERE AccountId IN:accIds GROUP BY AccountId]){
                                           accVsOppCount.put((Id)agr.get('AccountId'), (Integer)agr.get('oppCount'));
                                           accVsOppAmount.put((Id)agr.get('AccountId'), (Decimal)agr.get('oppAmount'));
                                       }
        }
        
        for(Account acc : (List<Account>)newItems){
            Integer totalScore = 0;
            if(acc.AnnualRevenue != null){
                if(acc.AnnualRevenue >= 10000000){
                    totalScore += 40;
                } else if (acc.AnnualRevenue >= 5000000){
                    totalScore += 35;
                } else if(acc.AnnualRevenue >= 1000000){
                    totalScore += 30;
                } else if(acc.AnnualRevenue >= 500000){
                    totalScore += 25;
                } else {
                    totalScore += 15;
                }
            }
            
            
            if(acc.NumberOfEmployees != null){
                if(acc.NumberOfEmployees >= 1000){
                    totalScore += 20;
                } else if(acc.NumberOfEmployees >= 500){
                    totalScore += 15;
                } else if(acc.NumberOfEmployees >= 100){
                    totalScore += 10;
                } else if(acc.NumberOfEmployees >= 50){
                    totalScore += 5;
                }
            }
            
            if(acc.Industry != null){
                if(acc.Industry == 'Technology' || acc.Industry == 'Finance'){
                    totalScore += 15;
                } else if(acc.Industry == 'Healthcare' || acc.Industry == 'Engineering'){
                    totalScore += 10;
                } else {
                    totalScore += 5;
                }
            }
            
            if(Trigger.isUpdate){
                Integer oppCount = accVsOppCount.get(acc.Id);
                Decimal oppValue = accVsOppAmount.get(acc.Id);
                if(oppCount >= 2){
                    totalScore += 10;
                } else {
                    totalScore += 5;
                }
                
                if(oppValue >= 5000000){
                    totalScore += 10;
                } else {
                    totalScore += 5;
                }
            }
            
            acc.Account_Score__c = totalScore;
        }
    }
}