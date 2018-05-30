trigger Trg_Case on Case (after delete, after insert, after undelete,after update, before delete, before insert, before update) {
	Map<Id, Case> mapNewCasesForExecute = new Map<Id, Case> ();
	Map<Id, Case> mapOldCasesForExecute = new Map<Id, Case> ();

	// list of fields, for which we can run trigger if they are changed
	Set<String> setOfFields = new Set<String> {
		'Case_Team_Updated__c', 'Request_Submitted__c'
	};

	if (!Utils.needToRunTigger(setOfFields, mapNewCasesForExecute, mapOldCasesForExecute, Trg_Case.alreadyExecutedBefore, Trg_Case.alreadyExecutedAfter)) {
		return;
	}

	if (Trigger.isBefore) {
		if (Trigger.isInsert) {
			Trg_Case.BeforeInsert(Trigger.new);
		}
		if (Trigger.isUpdate) {
			Trg_Case.BeforeUpdate(mapNewCasesForExecute, mapOldCasesForExecute);
		}
		if (Trigger.isDelete) {
			Trg_Case.BeforeDelete(mapOldCasesForExecute);
		}
	} else if (Trigger.isAfter) {
		if (Trigger.isInsert) {
			Trg_Case.AfterInsert(mapNewCasesForExecute);
		}
		if (Trigger.isUpdate) {
			Trg_Case.AfterUpdate(mapNewCasesForExecute, mapOldCasesForExecute);
		}
		if (Trigger.isDelete) {
			Trg_Case.AfterDelete(mapOldCasesForExecute);
		}
	}

}