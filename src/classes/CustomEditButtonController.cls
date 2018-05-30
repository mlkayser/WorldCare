public with sharing class CustomEditButtonController 
{
    
    @AuraEnabled
    public static List<Account> getAccount(String parentId) {
        return [
       	    SELECT Id
            FROM Account
            WHERE ParentId = :parentId
        ];
    }

}