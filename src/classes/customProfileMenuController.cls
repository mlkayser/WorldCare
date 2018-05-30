public class customProfileMenuController {

    @AuraEnabled
    public static User getUserInfo() {
        User user = [SELECT Name, Logout_URL__c FROM User WHERE Id = :UserInfo.getUserId()];
        return user;
    }
    
    @AuraEnabled
    public static Account getAccountInfo() {
        User user = [SELECT Id, Name, ContactId, AccountId FROM User WHERE Id= :UserInfo.getUserId()];        
        Account PersonAccount = [SELECT Id, Name, PersonContactId FROM Account WHERE Id  =: user.AccountId];
        return PersonAccount;
    }

    @AuraEnabled
    public static String getCurrentURL(){
        string Currenturl = URL.getSalesforceBaseUrl().toExternalForm();
        return (Currenturl);
    }
    
}