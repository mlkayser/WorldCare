/**
 * This class contains unit tests for validating the behavior of Apex class Trg_Case_CopyCaseTeamMember.cls which is Helper class for Trg_Case.trigger.
 *
 */
@isTest (seeAllData=False)
private class Trg_Case_CopyCaseTeamMemberTest {
	
	 static list<Case> lstCase = new list<Case>();
	 static list<Case> lstCaseChild1 = new list<Case>();
	 static list<Case> lstCaseChild2 = new list<Case>();
	 static list<CaseTeamMember> lstCaseTeamMember = new list<CaseTeamMember>();
	 static list<CaseTeamMember> lstCaseTeamMembers = new list<CaseTeamMember>();
	 static list<User> listUsers = new list<User>();
	 static integer numOfCaseMember = 201;
	 static integer numOfUsers = 201;
	 static integer numOfCaseChild1 = 5;
	 static integer numOfCaseChild2 = 10;
	 static integer numOfCase = 1;
	 static CaseTeamRole role = new CaseTeamRole();
	
	/**
    * The purpose of this method is to create test data.   
    */
    static void createTestData(){
    	
    	//Generate standard user with Standard User Profile
       	Profile userProfile = [Select p.Id From Profile p where Name like 'Standard User' limit 1][0];
        
        // Create User	
		for(Integer i=0;i<numOfUsers;i++) {
            listUsers.add(new User(
                    LastName            =   'T3stLastName' + userProfile +String.ValueOf(i),
                    Alias               =   'xy'+ String.ValueOf(i),
                    Email               =   'TestStandardUser'+String.ValueOf(i)+'@example.com',
                    Username            =   'TestStandardUser'+String.ValueOf(i)+'@example.com',
                    CommunityNickname   =   'xy'+ String.ValueOf(i),
                    //UserRoleId        =   Role.id,
                    IsActive            =   true,
                    TimeZoneSidKey      =   'America/New_York',
                    LocaleSidKey        =   'en_US',
                    EmailEncodingKey    =   'ISO-8859-1',
                    ProfileId           =   userProfile.id,
                    LanguageLocaleKey   =   'en_US',
                    Department          =   'Corporate Sales'
                )
            );
        }
	    insert listUsers;
    	
    	// Create Generaly Case
    	for(integer i = 0 ; i<numOfCase; i++){
    		lstCase.add(new Case (
    					Subject = 'TesCase' + i,
    		 			Status = 'New',
        	 			Case_Team_Updated__c = System.Now()
        	 			));
    	}
    	insert lstCase;
    	
    	// Select Role
    	role = [Select ID from CaseTeamRole LIMIT 1];
        
    	// Create Case Team Member
    	for(integer i = 0 ; i<numOfCaseMember; i++){
    		lstCaseTeamMember.add(new CaseTeamMember (
    		 			ParentId = lstCase[0].id,
    		 			MemberId = listUsers[i].id,
    		 			TeamRoleId = role.id
        	 			));
    	}
    }
    static void resetID(){
    	Trg_Case.alreadyExecutedBefore = new Set<Id>();
        Trg_Case.alreadyExecutedAfter = new Set<Id>();
    }
	
	
   /** 
   	*	This test method contains tests for validating the behavior 
  	*	SCENARIO:		One Case is created on first level. 1 Case is created on second level. 1 Cases is created on third level. 
  	*					a)	Insert one Case Team Member on 1 level Case.
  	*	Expectations:	a)	Case Team Members which is created on first level Case is cloned to second and third level Cases automaticaly.
  	*/
    static testMethod void positiveTestInsertOneCaseTeamMember() {
    	numOfCaseMember = 1;
       // CREATE TEST DATA
	   createTestData();
	   
	   // RUN TEST
	   Test.startTest();
	   		// a)	Insert one Case Team Member on 1 level Case.	
	   	   insert lstCaseTeamMember;
	   	   
	   	  	 // Create Child Case 1 level
	    	for(integer i = 0 ; i<1; i++){
	    		lstCaseChild1.add(new Case (
	    					Subject = 'TeslstCaseChild1' + i,
	    		 			Status = 'New',
	        	 			Case_Team_Updated__c = System.Now(),
	        	 			ParentID = lstCase[0].id
	        	 			));
	    	}
	    	insert lstCaseChild1;
	    	
	    	//Create Child Case 2 level
	    	for(integer i = 0 ; i<1; i++){
	    		lstCaseChild2.add(new Case (
	    					Subject = 'TestlstCaseChild2' + i, 
	    		 			Status = 'New',
	        	 			Case_Team_Updated__c = System.Now(),
	        	 			ParentID = lstCaseChild1[0].id
	        	 			));
	    	}
	    	insert lstCaseChild2;
	   
	   system.debug(loggingLevel.ERROR,'SOQL positiveTestInsertOneCaseTeamMember() before STOP Test ' + limits.getQueries()); 	   
	   system.debug(LoggingLevel.ERROR, 'DML rows query before stopTest() positiveTestInsertOneCaseTeamMember() unit test: ' + Limits.getDMLRows());
	   Test.stopTest();
	   
	   resetID();
	   // Update Case on 1 level
	   lstCase[0].Case_Team_Updated__c = DateTime.now().addseconds(10);
       update lstCase; 
	   
	   // Asserts after insert	   
	   list<CaseTeamMember> caseTeamMemberToAssert = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCase[0].id];
	   system.assertEquals(numOfCaseMember,caseTeamMemberToAssert.size(),'Case Team Members were not created correctly.');
	   
	   list<CaseTeamMember> caseTeamMemberToAssert1 = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCaseChild1[0].id];
	   system.assertEquals(numOfCaseMember,caseTeamMemberToAssert1.size(), 'Case Team Members were not cloned correctly.');
	   
	   list<CaseTeamMember> caseTeamMemberToAssert2 = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCaseChild2[0].id];
	   system.assertEquals(numOfCaseMember,caseTeamMemberToAssert2.size(), 'Case Team Members were not cloned correctly.');
	   
	   system.debug(LoggingLevel.ERROR, 'DML rows query before stopTest() positiveTestInsertOneCaseTeamMember() END Test: ' + Limits.getDMLRows());
	   system.debug(loggingLevel.ERROR,'SOQL positiveTestInsertOneCaseTeamMember() before END Test ' + limits.getQueries());   
   
    }// positiveTestInsertOneCaseTeamMember()
    /** 
   	*	This test method contains tests for validating the behavior 
  	*	SCENARIO:		One Case is created on first level. 1 Case is created on second level. 1 Cases is created on third level. 
  	*					a)	Insert one Case Team Member on 1 level Case.
  	*					b)	Delete Case Team Members on 1 level Case.
  	*	Expectations:	a)	Case Team Members which is created on first level Case is cloned to second and third level Cases automaticaly.
  	*					b)	Case Team Members which are deleted on first level Case is deleted to second and third level Cases automaticaly.
  	*/
    static testMethod void positiveTestInsertAndDeleteOneCaseTeamMember() {
    	numOfCaseMember = 1;
       // CREATE TEST DATA
	   createTestData();
	   
	   // RUN TEST
	   Test.startTest();
	   		// a)	Insert one Case Team Member on 1 level Case.	
	   	   insert lstCaseTeamMember;
	   	   
	   	  	 // Create Child Case 1 level
	    	for(integer i = 0 ; i<1; i++){
	    		lstCaseChild1.add(new Case (
	    					Subject = 'TeslstCaseChild1' + i,
	    		 			Status = 'New',
	        	 			Case_Team_Updated__c = System.Now(),
	        	 			ParentID = lstCase[0].id
	        	 			));
	    	}
	    	insert lstCaseChild1;
	    	
	    	//Create Child Case 2 level
	    	for(integer i = 0 ; i<1; i++){
	    		lstCaseChild2.add(new Case (
	    					Subject = 'TestlstCaseChild2' + i, 
	    		 			Status = 'New',
	        	 			Case_Team_Updated__c = System.Now(),
	        	 			ParentID = lstCaseChild1[0].id
	        	 			));
	    	}
	    	insert lstCaseChild2;
	   
	   system.debug(loggingLevel.ERROR,'SOQL positiveTestInsertAndDeleteOneCaseTeamMember() before STOP Test ' + limits.getQueries()); 	   
	   system.debug(LoggingLevel.ERROR, 'DML rows query before stopTest() positiveTestInsertAndDeleteOneCaseTeamMember() unit test: ' + Limits.getDMLRows());
	   Test.stopTest();
	   
	   // Asserts after insert	   
	   list<CaseTeamMember> caseTeamMemberToAssert = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCase[0].id];
	   system.assertEquals(numOfCaseMember,caseTeamMemberToAssert.size(),'Case Team Members were not created correctly.');
	   
	   list<CaseTeamMember> caseTeamMemberToAssert1 = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCaseChild1[0].id];
	   system.assertEquals(numOfCaseMember,caseTeamMemberToAssert1.size(), 'Case Team Members were not cloned correctly.');
	   
	   list<CaseTeamMember> caseTeamMemberToAssert2 = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCaseChild2[0].id];
	   system.assertEquals(numOfCaseMember,caseTeamMemberToAssert2.size(), 'Case Team Members were not cloned correctly.');
	   
	   // Update Case on 1 level
	   resetID();
       lstCase[0].Case_Team_Updated__c = DateTime.now().addseconds(20);
       update lstCase; 
	   
	   // b) DELETE one Case Team Member from 1 Case level
	   resetID();
	   delete caseTeamMemberToAssert;
	   
	    // Update Case on 1 level
	   resetID();
       lstCase[0].Case_Team_Updated__c = DateTime.now().addseconds(30);
       update lstCase; 
	   
       // Asserts after delete	   
	   caseTeamMemberToAssert = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCase[0].id];
	   system.assertEquals(0,caseTeamMemberToAssert.size(),'Case Team Members were not deleted correctly.');
	   
	   caseTeamMemberToAssert1 = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCaseChild1[0].id];
	   system.assertEquals(0,caseTeamMemberToAssert1.size(), 'Case Team Members were not deleted correctly.');
	   
	   caseTeamMemberToAssert2 = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCaseChild2[0].id];
	   system.assertEquals(0,caseTeamMemberToAssert2.size(), 'Case Team Members were not deleted correctly.');
	   
	   system.debug(LoggingLevel.ERROR, 'DML rows query before stopTest() positiveTestInsertAndDeleteOneCaseTeamMember() END Test: ' + Limits.getDMLRows());
	   system.debug(loggingLevel.ERROR,'SOQL positiveTestInsertAndDeleteOneCaseTeamMember() before END Test ' + limits.getQueries());   
   
    }// positiveTestInsertAndDeleteOneCaseTeamMember()
     /** 
   	*	This test method contains tests for validating the behavior 
  	*	SCENARIO:		- One Case is created on first level. 1 Case is created on second level. 1 Cases is created on third level. 
  	*					- On first level Case are created 1 Case Team Member.
  	*					a) Add another Case Team Member on 1 Case level
  	*					b) Delete one Case Team Member from 1 Case level
  	*	Expectations:	a) Case Team Members which were created on second level Case are cloned to third level Cases automaticaly.
  	*					b) Case Team Member which is deleted on first level Case is deleted from second and third level Cases automaticaly.
  	*/
    static testMethod void positiveTestAddAnotherCaseTeamMemberAndDeleteOneCaseTeamMember() {
    	numOfCaseMember = 1;
       // CREATE TEST DATA
	   createTestData();
	   
	   	   insert lstCaseTeamMember;
	   	   
	   	  	 // Create Child Case 1 level
	    	for(integer i = 0 ; i<1; i++){
	    		lstCaseChild1.add(new Case (
	    					Subject = 'TeslstCaseChild1' + i,
	    		 			Status = 'New',
	        	 			Case_Team_Updated__c = System.Now(),
	        	 			ParentID = lstCase[0].id
	        	 			));
	    	}
	    	insert lstCaseChild1;
	    	
	    	//Create Child Case 2 level
	    	for(integer i = 0 ; i<1; i++){
	    		lstCaseChild2.add(new Case (
	    					Subject = 'TestlstCaseChild2' + i, 
	    		 			Status = 'New',
	        	 			Case_Team_Updated__c = System.Now(),
	        	 			ParentID = lstCaseChild1[0].id
	        	 			));
	    	}
	    	insert lstCaseChild2;
	   
	   // Asserts after insert	   
	   list<CaseTeamMember> caseTeamMemberToAssert = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCase[0].id];
	   system.assertEquals(numOfCaseMember,caseTeamMemberToAssert.size(),'Case Team Members were not created correctly.');
	   
	   list<CaseTeamMember> caseTeamMemberToAssert1 = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCaseChild1[0].id];
	   system.assertEquals(numOfCaseMember,caseTeamMemberToAssert1.size(), 'Case Team Members were not cloned correctly.');
	   
	   list<CaseTeamMember> caseTeamMemberToAssert2 = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCaseChild2[0].id];
	   system.assertEquals(numOfCaseMember,caseTeamMemberToAssert2.size(), 'Case Team Members were not cloned correctly.');
	   
	   // RUN TEST
	   Test.startTest();
	   		
	   		resetID();
	  		// Update Case on 1 level
       		update lstCase; 
       		lstCase[0].Case_Team_Updated__c = DateTime.now().addseconds(10);
		  
		   // a) ADD another Case Team Member on 1 Case level
		   CaseTeamMember newCaseTeamMember1 = new CaseTeamMember (
						    		 			ParentId = lstCase[0].id,
						    		 			MemberId = listUsers[5].id,
						    		 			TeamRoleId = role.id
						        	 			);
			lstCaseTeamMember.add(newCaseTeamMember1);
	    	insert newCaseTeamMember1;
		
		  	resetID();
	  		// Update Case on 1 level
       		update lstCase; 
       		lstCase[0].Case_Team_Updated__c = DateTime.now().addseconds(10);
       			  
       system.debug(loggingLevel.ERROR,'SOQL positiveTestAddAnotherCaseTeamMemberAndDeleteOneCaseTeamMember() before STOP Test ' + limits.getQueries()); 	   
	   system.debug(LoggingLevel.ERROR, 'DML rows query before stopTest() positiveTestAddAnotherCaseTeamMemberAndDeleteOneCaseTeamMember() unit test: ' + Limits.getDMLRows());
	   Test.stopTest();
   
	   // Asserts after insert	   
	   caseTeamMemberToAssert = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCase[0].id];
	   system.assertEquals(2,caseTeamMemberToAssert.size(),'Case Team Members were not created correctly.');
	   
	   caseTeamMemberToAssert1 = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCaseChild1[0].id];
	   system.assertEquals(2,caseTeamMemberToAssert1.size(), 'Case Team Members were not cloned correctly.');
	   
	   caseTeamMemberToAssert2 = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCaseChild2[0].id];
	   system.assertEquals(2,caseTeamMemberToAssert2.size(), 'Case Team Members were not cloned correctly.');
	   
	   resetID();
	   // Update Case on 1 level 
       lstCase[0].Case_Team_Updated__c = DateTime.now().addseconds(10); 
       update lstCase;
       
	   // b) DELETE one Case Team Member from 1 Case level
	   resetID();
	   set<Id> caseTeamMemberListToDelete = new set<Id>();
	   		caseTeamMemberListToDelete.add(caseTeamMemberToAssert[0].Id);
	   delete [SELECT Id FROM CaseTeamMember WHERE Id = :caseTeamMemberListToDelete];
	   
	   resetID();
	   // Update Case on 1 level 
       lstCase[0].Case_Team_Updated__c = DateTime.now().addseconds(20); 
       update lstCase;
	   
	   // Asserts after delete	   
	   caseTeamMemberToAssert = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCase[0].id];
	   system.assertEquals(1,caseTeamMemberToAssert.size(),'Case Team Members were not deleted correctly.');
	   
	   caseTeamMemberToAssert1 = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCaseChild1[0].id];
	   system.assertEquals(1,caseTeamMemberToAssert1.size(), 'Case Team Members were not deleted correctly.');
	   
	   caseTeamMemberToAssert2 = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCaseChild2[0].id];
	   system.assertEquals(1,caseTeamMemberToAssert2.size(), 'Case Team Members were not deleted correctly.');
	  
	   system.debug(LoggingLevel.ERROR, 'DML rows query before stopTest() positiveTestAddAnotherCaseTeamMemberAndDeleteOneCaseTeamMember() END Test: ' + Limits.getDMLRows());
	   system.debug(loggingLevel.ERROR,'SOQL positiveTestAddAnotherCaseTeamMemberAndDeleteOneCaseTeamMember() before END Test ' + limits.getQueries());   
    } // positiveTestAddAnotherCaseTeamMemberAndDeleteOneCaseTeamMember()
   /** 
   	*	This test method contains tests for validating the behavior 
  	*	SCENARIO:		- One Case is created on first level. 5 Cases are created on second level. 10 Cases are create on third level. 
  	*					- On first level Case are created 201 Case Team Members.
  	*	Expectations:	- Case Team Members which were created on first level Case are cloned to related second and third level Cases automaticaly.
  	*/
    static testMethod void positiveTestInsertSetOfCaseTeamMember() {
    	numOfCaseChild1 = 2;
    	numOfCaseChild2 = 4;
       // CREATE TEST DATA
	   createTestData();
	   
	   // RUN TEST
	   Test.startTest();
	   	   insert lstCaseTeamMember;
	   	   
	   	  	 // Create Child Case 1 level
	    	for(integer i = 0 ; i<numOfCaseChild1; i++){
	    		lstCaseChild1.add(new Case (
	    					Subject = 'TeslstCaseChild1' + i,
	    		 			Status = 'New',
	        	 			Case_Team_Updated__c = System.Now(),
	        	 			ParentID = lstCase[0].id
	        	 			));
	    	}
	    	insert lstCaseChild1;
	    	
	    	//Create Child Case 2 level
	    	for(integer i = 0 ; i<numOfCaseChild2; i++){
	    		lstCaseChild2.add(new Case (
	    					Subject = 'TestlstCaseChild2' + i, 
	    		 			Status = 'New',
	        	 			Case_Team_Updated__c = System.Now(),
	        	 			ParentID = lstCaseChild1[0].id
	        	 			));
	    	}
	    	insert lstCaseChild2;
	   
	   system.debug(loggingLevel.ERROR,'SOQL positiveTestInsertSetOfCaseTeamMember() before STOP Test ' + limits.getQueries()); 	   
	   system.debug(LoggingLevel.ERROR, 'DML rows query positiveTestInsertSetOfCaseTeamMember() before STOP Test: ' + Limits.getDMLRows());
	  
	   Test.stopTest();
	   
	   resetID();
	   // Update Case on 1 level
	   lstCase[0].Case_Team_Updated__c = DateTime.now().addseconds(10);
       update lstCase;  
	   
	   // Asserts after insert	   
	   list<CaseTeamMember> caseTeamMemberToAssert = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCase[0].id];
	   system.assertEquals(numOfCaseMember,caseTeamMemberToAssert.size(),'Case Team Members were not created correctly.');
	   
	   list<CaseTeamMember> caseTeamMemberToAssert1 = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCaseChild1[0].id];
	   system.assertEquals(numOfCaseMember,caseTeamMemberToAssert1.size(), 'Case Team Members were not created correctly.');
	   
	   list<CaseTeamMember> caseTeamMemberToAssert2 = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCaseChild2[0].id];
	   system.assertEquals(numOfCaseMember,caseTeamMemberToAssert2.size(), 'Case Team Members were not created correctly.');
	   
	   system.debug(LoggingLevel.ERROR, 'DML rows query before positiveTestInsertSetOfCaseTeamMember before END Test: ' + Limits.getDMLRows());
	   system.debug(loggingLevel.ERROR,'SOQL positiveTestInsertSetOfCaseTeamMember() before END Test ' + limits.getQueries());   
    } //positiveTestInsertSetOfCaseTeamMember()
     /** 
   	*	This test method contains tests for validating the behavior 
  	*	SCENARIO:		- One Case is created on first level. 5 Case is created on second level. 10 Cases is create on third level. 
  	*					a)	On first level Case are created 70 Case Team Members.
  	*					b)	Add another 30 Case Team Members.
  	*	Expectations:	a)b) Case Team Members which were created on first level Case are cloned to related second and third level Cases automaticaly.
  	*/
    static testMethod void positiveTestInsertSetOfAndAddAnotherCaseTeamMembers() {
       numOfCaseMember = 70;
       // CREATE TEST DATA
	   createTestData();
	   
	   // RUN TEST
	   Test.startTest();
	   	   //a)	On first level Case are created 70 Case Team Members
	   	   insert lstCaseTeamMember;
	   	   
	   	  	 // Create Child Case 1 level
	    	for(integer i = 0 ; i<numOfCaseChild1; i++){
	    		lstCaseChild1.add(new Case (
	    					Subject = 'TeslstCaseChild1' + i,
	    		 			Status = 'New',
	        	 			Case_Team_Updated__c = System.Now(),
	        	 			ParentID = lstCase[0].id
	        	 			));
	    	}
	    	insert lstCaseChild1;
	    	
	    	//Create Child Case 2 level
	    	for(integer i = 0 ; i<numOfCaseChild2; i++){
	    		lstCaseChild2.add(new Case (
	    					Subject = 'TestlstCaseChild2' + i, 
	    		 			Status = 'New',
	        	 			Case_Team_Updated__c = System.Now(),
	        	 			ParentID = lstCaseChild1[0].id
	        	 			));
	    	}
	    	insert lstCaseChild2;
	   
	   system.debug(loggingLevel.ERROR,'SOQL positiveTestInsertSetOfAndAddAnotherCaseTeamMembers() before STOP Test ' + limits.getQueries()); 	   
	   system.debug(LoggingLevel.ERROR, 'DML rows query positiveTestInsertSetOfAndAddAnotherCaseTeamMembers() before STOP Test: ' + Limits.getDMLRows());
	  
	   Test.stopTest();
	   
	   resetID();
	   // Update Case on 1 level
	   lstCase[0].Case_Team_Updated__c = DateTime.now().addseconds(10);
       update lstCase; 
	   
	   // Asserts after insert	   
	   list<CaseTeamMember> caseTeamMemberToAssert = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCase[0].id];
	   system.assertEquals(numOfCaseMember,caseTeamMemberToAssert.size(),'Case Team Members were not created correctly.');
	   
	   list<CaseTeamMember> caseTeamMemberToAssert1 = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCaseChild1[0].id];
	   system.assertEquals(numOfCaseMember,caseTeamMemberToAssert1.size(), 'Case Team Members were not created correctly.');
	   
	   list<CaseTeamMember> caseTeamMemberToAssert2 = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCaseChild2[0].id];
	   system.assertEquals(numOfCaseMember,caseTeamMemberToAssert2.size(), 'Case Team Members were not created correctly.');
	   
	   // b)	Add another 30 Case Team Members
    	for(integer i = 70 ; i<100; i++){
    		lstCaseTeamMembers.add(new CaseTeamMember (
    		 			ParentId = lstCase[0].id,
    		 			MemberId = listUsers[i].id,
    		 			TeamRoleId = role.id
        	 			));
    	}
	   insert lstCaseTeamMembers;
	   
	   resetID();
	   // Update Case on 1 level
	   lstCase[0].Case_Team_Updated__c = DateTime.now().addseconds(10);
       update lstCase; 
	   
	   // Asserts after insert	   
	   caseTeamMemberToAssert = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCase[0].id];
	   system.assertEquals(numOfCaseMember + 30,caseTeamMemberToAssert.size(),'Case Team Members were not created correctly.');
	   
	   caseTeamMemberToAssert1 = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCaseChild1[0].id];
	   system.assertEquals(numOfCaseMember + 30,caseTeamMemberToAssert1.size(), 'Case Team Members were not created correctly.');
	   
	   caseTeamMemberToAssert2 = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCaseChild2[0].id];
	   system.assertEquals(numOfCaseMember + 30,caseTeamMemberToAssert2.size(), 'Case Team Members were not created correctly.');
	   
	   system.debug(LoggingLevel.ERROR, 'DML rows query before positiveTestInsertSetOfAndAddAnotherCaseTeamMembers before END Test: ' + Limits.getDMLRows());
	   system.debug(loggingLevel.ERROR,'SOQL positiveTestInsertSetOfAndAddAnotherCaseTeamMembers() before END Test ' + limits.getQueries());   
    } //positiveTestInsertSetOfAndAddAnotherCaseTeamMembers()
    
    /** 
   	*	This test method contains tests for validating the behavior 
  	*	SCENARIO:		- One Case is created on first level. 5 Cases are created on second level. 10 Cases are created on third level. 
  	*					a) On first level 201 Case Team Members were created.
  	*					b) On first level 100 Case Team Members were deleted.
  	*					c) On first level ALL Case Team Members were deleted.
  	*	Expectations:	b) Case Team Members which were deleted on first level Case are deleted on related second and third level Cases automaticaly.
  	*					c) Case Team Members which were deleted on first level Case are deleted on related second and third level Cases automaticaly.
  	*/
    static testMethod void positiveTestInsertAndDeleteSetOfCaseTeamMembers() {
    	numOfCaseChild1 = 2;
    	numOfCaseChild2 = 4;
       // CREATE TEST DATA
	   createTestData();
	   
	   // a) On first level 201 Case Team Members were created.
	   insert lstCaseTeamMember;
	   
	   // Create Child Case 1
	   for(integer i = 0 ; i<numOfCaseChild1; i++){
    		lstCaseChild1.add(new Case (
    					Subject = 'TeslstCaseChild1' + i,
    		 			Status = 'New',
        	 			Case_Team_Updated__c = System.Now(),
        	 			ParentID = lstCase[0].id
        	 			));
    	}
    	insert lstCaseChild1;
    	
    	//Create Child Case 2
    	for(integer i = 0 ; i<numOfCaseChild2; i++){
    		lstCaseChild2.add(new Case (
    					Subject = 'TestlstCaseChild2' + i, 
    		 			Status = 'New',
        	 			Case_Team_Updated__c = System.Now(),
        	 			ParentID = lstCaseChild1[0].id
        	 			));
    	}
    	insert lstCaseChild2;
	   
	   // Asserts after insert	   
	   list<CaseTeamMember> caseTeamMemberToAssert = [SELECT id,ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCase[0].id];
	   system.assertEquals(numOfCaseMember,caseTeamMemberToAssert.size(),'Case Team Members were not created correctly.');
	   
	   list<CaseTeamMember> caseTeamMemberToAssert1 = [SELECT id,ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCaseChild1[0].id];
	   system.assertEquals(numOfCaseMember,caseTeamMemberToAssert1.size(), 'Case Team Members were not created correctly.');
	   
	   list<CaseTeamMember> caseTeamMemberToAssert2 = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCaseChild2[0].id];
	   system.assertEquals(numOfCaseMember,caseTeamMemberToAssert2.size(), 'Case Team Members were not created correctly.');
	   
	   // RUN TEST
	   Test.startTest();
	     	resetID();
		    // b) On first level 100 Case Team Members were deleted
	        set<Id> caseTeamMemberListToDelete = new set<Id>();
	        for(integer i=50;i< 150 ;i++){
	             caseTeamMemberListToDelete.add(caseTeamMemberToAssert[i].Id);
	        }
	        delete [SELECT Id FROM CaseTeamMember WHERE Id = :caseTeamMemberListToDelete];
        
        system.debug(LoggingLevel.ERROR, 'DML rows query positiveTestInsertAndDeleteSetOfCaseTeamMembers() before STOP Test: ' + Limits.getDMLRows());
        system.debug(loggingLevel.ERROR,'SOQL positiveTestInsertAndDeleteSetOfCaseTeamMembers() before STOP Test ' + limits.getQueries()); 
        Test.stopTest();
        
        // Update Case
		resetID();
       	lstCase[0].Case_Team_Updated__c = DateTime.now().addseconds(10);
       	update lstCase; 
		
		// Asserts after delete	   
	   	caseTeamMemberToAssert = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCase[0].id];
	   	system.assertEquals(numOfCaseMember - 100,caseTeamMemberToAssert.size(), 'Case Team Members were not deleted correctly.' );
	   
	   	caseTeamMemberToAssert1 = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCaseChild1[0].id];
	   	system.assertEquals(numOfCaseMember - 100,caseTeamMemberToAssert1.size(), 'Case Team Members were not deleted correctly.');
	   
	   	caseTeamMemberToAssert2 = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCaseChild2[0].id];
	   	system.assertEquals(numOfCaseMember - 100,caseTeamMemberToAssert2.size(), 'Case Team Members were not deleted correctly.');
        
	    // c) On first level ALL Case Team Members were deleted
        caseTeamMemberListToDelete = new set<Id>();
        resetID();
        for(integer i=0;i< caseTeamMemberToAssert.size() ;i++){
             caseTeamMemberListToDelete.add(caseTeamMemberToAssert[i].Id);
        }
        delete [SELECT Id FROM CaseTeamMember WHERE Id = :caseTeamMemberListToDelete];
        
        // Update Case
		resetID();
       	lstCase[0].Case_Team_Updated__c = DateTime.now().addseconds(10);
       	update lstCase; 
        
        // Asserts after delete	   
	   	caseTeamMemberToAssert = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCase[0].id];
	   	system.assertEquals(0,caseTeamMemberToAssert.size(), 'Case Team Members were not deleted correctly.' );
	   
	   	caseTeamMemberToAssert1 = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCaseChild1[0].id];
	   	system.assertEquals(0,caseTeamMemberToAssert1.size(), 'Case Team Members were not deleted correctly.');
	   
	   	caseTeamMemberToAssert2 = [SELECT ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCaseChild2[0].id];
	   	system.assertEquals(0, caseTeamMemberToAssert2.size(), 'Case Team Members were not deleted correctly.');
        
        system.debug(LoggingLevel.ERROR, 'DML rows query positiveTestInsertAndDeleteSetOfCaseTeamMembers() before END Test: ' + Limits.getDMLRows());
        system.debug(loggingLevel.ERROR,'SOQL positiveTestInsertAndDeleteSetOfCaseTeamMembers() before END Test ' + limits.getQueries()); 
    } // positiveTestInsertAndDeleteSetOfCaseTeamMembers()
    /** 
   	*	This test method contains tests for validating the behavior 
  	*	SCENARIO:		- 7 Cases are created on first level:
  	*							- lstCase[0].id have 41 Case Team Members
  	*							- lstCase[1].id have 40 Case Team Members
  	*							- lstCase[2].id have 20 Case Team Members
  	*							- lstCase[3].id have 20 Case Team Members
  	*							- lstCase[4].id have 20 Case Team Members
  	*							- lstCase[5].id have 30 Case Team Members
  	*							- lstCase[6].id have 30 Case Team Members
  	*					- 7 Cases are created on second level.
  	*					- 7 Cases are created on third level.
  	*	Expectations:	- Created Case Team Members will be cloned on releated Case/s on second and third level after their create.
  	*/
    static testMethod void positiveTestInsertMixData() {
	   numOfCase = 7;
	   numOfCaseMember = 201;
	   
	   // CREATE TEST DATA
	   createTestData();
	   
	   for(integer i = 0 ; i<20; i++){
    		lstCaseTeamMember[i].ParentId = lstCase[0].id;
    	}
	   for(integer i = 20 ; i<60; i++){
    		lstCaseTeamMember[i].ParentId = lstCase[1].id;
    	}
	   for(integer i = 60 ; i<80; i++){
    		lstCaseTeamMember[i].ParentId = lstCase[2].id;
    	}
	   for(integer i = 80 ; i<100; i++){
    		lstCaseTeamMember[i].ParentId = lstCase[3].id;
    	}
	   for(integer i = 100 ; i<120; i++){
    		lstCaseTeamMember[i].ParentId = lstCase[4].id;
    	}
	   for(integer i = 120 ; i<150; i++){
    		lstCaseTeamMember[i].ParentId = lstCase[5].id;
    	}
	   for(integer i = 150 ; i<180; i++){
    		lstCaseTeamMember[i].ParentId = lstCase[6].id;
    	}
	   
	   // RUN TEST
	   Test.startTest();
		   
		   // Insert Case team members
		   insert lstCaseTeamMember;
		   
	   system.debug(LoggingLevel.ERROR, 'DML rows query positiveTestInsertAndDeleteSetOfCaseTeamMembers() before STOP Test: ' + Limits.getDMLRows());
       system.debug(loggingLevel.ERROR,'SOQL positiveTestInsertAndDeleteSetOfCaseTeamMembers() before STOP Test ' + limits.getQueries()); 
       Test.stopTest();
	   
	   // Create Child Case 1
	   for(integer i = 0 ; i<7; i++){
    		lstCaseChild1.add(new Case (
    					Subject = 'TeslstCaseChild1' + i,
    		 			Status = 'New',
        	 			Case_Team_Updated__c = System.Now(),
        	 			ParentID = lstCase[i].id
        	 			));
    	}
    	insert lstCaseChild1;
    	
    	//Create Child Case 2
    	for(integer i = 0 ; i<7; i++){
    		lstCaseChild2.add(new Case (
    					Subject = 'TestlstCaseChild2' + i, 
    		 			Status = 'New',
        	 			Case_Team_Updated__c = System.Now(),
        	 			ParentID = lstCaseChild1[i].id
        	 			));
    	}
    	insert lstCaseChild2;
	   
	   // Asserts after insert	   
	   list<Case> caseToAssert = [SELECT Id FROM Case WHERE Id IN: lstCase order by id asc ];
	   
	   list<CaseTeamMember> caseTeamMemberToAssert1 = [SELECT id,ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId IN: lstCase];
	   system.assertEquals(numOfCaseMember,caseTeamMemberToAssert1.size(), 'Case Team Members were not created correctly.');
	   
        map<id, list<CaseTeamMember>> mapCaseTeamMemberByCaseId = new map<id, list<CaseTeamMember>>();
	        for(CaseTeamMember csMember :caseTeamMemberToAssert1){
	        	if(!mapCaseTeamMemberByCaseId.containsKey(csMember.ParentId)){
	        		mapCaseTeamMemberByCaseId.put(csMember.ParentId, new list<CaseTeamMember>());
	            }
	          mapCaseTeamMemberByCaseId.get(csMember.ParentId).add(csMember);
	        }
        for(Case objectCase :caseToAssert){
        	if(objectCase.id == lstCase[0].id){  
        		System.assertEquals(41,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not created correctly.');
        	}
        	if(objectCase.id == lstCase[1].id){  
        		System.assertEquals(40,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not created correctly.');
        	}
        	if(objectCase.id == lstCase[2].id){  
        		System.assertEquals(20,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not created correctly.');
        	}
        	if(objectCase.id == lstCase[3].id){  
        		System.assertEquals(20,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not created correctly.');
        	}
        	if(objectCase.id == lstCase[4].id){  
        		System.assertEquals(20,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not created correctly.');
        	}
        	if(objectCase.id == lstCase[5].id){  
        		System.assertEquals(30,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not created correctly.');
        	}
        	if(objectCase.id == lstCase[6].id){  
        		System.assertEquals(30,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not created correctly.');
        	}
        }
        
        // Asserts after insert	   
	   caseToAssert = [SELECT Id FROM Case WHERE Id IN: lstCase order by id asc ];
	   
	   caseTeamMemberToAssert1 = [SELECT id,ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId IN: lstCaseChild1];
	   system.assertEquals(numOfCaseMember,caseTeamMemberToAssert1.size(), 'Case Team Members were not created correctly.');
	   
        map<id, list<CaseTeamMember>> mapChild1CaseTeamMemberByCaseId = new map<id, list<CaseTeamMember>>();
	        for(CaseTeamMember csMember :caseTeamMemberToAssert1){
	        	if(!mapCaseTeamMemberByCaseId.containsKey(csMember.ParentId)){
	        		mapCaseTeamMemberByCaseId.put(csMember.ParentId, new list<CaseTeamMember>());
	            }
	          mapCaseTeamMemberByCaseId.get(csMember.ParentId).add(csMember);
	        }
        for(Case objectCase :caseToAssert){
        	if(objectCase.id == lstCase[0].id){  
        		System.assertEquals(41,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not cloned correctly.');
        	}
        	if(objectCase.id == lstCase[1].id){  
        		System.assertEquals(40,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not cloned correctly.');
        	}
        	if(objectCase.id == lstCase[2].id){  
        		System.assertEquals(20,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not cloned correctly.');
        	}
        	if(objectCase.id == lstCase[3].id){  
        		System.assertEquals(20,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not cloned correctly.');
        	}
        	if(objectCase.id == lstCase[4].id){  
        		System.assertEquals(20,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not cloned correctly.');
        	}
        	if(objectCase.id == lstCase[5].id){  
        		System.assertEquals(30,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not cloned correctly.');
        	}
        	if(objectCase.id == lstCase[6].id){  
        		System.assertEquals(30,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not cloned correctly.');
        	}
        }
        
        // Asserts after insert	   
	   caseToAssert = [SELECT Id FROM Case WHERE Id IN: lstCase order by id asc ];
	   
	   caseTeamMemberToAssert1 = [SELECT id,ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId IN: lstCaseChild2];
	   system.assertEquals(numOfCaseMember,caseTeamMemberToAssert1.size(), 'Case Team Members were not created correctly.');
	   
        map<id, list<CaseTeamMember>> mapChild2CaseTeamMemberByCaseId = new map<id, list<CaseTeamMember>>();
	        for(CaseTeamMember csMember :caseTeamMemberToAssert1){
	        	if(!mapCaseTeamMemberByCaseId.containsKey(csMember.ParentId)){
	        		mapCaseTeamMemberByCaseId.put(csMember.ParentId, new list<CaseTeamMember>());
	            }
	          mapCaseTeamMemberByCaseId.get(csMember.ParentId).add(csMember);
	        }
        for(Case objectCase :caseToAssert){
        	if(objectCase.id == lstCase[0].id){  
        		System.assertEquals(41,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not cloned correctly.');
        	}
        	if(objectCase.id == lstCase[1].id){  
        		System.assertEquals(40,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not cloned correctly.');
        	}
        	if(objectCase.id == lstCase[2].id){  
        		System.assertEquals(20,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not cloned correctly.');
        	}
        	if(objectCase.id == lstCase[3].id){  
        		System.assertEquals(20,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not cloned correctly.');
        	}
        	if(objectCase.id == lstCase[4].id){  
        		System.assertEquals(20,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not cloned correctly.');
        	}
        	if(objectCase.id == lstCase[5].id){  
        		System.assertEquals(30,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not cloned correctly.');
        	}
        	if(objectCase.id == lstCase[6].id){  
        		System.assertEquals(30,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not cloned correctly.');
        	}
        }
        
        system.debug(LoggingLevel.ERROR, 'DML rows query positiveTestInsertMixData() before END Test: ' + Limits.getDMLRows());
        system.debug(loggingLevel.ERROR,'SOQL positiveTestInsertMixData() before END Test ' + limits.getQueries()); 
    } // positiveTestInsertMixData()
    /** 
   	*	This test method contains tests for validating the behavior 
  	*	SCENARIO:		- 7 Cases are created on first level:
  	*							- lstCase[0].id have 41 Case Team Members
  	*							- lstCase[1].id have 40 Case Team Members
  	*							- lstCase[2].id have 20 Case Team Members
  	*							- lstCase[3].id have 20 Case Team Members
  	*							- lstCase[4].id have 20 Case Team Members
  	*							- lstCase[5].id have 30 Case Team Members
  	*							- lstCase[6].id have 30 Case Team Members
  	*					- 7 Cases are created on second level.
  	*					- 7 Cases are created on third level.
  	*	Expectations:	- Created Case Team Members will be cloned on releated Case/s on second and third level after their create automaticaly.
  	*					- Case Team Members which were deleted on first level Case are deleted on related second and third level Cases automaticaly.
  	*/
    static testMethod void positiveTestDeleteMixData() {
	   numOfCase = 7;
	   numOfCaseMember = 201;
	   
	   // CREATE TEST DATA
	   createTestData();
	   
	   for(integer i = 0 ; i<20; i++){
    		lstCaseTeamMember[i].ParentId = lstCase[0].id;
    	}
	   for(integer i = 20 ; i<60; i++){
    		lstCaseTeamMember[i].ParentId = lstCase[1].id;
    	}
	   for(integer i = 60 ; i<80; i++){
    		lstCaseTeamMember[i].ParentId = lstCase[2].id;
    	}
	   for(integer i = 80 ; i<100; i++){
    		lstCaseTeamMember[i].ParentId = lstCase[3].id;
    	}
	   for(integer i = 100 ; i<120; i++){
    		lstCaseTeamMember[i].ParentId = lstCase[4].id;
    	}
	   for(integer i = 120 ; i<150; i++){
    		lstCaseTeamMember[i].ParentId = lstCase[5].id;
    	}
	   for(integer i = 150 ; i<180; i++){
    		lstCaseTeamMember[i].ParentId = lstCase[6].id;
    	}
	   
	   // Insert Case team members
	   insert lstCaseTeamMember;
		   
	   // Create Child Case 1
	   for(integer i = 0 ; i<7; i++){
    		lstCaseChild1.add(new Case (
    					Subject = 'TeslstCaseChild1' + i,
    		 			Status = 'New',
        	 			Case_Team_Updated__c = System.Now(),
        	 			ParentID = lstCase[i].id
        	 			));
    	}
    	insert lstCaseChild1;
    	
    	//Create Child Case 2
    	for(integer i = 0 ; i<7; i++){
    		lstCaseChild2.add(new Case (
    					Subject = 'TestlstCaseChild2' + i, 
    		 			Status = 'New',
        	 			Case_Team_Updated__c = System.Now(),
        	 			ParentID = lstCaseChild1[i].id
        	 			));
    	}
    	insert lstCaseChild2;
	   
	   	// RUN TEST
	   Test.startTest();
		   	// Delete Case team Members
	        set<Id> caseTeamMemberListToDelete = new set<Id>();
	        resetID();
	        for(integer i=5;i< 10 ;i++){
	             caseTeamMemberListToDelete.add(lstCaseTeamMember[i].Id);
	        }
	        for(integer i=20;i< 60 ;i++){
	             caseTeamMemberListToDelete.add(lstCaseTeamMember[i].Id);
	        }
	        for(integer i=65;i< 70 ;i++){
	             caseTeamMemberListToDelete.add(lstCaseTeamMember[i].Id);
	        }
	        for(integer i=80;i< 100 ;i++){
	             caseTeamMemberListToDelete.add(lstCaseTeamMember[i].Id);
	        }
	        for(integer i=105;i< 110 ;i++){
	             caseTeamMemberListToDelete.add(lstCaseTeamMember[i].Id);
	        }
	        for(integer i=160;i< 201 ;i++){
	             caseTeamMemberListToDelete.add(lstCaseTeamMember[i].Id);
	        }
	        delete [SELECT Id FROM CaseTeamMember WHERE Id = :caseTeamMemberListToDelete];
	        
	        // Update Case
			resetID();
	       	lstCase[0].Case_Team_Updated__c = DateTime.now().addseconds(10);
	       	update lstCase; 
	       	
      system.debug(LoggingLevel.ERROR, 'DML rows query positiveTestDeleteMixData() before STOP Test: ' + Limits.getDMLRows());
      system.debug(loggingLevel.ERROR,'SOQL positiveTestDeleteMixData() before STOP Test ' + limits.getQueries()); 
      Test.stopTest();  
      
      // Asserts after delete	   
	  list<Case> caseToAssert = [SELECT Id FROM Case WHERE Id IN: lstCase order by id asc ];
	   
	  list<CaseTeamMember> caseTeamMemberToAssert1 = [SELECT id,ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId IN: lstCase];
	   
        map<id, list<CaseTeamMember>> mapCaseTeamMemberByCaseId = new map<id, list<CaseTeamMember>>();
	        for(CaseTeamMember csMember :caseTeamMemberToAssert1){
	        	if(!mapCaseTeamMemberByCaseId.containsKey(csMember.ParentId)){
	        		mapCaseTeamMemberByCaseId.put(csMember.ParentId, new list<CaseTeamMember>());
	            }
	          mapCaseTeamMemberByCaseId.get(csMember.ParentId).add(csMember);
	        }
        for(Case objectCase :caseToAssert){
        	if(objectCase.id == lstCase[0].id){  
        		System.assertEquals(15,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not deleted correctly.');
        	}
        	if(objectCase.id == lstCase[2].id){  
        		System.assertEquals(15,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not deleted correctly.');
        	}
        	if(objectCase.id == lstCase[4].id){  
        		System.assertEquals(15,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not deleted correctly.');
        	}
        	if(objectCase.id == lstCase[5].id){  
        		System.assertEquals(30,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not deleted correctly.');
        	}
        	if(objectCase.id == lstCase[6].id){  
        		System.assertEquals(10,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not deleted correctly.');
        	}
        }
        
       // Asserts after delete	   
	   caseToAssert = [SELECT Id FROM Case WHERE Id IN: lstCase order by id asc ];
	   
	   caseTeamMemberToAssert1 = [SELECT id,ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId IN: lstCaseChild1];
	   
        map<id, list<CaseTeamMember>> mapChild1CaseTeamMemberByCaseId = new map<id, list<CaseTeamMember>>();
	        for(CaseTeamMember csMember :caseTeamMemberToAssert1){
	        	if(!mapCaseTeamMemberByCaseId.containsKey(csMember.ParentId)){
	        		mapCaseTeamMemberByCaseId.put(csMember.ParentId, new list<CaseTeamMember>());
	            }
	          mapCaseTeamMemberByCaseId.get(csMember.ParentId).add(csMember);
	        }
        for(Case objectCase :caseToAssert){
        	if(objectCase.id == lstCase[0].id){  
        		System.assertEquals(15,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not deleted correctly.');
        	}
        	if(objectCase.id == lstCase[2].id){  
        		System.assertEquals(15,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not deleted correctly.');
        	}
        	if(objectCase.id == lstCase[4].id){  
        		System.assertEquals(15,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not deleted correctly.');
        	}
        	if(objectCase.id == lstCase[5].id){  
        		System.assertEquals(30,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not deleted correctly.');
        	}
        	if(objectCase.id == lstCase[6].id){  
        		System.assertEquals(10,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not deleted correctly.');
        	}
        }
        
        // Asserts after delete	   
	   caseToAssert = [SELECT Id FROM Case WHERE Id IN: lstCase order by id asc ];
	   
	   caseTeamMemberToAssert1 = [SELECT id,ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId IN: lstCaseChild2];
	   
        map<id, list<CaseTeamMember>> mapChild2CaseTeamMemberByCaseId = new map<id, list<CaseTeamMember>>();
	        for(CaseTeamMember csMember :caseTeamMemberToAssert1){
	        	if(!mapCaseTeamMemberByCaseId.containsKey(csMember.ParentId)){
	        		mapCaseTeamMemberByCaseId.put(csMember.ParentId, new list<CaseTeamMember>());
	            }
	          mapCaseTeamMemberByCaseId.get(csMember.ParentId).add(csMember);
	        }
        for(Case objectCase :caseToAssert){
        	if(objectCase.id == lstCase[0].id){  
        		System.assertEquals(15,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not deleted correctly.');
        	}
        	if(objectCase.id == lstCase[2].id){  
        		System.assertEquals(15,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not deleted correctly.');
        	}
        	if(objectCase.id == lstCase[4].id){  
        		System.assertEquals(15,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not deleted correctly.');
        	}
        	if(objectCase.id == lstCase[5].id){  
        		System.assertEquals(30,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not deleted correctly.');
        	}
        	if(objectCase.id == lstCase[6].id){  
        		System.assertEquals(10,mapCaseTeamMemberByCaseId.get(objectCase.Id).size(), 'Case Team Members were not deleted correctly.');
        	}
        }
      
      system.debug(LoggingLevel.ERROR, 'DML rows query positiveTestDeleteMixData() before END Test: ' + Limits.getDMLRows());
      system.debug(loggingLevel.ERROR,'SOQL positiveTestDeleteMixData() before END Test ' + limits.getQueries()); 
    } // positiveTestDeleteMixData()
   
    /** 
   	*	This test method contains tests for validating the behavior 
  	*	SCENARIO:		- One Case is created on first level. 5 Cases are created on second level.
  	*					- Case on first level is deleted.
  	*	Expectations:	- Case Team Members will be deleted on first level Case but Case on second level will be stay with releated Case Team Members.
  	*/
    static testMethod void positiveTestDeleteCase() {
       // CREATE TEST DATA
	   createTestData();
	   
   	   insert lstCaseTeamMember;
   	   
   	  	 // Create Child Case 1
    	for(integer i = 0 ; i<numOfCaseChild1; i++){
    		lstCaseChild1.add(new Case (
    					Subject = 'TeslstCaseChild1' + i,
    		 			Status = 'New',
        	 			Case_Team_Updated__c = System.Now(),
        	 			ParentID = lstCase[0].id
        	 			));
    	}
    	insert lstCaseChild1;
	    	
	   // Asserts after insert	   
	   list<CaseTeamMember> caseTeamMemberToAssert = [SELECT id,ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCase[0].id];
	   system.assertEquals(numOfCaseMember,caseTeamMemberToAssert.size(),'Case Team Members were not created correctly.');
	   
	   list<CaseTeamMember> caseTeamMemberToAssert1 = [SELECT id,ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCaseChild1[0].id];
	   system.assertEquals(numOfCaseMember,caseTeamMemberToAssert1.size(), 'Case Team Members were not created correctly.');
	   
	   // RUN TEST
	   Test.startTest();
	   		resetID();
	   		delete lstCase; 
       
       system.debug(loggingLevel.ERROR,'SOQL positiveTestDeleteCase() before STOP Test ' + limits.getQueries());
       system.debug(LoggingLevel.ERROR, 'DML rows query positiveTestDeleteCase() before STOP Test ' + Limits.getDMLRows());  
       Test.stopTest();
       
       // Asserts after insert	   
	   caseTeamMemberToAssert = [SELECT id,ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCase[0].id];
	   system.assertEquals(0,caseTeamMemberToAssert.size(),'Case Team Members were not deleted correctly.');
	   
	   caseTeamMemberToAssert1 = [SELECT id,ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId =: lstCaseChild1[0].id];
	   system.assertEquals(numOfCaseMember,caseTeamMemberToAssert1.size(), 'Case Team Members were not stay correctly.');
       
       system.debug(LoggingLevel.ERROR, 'DML rows query positiveTestDeleteCase() before END Test ' + Limits.getDMLRows());
       system.debug(loggingLevel.ERROR,'SOQL positiveTestDeleteCase() before END Test ' + limits.getQueries()); 
    } // positiveTestDeleteCase()
}