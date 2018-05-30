@RestResource(urlMapping='/Account/*')
global with sharing class portalAccount {

    // get account
    @HttpGet
    global static Account getAccountById() {
        RestRequest request = RestContext.request;
        String accountId = request.requestURI.substring(
            request.requestURI.lastIndexOf('/')+1);
        Account result = [
            SELECT Source_Partner_UID__c,
                Source_Partner__c,
                FirstName,
                LastName,
                PersonBirthdate,
                Gender__c,
                PersonEmail,
                PersonHomePhone,
                PersonMobilePhone,
                BillingCountry,
                BillingState,
                BillingCity,
                BillingStreet,       
                BillingPostalCode
            FROM Account
            WHERE Id = :accountId 
        ];
        return result;
    }

    // create/update Person account
    @HttpPost
    global static Account CreateAccount(String UID, String partner, String firstName, String lastName, Date DOB, String sex, String email, String homePhone, String mobilePhone, String country, String state, String city, String streetAddress1, String streetAddress2, String zip ) {        

        String message = '';

        // catenate street addresses
        String streetAddress = streetAddress1 + ', ' + streetAddress2;
         
        // create new account if it does not exist
        List<Account> a = [SELECT Id FROM Account WHERE Source_Partner_UID__c = :UID LIMIT 1];
        if (a.isEmpty()) {
            
            try {
                // create new account
                Account account = new Account();
                account.RecordTypeID = [SELECT Id FROM RecordType WHERE SobjectType='Account' AND IsPersonType=True AND Name='Patient'].Id;
                account.Source_Partner__c = partner;
                account.Source_Partner_UID__c = UID;
                account.AccountSource = 'Partner';
                account.FirstName = firstName;
                account.LastName = lastName;
                account.PersonBirthdate = DOB;
                account.Gender__c = sex;
                account.PersonEmail = email;
                account.PersonHomePhone = homePhone;
                account.PersonMobilePhone = mobilePhone;
                account.BillingCountry = country;
                account.BillingState = state;
                account.BillingCity = city;
                account.BillingStreet = streetAddress;       
                account.BillingPostalCode = zip;

                //userId = Site.createExternalUser(user, accountId, password);
                insert account;
                message = 'Succes: account record created for ' + firstName + ' ' + lastName +'! ID Is: ' + account.Id;
                return account;
 
            } catch(DMLexception e) {
                message = 'Failed: ' + e.getMessage();
            }                           

        } else {
            message = 'Account exists';
            return a[0];
        }        
        
        //return message;
        return null;
    }
      
}