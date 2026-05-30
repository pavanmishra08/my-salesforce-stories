public class ContactTriggerHelper {
    public static void checkDuplicates(List<sObject> newItems, Map<Id, sObject> newItemsMap, Map<Id, sObject> oldItemsMap){
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
    
    /*
     * Write a trigger to calculate age, lifecycle stage, and demographic scoring for contacts with comprehensive validation and business 
	   logic.
	   1. Calculate Age 2. Set Age Category according to age < 25 (Young Professional), < 35 (Early Career), < 45 Mid career,
		  < 55 Senior Professional
	   2. If age between 35 to 55 score 20, bet 25 to 35 score 15, else 10
	   3. If indusetry is Tech and Financial services score 15
          if industry is healthcare and manufacturing score is 10
       4. AnnualRevenue > 1 cr score 15, AR > 10 Lakh score 10, AR > 1 L score 5
       5. if score > 50 Key Decision Maker, score >= 30 Influencer, score >=15 Engaged Contact, BAsic Contact
	*/
    public static void ContactDemographicsLifecycle(List<sObject> newItems, Map<Id, sObject> newItemsMap, Map<Id, sObject> oldItemsMap){
        Set<Id> accIds = new Set<Id>();
        for(Contact c : (List<Contact>)newItems){
            if(c.AccountId != null){
                accIds.add(c.AccountId);
            }
        }
        
        Map<Id, Account> accountMap = new Map<Id,Account>([SELECT Id, Name, AnnualRevenue, Industry
                                                           FROM Account WHERE Id IN:accIds]);
        for(Contact c : (List<Contact>)newItems){
            Integer demoScore = 0;
            if(c.Birthdate != null){
                Date today = Date.today();
                Integer age = Date.today().year() - c.Birthdate.year();
                Date birthDayThisYear = Date.newInstance(today.year(), c.BirthDate.month(), c.Birthdate.day());
                if( birthDayThisYear > today ){
                    age--;
                }
                
                c.Age__c = age;
                
                if(age < 25){
                    c.Age_Category__c = 'Young Professional';
                } else if(age < 35){
                    c.Age_Category__c = 'Early Career';
                } else if(age < 45){
                    c.Age_Category__c = 'Mid Career';
                } else if(age < 55){
                    c.Age_Category__c = 'Senior Professional';
                } else {
                    c.Age_Category__c = 'Executive Level';
                }
                
                if(age != null){
                    if(age >= 35 && age <= 55){
                        demoScore += 20;
                    } else if(age >= 25 && age < 35){
                        demoScore += 15;
                    } else {
                        demoScore += 10;
                    }
                }
            }
            
            if(accountMap.containsKey(c.AccountId)){
                Account acc = accountMap.get(c.AccountId);
                if(acc.Industry == 'Technology' || acc.Industry == 'Financial Service'){
                    demoScore += 15;
                } else if(acc.Industry == 'Healthcare' || acc.Industry == 'Manufacturing'){
                    demoScore += 10;
                } else {
                    demoScore += 5;
                }
                
                if(acc.AnnualRevenue > 10000000){
                    demoScore += 15;
                } else if(acc.AnnualRevenue > 1000000){
                    demoScore += 10;
                } else {
                    demoScore += 5;
                }
            }
            
            if(demoScore != 0){
                c.Demographic_Score__c = demoScore;
                if(demoScore >= 50){
                    c.Lifecycle_Stage__c = 'Key Decision Maker';
                } else if(demoScore >= 30){
                    c.Lifecycle_Stage__c = 'Influencer';
                } else if(demoScore >= 15){
                    c.Lifecycle_Stage__c = 'Engaged Contact';
                } else {
                    c.Lifecycle_Stage__c = 'Basic Contact';
                }
            }
        }
    }
    /*
     * Write a trigger to update the count of related contacts on the account
	*/
    public static void ContactCountUpdateOnAccount(Map<Id, sObject> oldMap, List<sObject> oldItem, List<sObject> newItem){
		Set<Id> accIds = new Set<Id>();
        if(Trigger.isDelete){
            for(Contact c: (List<Contact>)oldItem){
                if(c.AccountId != null){
                    accIds.add(c.AccountId);
                }
            }
        } else if(Trigger.isUpdate){
            for(Contact c : (List<Contact>)newItem){
                Contact con = (Contact)oldMap.get(c.Id);
                if(con.AccountId != null){
                    accIds.add(con.AccountId);
                }
                if(c.AccountId != null){
                    accIds.add(c.AccountId);
                }
            }
        } else {
            for(Contact c: (List<Contact>)newItem){
                if(c.AccountId != null){
                    accIds.add(c.AccountId);
                }
            }
        }
        
        Map<Id, Integer> accIdVsNoOfCon = new Map<Id,Integer>();
        
        for(AggregateResult agr : [SELECT Count(Id) noOfCon, AccountId FROM Contact
                                    WHERE AccountId IN: accIds
                                    GROUP BY AccountId]){
            accIdVsNoOfCon.put((Id)agr.get('AccountId'), (Integer)agr.get('noOfCon'));
        }
        
        List<Account> accList = new List<Account>();
        for(Id i : accIds){
            Account acc = new Account();
            if(accIdVsNoOfCon.containsKey(i)){
                acc.Id = i;
                acc.Number_Of_Contact_Trigger__c = accIdVsNoOfCon.get(i);
            } else {
                acc.Id = i;
                acc.Number_Of_Contact_Trigger__c = 0;
            }
            accList.add(acc);
        }
        
        if(accList.size() > 0){
            update accList;
        }
    }
}