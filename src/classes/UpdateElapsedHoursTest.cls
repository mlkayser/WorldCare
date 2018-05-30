/**
 * This class contains unit tests for validating the behavior of Apex class 'UpdateElapsedHoursBatch.cls'.
 *
 * @autor Pavol Pilc (v2analyst@v2sa.com)
 *
 * Created: 2016-January-12
 */

@isTest(seeAllData = false)
public class UpdateElapsedHoursTest {
	// Declare method for reset Id
	static void resetID(){
   		Trg_Case.alreadyExecutedBefore = new Set<Id>();
        Trg_Case.alreadyExecutedAfter = new Set<Id>();
    } 
   
    /** 
   	*	This test method contains tests for validating the behavior of Apex class 'UpdateElapsedHoursBatch.cls'.
  	*	SCENARIO:	Create 201 cases with filled field 'Report_Received__c' and not filled field 'Report_Received__c'.
  	*	Expectations: After insert new cases will does not start trigger and therefore not filled field 'Request_Submitted_Not_Received_Hours__c'.
  	*/
    static testmethod void testNotRunTrigger(){
    	// Declare value
        list<Case> lstCase = new list<Case>();
        list<Case> lstCaseNotReceived = new list<Case>();
        list<Case> lstCaseReceived = new list<Case>();
		
		// Preparation of the test data
		Case newCase;
		integer Casenumber = 201;
		integer notreceivednumber = 3;
		
		for(integer i = 0 ; i<Casenumber; i++){
		    newCase = new Case(Request_Submitted__c = datetime.now().adddays(-3), Report_Received__c = (i < notreceivednumber)?null:datetime.now().adddays(-1));
		    if(i < notreceivednumber){
		        lstCaseNotReceived.add(newCase);
		    }
		    else{
		        lstCaseReceived.add(newCase);
		    } 
		}
		// Add create cases to list
		lstCase.addall(lstCaseNotReceived);
		lstCase.addall(lstCaseReceived);
		
		// Set variable inactiveCaseTriger = true based on which trigger will be running
		Trg_Case_UpdateSubmittedNotReceivedHours.inactiveCaseTriger = true;
		// Insert 201 Cases
		insert lstCase; 
		
		list<Case> listCasesToAssert = [SELECT id, Request_Submitted_Not_Received_Hours__c FROM Case WHERE id In: lstCase];
		// Check if were created 201 cases
		system.assertEquals(201, listCasesToAssert.size()); 
		
		for(Case objCase : listCasesToAssert ){ // we are expecting that field will be NULL becasue trigger was not running
			system.assertEquals(null, objCase.Request_Submitted_Not_Received_Hours__c, 'Field Request Submitted Not Received Hours was populated correctly.'); 
		}	  
		
		// Run Test
		system.Test.startTest();
		
			// Run schedule class
	        UpdateElapsedHoursSchedule MyUpdateElapsedHoursSchedule = new UpdateElapsedHoursSchedule();
	        MyUpdateElapsedHoursSchedule.BatchUEB.lstCaseNotReceived = lstCaseNotReceived;
	        MyUpdateElapsedHoursSchedule.BatchUEB.lstCaseReceived = lstCaseReceived;
	        system.schedule('V2SA_AnalyticSnapshotBO', UpdateElapsedHoursSchedule.GetCron(), MyUpdateElapsedHoursSchedule);
        	
        	system.debug(loggingLevel.ERROR,'SOQL testNotRunTrigger() before STOP Test ' + limits.getQueries()); 	   
	    	system.debug(LoggingLevel.ERROR, 'DML rows query before stopTest() testNotRunTrigger() unit test: ' + Limits.getDMLRows());
        system.Test.stopTest();
        
        /*BusinessHours defaultHours = [select Id from BusinessHours where IsDefault=true];
        
        list<Case> lstCaseNotReceivedToAssert = [Select id, Days_at_Hospital__c, Request_Submitted__c, Report_Received__c, Request_Submitted_Not_Received_Hours__c, Today_is_Holiday__c, BusinessHoursId from case where id in : lstCaseNotReceived];
        
        for(Case objCase : lstCaseNotReceivedToAssert){
            //On the off-chance that the business hours on the case are null, use the default ones instead
            Id hoursToUse = objCase.BusinessHoursId!=null?objCase.BusinessHoursId:defaultHours.Id;

            //The diff method comes back in milliseconds, so we divide by 3600000 to get hours.
            datetime TodayAt1201am = datetime.newInstance(date.today(), time.newInstance(0, 1, 0, 0));
            Double submittedToTodayAt1201am = BusinessHours.diff(hoursToUse, objCase.Request_Submitted__c, TodayAt1201am)/3600000.0;
            system.assertEquals(submittedToTodayAt1201am, objCase.Request_Submitted_Not_Received_Hours__c);
        } */
        
        system.debug(LoggingLevel.ERROR, 'DML rows query before stopTest() testNotRunTrigger() END Test: ' + Limits.getDMLRows());
	    system.debug(loggingLevel.ERROR,'SOQL testNotRunTrigger() before END Test ' + limits.getQueries()); 
    }
    
    /** 
   	*	This test method contains tests for validating the behavior of Apex class 'Trg_Case_UpdateSubmittedNotReceivedHours.cls'.
  	*	SCENARIO:	Create 201 cases
  	*	Expectations: After inserting the new cases was launched trigger and therefore be filled fields Request_Submitted_Not_Received_Hours _c
  	*/
    static testmethod void testRunningTrigerAfterInsert() {
        // Declare value
        list<Case> lstCase = new list<Case>();
        list<Case> lstCaseNotReceived = new list<Case>();
        list<Case> lstCaseReceived = new list<Case>();
		
		// Preparation of the test data
		Case newCase;
		integer Casenumber = 201;
		
		for(integer i = 0 ; i<Casenumber; i++){
		    newCase = new Case(Request_Submitted__c = datetime.now().adddays(-3));
		    lstCaseNotReceived.add(newCase);
		}
		// Add create cases to list
		lstCase.addall(lstCaseNotReceived);
		lstCase.addall(lstCaseReceived);
			
		// Run Test
		system.Test.startTest();
			// Insert Cases
			insert lstCase;
		
        system.Test.stopTest();
        
         // Asserts after insert Cases
		list<Case> listCasesToAssert = [SELECT id, Request_Submitted_Not_Received_Hours__c FROM Case WHERE id In: lstCase];
		// Check if were created 201 cases
		system.assertEquals(201, listCasesToAssert.size());
		
		// we are expecting that field was NOT null because trigger was running
		for(Case objCase : listCasesToAssert ){ 
			system.assertNOTEquals(null, objCase.Request_Submitted_Not_Received_Hours__c, 'Request Submitted Not Received Hours was not null incorrect.');
		}
		 
        system.debug(LoggingLevel.ERROR, 'DML rows query before stopTest() testRunningTrigerAfterInsert() END Test: ' + Limits.getDMLRows());
	    system.debug(loggingLevel.ERROR,'SOQL testRunningTrigerAfterInsert() before END Test ' + limits.getQueries()); 	 
        
    }
    
    /** 
   	*	This test method contains tests for validating the behavior of Apex class 'Trg_Case_UpdateSubmittedNotReceivedHours.cls'.
  	*	SCENARIO:	Create 7 cases (4 not received cases and 3 received cases)
  	*	Expectations: After inserting the new cases was launched trigger and therefore be filled fields Request_Submitted_Not_Received_Hours _c only for not received cases
  	*/
    static testmethod void testRunningTrigerAfterInsertDifferentData() {
         // Declare value
        list<Case> lstCase = new list<Case>();
        list<Case> lstCaseNotReceived = new list<Case>();
        list<Case> lstCaseReceived = new list<Case>();
		
		// Preparation of the test data
		Case newCase;
		integer Casenumber = 7;
		integer notreceivednumber = 4;
		
		for(integer i = 0 ; i<Casenumber; i++){
		    newCase = new Case(Request_Submitted__c = datetime.now().adddays(-i), Report_Received__c = (i < notreceivednumber)?null:datetime.now().adddays(-i));
		    if(i < notreceivednumber){
		        lstCaseNotReceived.add(newCase);
		    }
		    else{
		        lstCaseReceived.add(newCase);
		    } 
		}
		// Add create cases to list
		lstCase.addall(lstCaseNotReceived);
		lstCase.addall(lstCaseReceived);
		
			
				
		// Start test
		system.Test.startTest();
			
			resetID();
			// Insert Cases
			insert lstCase;
	        
	        system.debug(loggingLevel.ERROR,'SOQL testRunningTrigerAfterInsertDifferentData() before STOP Test ' + limits.getQueries()); 	   
		    system.debug(LoggingLevel.ERROR, 'DML rows query before stopTest() testRunningTrigerAfterInsertDifferentData() unit test: ' + Limits.getDMLRows());
        // Stop test	
		system.Test.stopTest();
        
		// Asserts after update Cases
		list<Case> listCasesToAssert = [SELECT id, Request_Submitted_Not_Received_Hours__c FROM Case WHERE id In: lstCase];
		// Check if were created 7 cases
		system.assertEquals(7, listCasesToAssert.size()); 
		
		system.assertEquals(null, listCasesToAssert[0].Request_Submitted_Not_Received_Hours__c, 'Request Submitted Not Received Hours was not populated with null correctly.');
		system.assertNotEquals(null, listCasesToAssert[1].Request_Submitted_Not_Received_Hours__c, 'Request Submitted Not Received Hours was not null incorrect.');
		system.assertNotEquals(null, listCasesToAssert[2].Request_Submitted_Not_Received_Hours__c, 'Request Submitted Not Received Hours was not null incorrect.');
		system.assertNotEquals(null, listCasesToAssert[3].Request_Submitted_Not_Received_Hours__c, 'Request Submitted Not Received Hours was not null incorrect.');
		system.assertEquals(null, listCasesToAssert[4].Request_Submitted_Not_Received_Hours__c, 'Request Submitted Not Received Hours was not populated with null correctly.');
		system.assertEquals(null, listCasesToAssert[5].Request_Submitted_Not_Received_Hours__c, 'Request Submitted Not Received Hours was not populated with null correctly.');
		system.assertEquals(null, listCasesToAssert[6].Request_Submitted_Not_Received_Hours__c, 'Request Submitted Not Received Hours was not populated with null correctly.');

		system.debug(LoggingLevel.ERROR, 'DML rows query before stopTest() testRunningTrigerAfterInsertDifferentData() END Test: ' + Limits.getDMLRows());
	    system.debug(loggingLevel.ERROR,'SOQL testRunningTrigerAfterInsertDifferentData() before END Test ' + limits.getQueries()); 
        
    }
    
    /** 
   	*	This test method contains tests for validating the behavior of Apex class 'Trg_Case_UpdateSubmittedNotReceivedHours.cls'.
  	*	SCENARIO:	Create 7 cases (4 not received cases and 3 received cases)
  	*	Expectations: After update cases was not launched trigger and therefore not be filled fields Request_Submitted_Not_Received_Hours _c.
  	*/
    static testmethod void testNotRunningTrigerAfterUpdateDifferentData() {
        // Declare value
        list<Case> lstCase = new list<Case>();
        list<Case> lstCaseNotReceived = new list<Case>();
        list<Case> lstCaseReceived = new list<Case>();
		
		// Preparation of the test data
		Case newCase;
		integer Casenumber = 7;
		integer notreceivednumber = 4;
		
		for(integer i = 0 ; i<Casenumber; i++){
		    newCase = new Case(Request_Submitted__c = datetime.now().adddays(-3), Report_Received__c = (i < notreceivednumber)?null:datetime.now().adddays(-i));
		    if(i < notreceivednumber){
		        lstCaseNotReceived.add(newCase);
		    }
		    else{
		        lstCaseReceived.add(newCase);
		    } 
		}
		// Add create cases to list
		lstCase.addall(lstCaseNotReceived);
		lstCase.addall(lstCaseReceived);
		
		// Set variable inactiveCaseTriger = true based on which trigger will be running
		Trg_Case_UpdateSubmittedNotReceivedHours.inactiveCaseTriger = true;
		// Insert Cases
		insert lstCase;
		
		// UPDATE: Change field Request_Submitted__c to date = datetime.now() - i -1
		for(integer i = 0 ; i<Casenumber; i++){ // trigger does not run and we are expecting that Request_Submitted_Not_Received_Hours__c will be empty
			lstCase[i].Request_Submitted__c = datetime.now() - i;
		}
			
		// Run Test
		system.Test.startTest();
			
			Trg_Case_UpdateSubmittedNotReceivedHours.inactiveCaseTriger = true;
			resetID();
			update lstCase;
			
	        system.debug(loggingLevel.ERROR,'SOQL testRunningTrigerAfterUpdateDifferentData() before STOP Test ' + limits.getQueries()); 	   
			system.debug(LoggingLevel.ERROR, 'DML rows query before stopTest() testRunningTrigerAfterUpdateDifferentData() unit test: ' + Limits.getDMLRows());
    	// Stop Test
        system.Test.stopTest();
        
        // Asserts after update Case	
    	list<Case> listCasesToAssert = [SELECT id, Request_Submitted_Not_Received_Hours__c FROM Case WHERE id In: lstCase];
    	// Check if were created 7 cases
		system.assertEquals(7, listCasesToAssert.size()); 
		
		// we are expecting that field was NOT null because trigger was running
		for(Case objCase : listCasesToAssert ){ 
			system.assertEquals(null, objCase.Request_Submitted_Not_Received_Hours__c, 'Request Submitted Not Received Hours was not populated with null correctly.');
		}

		system.debug(LoggingLevel.ERROR, 'DML rows query before stopTest() testRunningTrigerAfterUpdateDifferentData() END Test: ' + Limits.getDMLRows());
	    system.debug(loggingLevel.ERROR,'SOQL testRunningTrigerAfterUpdateDifferentData() before END Test ' + limits.getQueries()); 
    }
    
    /** 
   	*	This test method contains tests for validating the behavior of Apex class 'Trg_Case_UpdateSubmittedNotReceivedHours.cls'.
  	*	SCENARIO:	Create 7 cases (4 not received cases and 3 received cases)
  	*	Expectations: After update cases was launched trigger and therefore be filled fields Request_Submitted_Not_Received_Hours _c only for not received cases
  	*/
    static testmethod void testRunningTrigerAfterUpdateDifferentData() {
        // Declare value
        list<Case> lstCase = new list<Case>();
        list<Case> lstCaseNotReceived = new list<Case>();
        list<Case> lstCaseReceived = new list<Case>();
		
		// Preparation of the test data
		Case newCase;
		integer Casenumber = 7;
		integer notreceivednumber = 4;
		
		for(integer i = 0 ; i<Casenumber; i++){
		    newCase = new Case(Request_Submitted__c = datetime.now().adddays(-3), Report_Received__c = (i < notreceivednumber)?null:datetime.now().adddays(-i));
		    if(i < notreceivednumber){
		        lstCaseNotReceived.add(newCase);
		    }
		    else{
		        lstCaseReceived.add(newCase);
		    } 
		}
		// Add create cases to list
		lstCase.addall(lstCaseNotReceived);
		lstCase.addall(lstCaseReceived);
		
		// Set variable inactiveCaseTriger = true based on which trigger will be running
		Trg_Case_UpdateSubmittedNotReceivedHours.inactiveCaseTriger = true;
		// Insert Cases
		insert lstCase;
		
		// UPDATE: Change field Request_Submitted__c to date = datetime.now() - i -1
		for(integer i = 0 ; i<Casenumber; i++){ // trigger does not run and we are expecting that Request_Submitted_Not_Received_Hours__c will be empty
			lstCase[i].Request_Submitted__c = datetime.now() - i;
		}
		
			
		// Set variable inactiveCaseTriger = true based on which trigger will be running
		
			
		// Run Test
		system.Test.startTest();
			
			Trg_Case_UpdateSubmittedNotReceivedHours.inactiveCaseTriger = false;
			resetID();
			update lstCase;
			
	        system.debug(loggingLevel.ERROR,'SOQL testRunningTrigerAfterUpdateDifferentData() before STOP Test ' + limits.getQueries()); 	   
			system.debug(LoggingLevel.ERROR, 'DML rows query before stopTest() testRunningTrigerAfterUpdateDifferentData() unit test: ' + Limits.getDMLRows());
    	// Stop Test
        system.Test.stopTest();
        
        // Asserts after update Case	
    	list<Case> listCasesToAssert = [SELECT id, Request_Submitted_Not_Received_Hours__c FROM Case WHERE id In: lstCase];
    	// Check if were created 7 cases
		system.assertEquals(7, listCasesToAssert.size()); 
		
		// We are expecting that field was NOT null because trigger was running		
		system.assertEquals(null, listCasesToAssert[0].Request_Submitted_Not_Received_Hours__c, 'Request Submitted Not Received Hours was not populated with null correctly.');
		system.assertNotEquals(null, listCasesToAssert[1].Request_Submitted_Not_Received_Hours__c, 'Request Submitted Not Received Hours was not null incorrect.');
		system.assertNotEquals(null, listCasesToAssert[2].Request_Submitted_Not_Received_Hours__c, 'Request Submitted Not Received Hours was not null incorrect.');
		system.assertNotEquals(null, listCasesToAssert[3].Request_Submitted_Not_Received_Hours__c, 'Request Submitted Not Received Hours was not null incorrect.');
		system.assertEquals(null, listCasesToAssert[4].Request_Submitted_Not_Received_Hours__c, 'Request Submitted Not Received Hours was not populated with null correctly.');
		system.assertEquals(null, listCasesToAssert[5].Request_Submitted_Not_Received_Hours__c, 'Request Submitted Not Received Hours was not populated with null correctly.');
		system.assertEquals(null, listCasesToAssert[6].Request_Submitted_Not_Received_Hours__c, 'Request Submitted Not Received Hours was not populated with null correctly.');

		system.debug(LoggingLevel.ERROR, 'DML rows query before stopTest() testRunningTrigerAfterUpdateDifferentData() END Test: ' + Limits.getDMLRows());
	    system.debug(loggingLevel.ERROR,'SOQL testRunningTrigerAfterUpdateDifferentData() before END Test ' + limits.getQueries()); 
    }
    
    
    
    //cover RunMe only//used for testing from UI
    static testmethod void testfromUi() {
        
        
        system.Test.startTest();
        
        	UpdateElapsedHoursSchedule.RunMe();
        	system.debug(loggingLevel.ERROR,'SOQL testfromUi before STOP Test ' + limits.getQueries()); 	   
		    system.debug(LoggingLevel.ERROR, 'DML rows query before stopTest() testfromUi unit test: ' + Limits.getDMLRows());
        
        system.Test.stopTest();
        
        system.debug(LoggingLevel.ERROR, 'DML rows query before stopTest() testfromUi END Test: ' + Limits.getDMLRows());
	    system.debug(loggingLevel.ERROR,'SOQL testfromUi before END Test ' + limits.getQueries());
        
    }
    
    /** 
   	*	This test method contains tests for validating the behavior of Apex class 'Trg_Case.cls'.
  	*/
    static testmethod void testPositiveCodeCoverage() {
    	// Preparation of the test data
        Case newCase;
        newCase = new Case(Request_Submitted__c = datetime.now().adddays(-1), Report_Received__c = null);
        
        // Insert Case
        insert newCase;
        
        // Asserts after insert Case
        list<Case> listCasesToAssert = [SELECT id, Request_Submitted_Not_Received_Hours__c FROM Case WHERE id =: newCase.id];
		// Check if were created 1 cases
		system.assertEquals(1, listCasesToAssert.size()); 

		// Start Test
        system.Test.startTest();
        
			resetID();
			delete listCasesToAssert;
			// Asserts after delete Case
	        listCasesToAssert = [SELECT id, Request_Submitted_Not_Received_Hours__c FROM Case WHERE id =: newCase.id];
			// Check if were created 0 cases
			system.assertEquals(0, listCasesToAssert.size()); 
  			
  			system.debug(loggingLevel.ERROR,'SOQL testPositiveCodeCoverage() before STOP Test ' + limits.getQueries()); 	   
		    system.debug(LoggingLevel.ERROR, 'DML rows query before stopTest() testPositiveCodeCoverage() unit test: ' + Limits.getDMLRows());
		    
  		// Stop Test
        system.Test.stopTest();  
        
        system.debug(LoggingLevel.ERROR, 'DML rows query before stopTest() testPositiveCodeCoverage() END Test: ' + Limits.getDMLRows());
	    system.debug(loggingLevel.ERROR,'SOQL testPositiveCodeCoverage() before END Test ' + limits.getQueries());
    }   
}