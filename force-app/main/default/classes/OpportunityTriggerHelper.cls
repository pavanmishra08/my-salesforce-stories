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
    /*
     * Write a Trigger to update all OpportunityLineItem with Status as Win when Opportunity
     * is closed won
	*/
    public static void updateOpportunityLineItem(List<sObject> newItems, Map<Id, sObject> oldItemsMap){
        Set<Id> oppIds = new Set<Id>();
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        for(Opportunity opp : (List<Opportunity>)newItems){
            if(String.isNotBlank(opp.StageName) && opp.StageName.equalsIgnoreCase('Closed Won')
               && !oldItemsMap.get(opp.Id).get('StageName').toString().equalsIgnoreCase('Closed Won')){
                oppIds.add(opp.Id);
            }
        }
        
        for(OpportunityLineItem oli : [SELECT Id, Status__c FROM OpportunityLineItem WHERE opportunityId IN: oppIds]){
            oli.Status__c = 'Win';
            oliList.add(oli);
        }
        
        if(oliList.size() > 0){
            update oliList;
        }
    }
    
    /* Write a trigger to send email notification when a high- 
	 * value opportunity is created (Amount > $100,000)
	 */
    public static void sendEmailNotification(List<sObject> newItems){
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(Opportunity opp : (List<Opportunity>)newItems){
            if(opp.Amount != null && opp.Amount > 100000){
                Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                msg.setToAddresses(new String[]{'pawanmishra872000@gmail.com'});
                msg.setSubject('A New High Value Opportunity ic Created');
                msg.setPlainTextBody('A new high-value opportunity has been created'+'\n\n'+
                                    'Opportunity Name '+opp.Name+'\n'+
                                    'Opportunity Amount '+opp.amount.format()+'\n'+
                                    'Opportunity Owner '+opp.Owner.Name);
                emailList.add(msg);
            }
        }
        if(!emailList.isEmpty()){
            Messaging.sendEmail(emailList);
        }
    }
    
    /*
     * Comprehensive Opportunity Validation Trigger
     * Write a trigger to validate opportunity data including close date, 
		amount requirements and stage progress rules
		1. Close date must not be in past for active stages such as 
			Proposal/Price Quote and Negotiation/Review
		2. Amount cannot be blank when opp reaches proposal stages
		3. Cannot Skip stages new stage must be next one of old
	 */
    public static void comprehensiveValidationTrigger(Map<Id, sObject> oldItems, List<sObject> newItems){
        for(Opportunity opp : (List<Opportunity>)newItems){
            Opportunity oldOpp = Trigger.isUpdate ? (Opportunity)oldItems.get(opp.Id) : null;
            if(opp.StageName == 'Proposal/Price Quote' || opp.StageName == 'Negotiation/Review'){
                if(opp.CloseDate != null && opp.CloseDate < Date.today()){
                    opp.CloseDate.addError('Close date cannot be in past for Active Stages');
                } else if(opp.CloseDate == null){
                    opp.closeDate.addError('Close date cannot be blank for Active Stages');
                }
            }
            
            if(opp.StageName == 'Proposal/Price Quote' && opp.Amount == null){
                opp.Amount.addError('Amount cannot be blank at Proposal stage');
            }
            
            if(Trigger.isUpdate && oldOpp.StageName != opp.StageName){
                List<String> stageProgression = new List<String>{
                    'Prospecting', 'Qualification', 'Needs Analysis', 'Value Proposition', 
                        'Id. Decision Makers', 'Perception Analysis', 'Proposal/Price Quote', 
                        'Negotiation/Review', 'Closed Won'
                }; 
                Integer oldIndex = stageProgression.indexOf(oldOpp.StageName);
                Integer newIndex = stageProgression.indexOf(opp.StageName);
                if(oldIndex != -1 && newIndex != -1 && opp.StageName != 'Closed Lost' && newIndex > oldIndex + 1){
                    opp.StageName.addError('Cannot Skip Stages. Stage must be progressed sequentially');
                } else if(oldIndex != -1 && newIndex != -1 && newIndex < oldIndex + 1){
                    opp.StageName.addError('Cannot go back to previous Stage');
                }
            }
        }
    }
}