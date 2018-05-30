@isTest

private Class CalculateTimeAtHospTest {

    static testMethod void testCalculateTimeAtHosp() {
    
        Case c = new case(Status = 'New', Type = 'Second Opinion');
        insert c;

        c.Status = 'On Hold';
        c.Request_Submitted__c = System.Now();
        update c;

        c.Report_Received__c = System.Now();
        update c;

    Case updatedCase = [select Report_Received__c,Turnaround_Time_Trigger__c from Case where Id=:c.Id];
    
    System.assert(updatedCase.Report_Received__c!=null);
    System.assert(updatedCase.Turnaround_Time_Trigger__c !=null);

    }
}