public with sharing class Trg_Case {
	public static Set<Id> alreadyExecutedBefore = new Set<Id> ();
	public static Set<Id> alreadyExecutedAfter = new Set<Id> ();
	
	/**
	 * @description Called for before insert trigger execution.
	 * For each update Case where was change Submitted day on a day different from today
	 *
	 * @param listNewCases 	list of new cases
	 */
	public static void beforeInsert(List<Case> listNewCases) {
		Trg_Case_UpdateSubmittedNotReceivedHours updateNotReceivedHours = new Trg_Case_UpdateSubmittedNotReceivedHours();
		updateNotReceivedHours.InsertRequestSubmittedNotReceivedHours(listNewCases);

	}

	/**
	 * @description Called for before update trigger execution.
	 * For each update Case where was change Submitted day on a day different from today
	 *
	 * @param mapNewCasesById 	map of new values of cases
	 * @param mapOldCasesById 	map of old values of cases
	 */
	public static void beforeUpdate(Map<Id, Case> mapNewCasesById, Map<Id, Case> mapOldCasesById) {
		Trg_Case_UpdateSubmittedNotReceivedHours updateNotReceivedHours = new Trg_Case_UpdateSubmittedNotReceivedHours();
		updateNotReceivedHours.UpdateRequestSubmittedNotReceivedHours(mapNewCasesById,mapOldCasesById);
	}

	/**
	 * @description Called for before delete trigger execution.
	 *
	 * @param mapOldCasesById 	map of old values of cases
	 */
	public static void beforeDelete(Map<Id, Case> mapOldCasesById) {
	}

	/**
	 * @description Called for after insert trigger execution.
	 * For each new Case where Case Origin = Internal will be adding Creator to Case Team.
	 *								
	 * @param mapNewCasesById new Case records that were inserted
	 */
	public static void afterInsert(Map<Id, Case> mapNewCasesById) {
		// Create Case Team Members
		Trg_Case_CopyCaseTeamMember copyCaseTeamMember = new Trg_Case_CopyCaseTeamMember();
		copyCaseTeamMember.AddParentCaseTeamMemberToNewCase(mapNewCasesById);
		
	}

	/**
	 * @description Called for after update trigger execution.
	 * Copy Team Member from Parent to child case
	 *
	 * @param mapNewCasesById 	map of new values of cases
	 * @param mapOldCasesById 	map of old values of cases
	 */
	public static void afterUpdate(Map<Id, Case> mapNewCasesById, Map<Id, Case> mapOldCasesById) {
		Trg_Case_CopyCaseTeamMember copyCaseTeamMember = new Trg_Case_CopyCaseTeamMember();
		copyCaseTeamMember.CopyTeamMemberToChild(mapNewCasesById,mapOldCasesById);
		
	}

	/**
	 * @description Called for after delete trigger execution.
	 *
	 * @param mapOldCasesById 	map of old values of cases	
	 */
	public static void afterDelete(Map<Id, Case> mapOldCasesById) {
	}
}