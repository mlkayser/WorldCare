@isTest
private class portalUserTest {
    // helper method
    static Id createTestRecord() {
        //User userWithRole = [ SELECT Id FROM User WHERE Email = 'depot@sadhanaconsulting.com' LIMIT 1];
        User userWithRole = [ SELECT Id FROM User WHERE (UserRole.Name = 'TM Nurses' AND Email != 'depot@sadhanaconsulting.com') LIMIT 1 ];
		System.runAs ( userWithRole ) {
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());

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
                IsActive = true
            );
            insert testUser;
    	}    
        Account acc = [SELECT Id, PersonContactId FROM Account WHERE PersonEmail = 'jsmith@test.com'];
        User u = [SELECT Id FROM User WHERE ContactId = :acc.PersonContactId];
        return u.Id;
    } 
    
    @isTest static void testGetUserById() {        
        // set up test request
        Id recordId = createTestRecord();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/User/' + recordId;
        request.httpMethod = 'GET';
        RestContext.request = request;
        
        // call method to test
        User thisUser = portalUser.getUserById();
        
        // verify results
        System.assert(thisUser != null);
        System.assertEquals('jsmith30',thisUser.alias);       
    }

    @isTest static void testCreateUser() {        

        //User userWithRole = [ SELECT Id FROM User WHERE Email = 'depot@sadhanaconsulting.com' LIMIT 1]; 
		User userWithRole = [ SELECT Id FROM User WHERE (UserRole.Name = 'TM Nurses' AND Email != 'depot@sadhanaconsulting.com') LIMIT 1 ];
        System.runAs ( userWithRole ) {
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());

            Account testAccount = new Account(
                FirstName = 'Jane',
                LastName = 'Smith',
                PersonEmail = 'jsmith99@test.com',
                Source_Partner_UID__c = 'JSM-009',
                OwnerId = userWithRole.Id,
                RecordTypeID = [SELECT Id FROM RecordType WHERE SobjectType='Account' AND IsPersonType=True AND Name='Patient'].Id
            );
            insert testAccount;
			System.debug('Account ID =' + testAccount.Id);
            
        	// call method to test
            User newUser = portalUser.createUser(
                'JSM-009',
                'Smith',
                'Jane',
                'jsmith99@test.com',
                'https://www.ucsb.edu'
            );
        
            // verify results
            System.assert(newUser != null); // new user was created
            User thisUser = [SELECT Id, Username FROM User WHERE Id =: newUser.Id];
            System.assert(thisUser != null); // new user was retrieved from database
            System.debug('Username= ' + thisUser.Username);
            System.assertEquals(thisUser.Username,'jsmith99@test.com'); // new user has the right value in this field      
        }
	}

}