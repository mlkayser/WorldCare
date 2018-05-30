@isTest
private class portalAccountTest {
    
    // helper method
    static Id createTestRecord() {
        Account testAccount = new Account(
          Source_Partner__c = '1.800MD',
          Source_Partner_UID__c = 'JSM-004',		
          firstName = 'John',
          lastName = 'Smith',
          PersonEmail = 'jsmith@test.com',
          PersonHomePhone = '111-222-3333',
          PersonMobilePhone = '212-333-5555',
          BillingCountry = 'United States',
          BillingState = 'Maine', 		// State needs to be spelled out
          BillingCity = 'Kennebunk',
          BillingStreet = '1 Main ST. Apt. 9',
          BillingPostalCode = '04043',
          PersonBirthdate = Date.newInstance(2000, 12, 9),
          Gender__c = 'Male'
        );
        insert testAccount;
        return testAccount.Id;
    } 
    
    @isTest static void testGetAccountById() {        
        // set up test request
        Id recordId = createTestRecord();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/Account/' + recordId;
        request.httpMethod = 'GET';
        RestContext.request = request;
        
        // call method to test
        Account thisAccount = portalAccount.getAccountById();
        
        // verify results
        System.assert(thisAccount != null);
        System.assertEquals('JSM-004',thisAccount.Source_Partner_UID__c);       
    }

    @isTest static void testCreateAccount() {        
        // call method to test
        Account newAccount = portalAccount.CreateAccount(
        	'JSM-004',
            '1.800MD',
            'John',
            'Smith',
            Date.newInstance(2000, 12, 9),
            'Male',
            'jsmith@test.com',
            '111-222-3333',
			'212-333-5555',
            'United States',
            'Maine',
            'Kennebunk',
            '1 Main ST.',
            'Apt. 9',
            '04043'
        );
        
        // verify results
        System.assert(newAccount != null); // new account was created
        Account thisAccount = [SELECT Id, Source_Partner_UID__c FROM Account WHERE Id =: newAccount.Id];
        System.assert(thisAccount != null); // new account was retrieved from database
        System.debug('UID= ' + thisAccount.Source_Partner_UID__c);
        System.assertEquals(thisAccount.Source_Partner_UID__c,'JSM-004'); // new account has the right value in this field      
    }
}