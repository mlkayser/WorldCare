/**
 *  Helper class for Trg_Case class. Class contains method for update field 'Request_Submitted_Not_Received_Hours__c' on Case
 */
public with sharing class Trg_Case_UpdateSubmittedNotReceivedHours {
	// Static set today date
	static Date dateToday = system.Today();
	//@TestVisible 
	public static Boolean inactiveCaseTriger = false;

	/**
	 * @description Called for set field 'Request_Submitted_Not_Received_Hours__c' after insert new Cases.
	 *
	 * @param caseId 	Map Cases records that were inserted.
	 */
	public void InsertRequestSubmittedNotReceivedHours(List<Case> listNewCases){
		// Setting conditions so that the method isn't running when launched from test method. Value inactiveCaseTriger is always set on FALSE, only in test method is changed on TRUE.
		if (Test.isRunningTest() && inactiveCaseTriger == true){
			return;
		}
			// Declare list
			list<Case> lstCase = new list <Case>();
			// Loop for add correct cases, on which will be set Request Submitted Not_Received_Hours _c
			for(Case objCase : listNewCases){
				if (objCase.Request_Submitted__c != null && objCase.Report_Received__c == null && (objCase.Request_Submitted__c).Date() != dateToday){
					lstCase.add(objCase);
				}
			}
			// Calling external method for update field 'Request_Submitted_Not_Received_Hours__c'
			UpdateElapsedHoursSchedule.ProcessUpdateElapsedHours(lstCase, false);
	}

	/**
	 * @description Called for set field 'Request_Submitted_Not_Received_Hours__c' after update Cases.
	 *
	 * @param caseId 	Map Cases records that were updated.
	 */
	public void UpdateRequestSubmittedNotReceivedHours(Map<Id, Case> mapNewCasesById, Map<Id, Case> mapOldCasesById){
		// Setting conditions so that the method isn't running when launched from test method. Value inactiveCaseTriger is always set on FALSE, only in test method is changed on TRUE.
		if (Test.isRunningTest() && inactiveCaseTriger == true){
			return;
		}
		// Declare list
		list<Case> lstCase = new list <Case>();
		// Loop for add correct cases, on which will be set Request Submitted Not_Received_Hours _c
		for(Case objCase : mapNewCasesById.values()){
			if (objCase.Request_Submitted__c != null && objCase.Report_Received__c == null && (objCase.Request_Submitted__c).Date() != dateToday && objCase.Request_Submitted__c != mapOldCasesById.get(objCase.Id).Request_Submitted__c ){
				lstCase.add(objCase);
			}
		}
		// Calling external method for update field 'Request_Submitted_Not_Received_Hours__c'
		UpdateElapsedHoursSchedule.ProcessUpdateElapsedHours(lstCase, false);	
	}
}