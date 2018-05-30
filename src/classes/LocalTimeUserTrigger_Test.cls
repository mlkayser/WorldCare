// Success Software - Local Time App for Salesforce
// Test class for Local time trigger on the User object
// 11/07/2017 - Initial implementation - Success Software, info@success-software.biz
@isTest(SeeAllData=true)
private class LocalTimeUserTrigger_Test {
    static testmethod void testTrigger(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        system.assert(p.Id != null);

        Test.startTest();
        // create a test user
        User u = new User(alias = 'newUser', email='newuser@audibene.de.test',
                    Emailencodingkey='UTF-8', firstname='NewUser', lastname='Testing', 
                    Languagelocalekey='en_US', localesidkey='en_US',
                    Profileid = p.Id,
                    Timezonesidkey='America/Los_Angeles',
                    Country='United States', State='California', City='Los Angeles',
                    IsActive=true,                                     
                    Username= System.now().millisecond() + '_newuser@audibene.de.test',
                    CommunityNickname = 'TestCommunityName' + System.now().millisecond());
        insert u;
        system.assert(u.Id != null);

        Test.stopTest();

        List<User> uTmp = [SELECT Id, UTC_Offset_F__c FROM User WHERE Id=:u.Id];
        system.assert(uTmp.size() == 1);
        system.assert(uTmp[0].UTC_Offset_F__c == -7 || uTmp[0].UTC_Offset_F__c == -8);
        
    }
}