public with sharing class WelcomeWidgetController {
    
    @AuraEnabled
    public static Account getAccountInformation() {
        User user = [SELECT Id, Name, AccountId from User where Id=: UserInfo.getUserId()];         
        Account PersonAccount = [SELECT Id, Name, MRN__c  from Account where Id  =: user.AccountId];
        return PersonAccount;
    }

}