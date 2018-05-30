@isTest
private class customProfileMenuControllerTest {
    // helper method
    static User createTestRecord() {
        User userWithRole = [ SELECT Id FROM User WHERE (UserRole.Name = 'TM Nurses' AND Email != 'depot@sadhanaconsulting.com') LIMIT 1 ];
		System.runAs ( userWithRole ) {
            //System.debug('Current User: ' + UserInfo.getUserName());
            //System.debug('Current Profile: ' + UserInfo.getProfileId());

            Account testAccount = new Account(
            	FirstName = 'John',
                LastName = 'Smith',
                PersonEmail = 'jsmith@test.com',
            	OwnerId = userWithRole.Id,
                RecordTypeID = [SELECT Id FROM RecordType WHERE SobjectType='Account' AND IsPersonType=True AND Name='Patient'].Id
            );
            insert testAccount;
            Account acc = [SELECT Id, PersonContactId FROM Account WHERE Id =: testAccount.Id];

            User testUser = new User(
                ContactId = acc.PersonContactId,
                Username = 'johnny100@test.com',
                FirstName = 'John',
                LastName = 'Smith',
                Email = 'jsmith@test.com',
                CommunityNickname = 'jsmith',
                Alias =  'jsmith30',           
                TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                ProfileId = [SELECT Id FROM Profile WHERE Name='WCI: Navigo Member' LIMIT 1].id,
                IsActive = true,
                Logout_URL__c = 'https://staging.navigohealth.com'
            );
            insert testUser;
    	}    
        Account acc = [SELECT Id, PersonContactId, Name FROM Account WHERE PersonEmail = 'jsmith@test.com'];
        User u = [SELECT Id, AccountId FROM User WHERE ContactId = :acc.PersonContactId];
        return u;
    } 
    
    @isTest static void testGetUserInfo() {        
        // set up test request
        User thisUser = createTestRecord();
        System.debug('this user');
        System.debug(thisUser);
        
        // call method to test
        System.runAs ( thisUser ) {
            Test.startTest();
            User returnedUser = customProfileMenuController.getUserInfo();
            Test.stopTest();
            
            // verify results
            System.debug('returned user');
            System.debug(returnedUser);
            System.assert(returnedUser != null);
            System.assertEquals('John Smith',returnedUser.Name);               
       }     
    }

    @isTest static void testGetAccountInfo() {        
        // set up test request
        User thisUser = createTestRecord();
        
        // call method to test
        System.runAs ( thisUser ) {
            Test.startTest();
            Account returnedAccount = customProfileMenuController.getAccountInfo();
            Test.stopTest();
            
            // verify results
            System.debug('returned account');
            System.debug(returnedAccount);
            System.assert(returnedAccount != null);
            System.assertEquals('John Smith',returnedAccount.Name);               
       }     
    }

    @isTest static void testGetCurrentURL() {        
        Test.startTest();
        String url = customProfileMenuController.getCurrentURL();
        Test.stopTest();
        
        // verify results
        System.assert(url != null);
    }

}