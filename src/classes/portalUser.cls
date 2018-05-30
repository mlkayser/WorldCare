@RestResource(urlMapping='/User/*')
global with sharing class portalUser {

    // get info about existing user
    @HttpGet
    global static User getUserById() {
        RestRequest request = RestContext.request;
        String userId = request.requestURI.substring(
            request.requestURI.lastIndexOf('/')+1);
        User result = [
            SELECT Username,
            LastName,
            Email,
            Alias,
            TimeZoneSidKey,
            LocaleSidKey,
            EmailEncodingKey,
            LanguageLocaleKey,
            UserRoleId,
            ProfileId,
            IsActive
            FROM User
            WHERE Id = :userId  
        ];
        return result;        
    }

    // edit portal User record
    @HttpPut 
    global static User editUser(String userId, String lastName, String firstName, String email, String logoutUrl) {        
        
        String message = '';

        // retrieve user record
        List<User> u = [SELECT FirstName, LastName, Email, Logout_URL__c FROM User WHERE Id = :userId LIMIT 1];
        if (!u.isEmpty()) {
                            
            User user = u[0];
            user.FirstName = firstName;
            user.LastName = lastName;
            user.Email = email;
            user.Logout_URL__c = logoutUrl;
            
            try {
                update user;
                User commUser = [SELECT Id, FirstName, LastName, Email, Logout_URL__c FROM User WHERE Id = :userId LIMIT 1];
                message = 'Succes: user record updated for ' + firstName + ' ' + lastName +'! ID Is: ' + user.Id;
                return commUser;
    
            } catch(DMLexception e) {
                message = 'Failed: ' + e.getMessage();
            }  

        } else {
            message = 'User does not exist';
            return null;
        }
        
        return null;
        //return message;
    }

    // create portal User record
    @HttpPost 
    global static User createUser(String UID, String lastName, String firstName, String email, String logoutUrl) {        
        
        String message = '';

        // retrieve Account
        List<Account> a = [SELECT Id FROM Account WHERE Source_Partner_UID__c = :UID LIMIT 1];
        if (!a.isEmpty()) {
             
            Account account = a[0];
            Id accountId = account.Id;
            Account Acc = [
                SELECT PersonContactId 
                FROM Account 
                WHERE Id = :accountId LIMIT 1
            ];
            Id contactId = Acc.PersonContactId;        

            // create user if it does not exist
            List<User> u = [SELECT Id, Username FROM User WHERE ContactId = :contactId LIMIT 1];
            if (u.isEmpty()) {
                  
                // random string
                Blob blobKey = crypto.generateAesKey(192);
                String key = EncodingUtil.base64encode(blobKey);
              
                // create new User
                User user = new User();
                user.ContactId = contactId;
                user.Username = email;
                user.FirstName = firstName;
                user.LastName = lastName;
                user.Email = email;
                user.CommunityNickname = lastName + '_' + key.substring(0,4);
                user.Alias =  string.valueof( firstName.substring(0,2) + lastName.substring(0,2) + key.substring(0,4) );           
                user.TimeZoneSidKey = 'America/New_York';
                user.LocaleSidKey = 'en_US';
                user.EmailEncodingKey = 'UTF-8';
                user.LanguageLocaleKey = 'en_US';
                user.ProfileId = [SELECT Id FROM Profile WHERE Name='WCI: Navigo Member' LIMIT 1].id;
                user.IsActive = true;
                user.Logout_URL__c = logoutUrl;
                
                try {
                    insert user;
                    //system.setPassword(user.Id, password);
                    User commUser = [SELECT Id, Username, Logout_URL__c FROM User WHERE Username = :email LIMIT 1];
                    message = 'Succes: user record created for ' + firstName + ' ' + lastName +'! ID Is: ' + user.Id;
                    return commUser;
        
                } catch(DMLexception e) {
                    message = 'Failed: ' + e.getMessage();
                }  

            } else {
                message = 'User exists';
                return u[0];
            }

        } else {
            message = 'Failed: Account does not exist.';
        }        
        
        return null;
        //return message;
    }
       
}