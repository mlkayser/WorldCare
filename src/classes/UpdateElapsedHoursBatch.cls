global without sharing class UpdateElapsedHoursBatch implements Database.Batchable<sObject>{
    
    //variables for test class to pass for finish method
    global list<Case> lstCaseNotReceived = new list<Case>();
    global list<Case> lstCaseReceived = new list<Case>();
    //==================================================
    
    global UpdateElapsedHoursBatch(){
        
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([Select id, Days_at_Hospital__c, Request_Submitted__c, Report_Received__c, Request_Submitted_Not_Received_Hours__c, Today_is_Holiday__c, BusinessHoursId from case where Request_Submitted__c != null AND Report_Received__c = null]);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        list<case> lstCase = (list<case>)(scope);
        UpdateElapsedHoursSchedule.ProcessUpdateElapsedHours(lstCase, true);
    }
    
    
    
    global void finish(Database.BatchableContext BC){
        
        // This part is dedicated for test class assertions
        if(Test.isRunningTest()){
            BusinessHours defaultHours = [select Id from BusinessHours where IsDefault=true];
	        
	        list<Case> lstCaseNotReceivedToAssert = [Select id, Days_at_Hospital__c, Request_Submitted__c, Report_Received__c, Request_Submitted_Not_Received_Hours__c, Today_is_Holiday__c, BusinessHoursId from case where id in : lstCaseNotReceived];
	        
	        for(Case objCase : lstCaseNotReceivedToAssert){
	            //On the off-chance that the business hours on the case are null, use the default ones instead
	            Id hoursToUse = objCase.BusinessHoursId!=null?objCase.BusinessHoursId:defaultHours.Id;
	
	            //The diff method comes back in milliseconds, so we divide by 3600000 to get hours.
	            datetime TodayAt1201am = datetime.newInstance(date.today(), time.newInstance(0, 1, 0, 0));
	            Double submittedToTodayAt1201am = BusinessHours.diff(hoursToUse, objCase.Request_Submitted__c, TodayAt1201am)/3600000.0;
	            system.assertEquals(submittedToTodayAt1201am, objCase.Request_Submitted_Not_Received_Hours__c);
	        }
	        
	        list<Case> lstCaseReceivedToAssert = [Select id, Days_at_Hospital__c, Request_Submitted__c, Report_Received__c, Request_Submitted_Not_Received_Hours__c, Today_is_Holiday__c, BusinessHoursId from case where id in : lstCaseReceived];
	        for(Case objCase : lstCaseReceivedToAssert){
	            system.assertEquals(null, objCase.Request_Submitted_Not_Received_Hours__c);
	        }
        }
    }
}