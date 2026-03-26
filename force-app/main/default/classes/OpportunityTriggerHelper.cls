public with sharing class OpportunityTriggerHelper {
    public OpportunityTriggerHelper() {

    }
    /*
    * Calculate and update the total opportunities amount on
    * Parent Account Object
    */
    public static void updateOppAmount(List<sObject> newItems, List<sObject> oldItems, Map<Id, sObject> oldItemsMap){
        Set<Id> accountIds = new Set<Id>();
        List<Account> accountsToUpdate = new List<Account>();
        if(Trigger.isDelete && oldItems != null){
            for(Opportunity opp: (List<Opportunity>)oldItems){
                accountIds.add(opp.AccountId);
            }
        } else {
            for(Opportunity opp : (List<Opportunity>)newItems){
                accountIds.add(opp.AccountId);
                if(Trigger.isUpdate && oldItems != null && oldItemsMap != null){
                    accountIds.add(oldItemsMap.get(opp.Id).get('AccountId').toString());
                }
            }
        }
        
        List<AggregateResult> arrList = [SELECT COUNT(Id) countOfOpp, AccountId, SUM(Amount) totalAmt 
                                            FROM Opportunity
                                            WHERE AccountId IN: accountIds
                                            GROUP BY AccountId
                                        ];
        for(AggregateResult agr : arrList){
            Account acc = new Account();
            acc.Id = (Id)agr.get('AccountId');
            acc.Total_No_Of_Opportunities__c = (Decimal)agr.get('countOfOpp');
            acc.Total_Oppotunities_Amount__c = (Decimal)agr.get('totalAmt');
            accountsToUpdate.add(acc);
        }
        if(!accountsToUpdate.isEmpty()){
            update accountsToUpdate;
        }
    }
}