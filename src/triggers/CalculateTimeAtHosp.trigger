trigger CalculateTimeAtHosp on Case (before update) {

//Get the default Business Hours
        BusinessHours defaultHours = [select Id from BusinessHours where IsDefault=true];

// Get the updated and previous version of the case
        for (Case updatedCase:System.Trigger.new) {
            Case oldCase = System.Trigger.oldMap.get(updatedCase.Id);

// check to see if 'Report Received' or 'Submitted' has been changed
        if ((oldCase.Report_Received__c!=updatedCase.Report_Received__c || oldCase.Request_Submitted__c!=updatedCase.Request_Submitted__c) && updatedCase.Report_Received__c!=null && updatedCase.Request_Submitted__c!=null) {

//On the off-chance that the business hours on the case are null, use the default ones instead
         Id hoursToUse = updatedCase.BusinessHoursId!=null?updatedCase.BusinessHoursId:defaultHours.Id;

//The diff method comes back in milliseconds, so we divide by 3600000 to get hours.
         Double submittedtoReceived = BusinessHours.diff(hoursToUse, updatedCase.Request_Submitted__c, updatedCase.Report_Received__c)/3600000.0;
         System.debug(submittedtoReceived);
            
// Update the 'Turnaround_Time_Trigger__c' field on the case
            updatedCase.Turnaround_Time_Trigger__c = submittedtoReceived;
            }
        }
    }