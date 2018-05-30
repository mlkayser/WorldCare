public with sharing class Utils {
	/**
	 * @description Called to check, if the trigger is executing first time in context on the same data.
	 * 
	 * @param setOfFields				Set Of Field Names, on which changes should be tracked 
	 * @param mapObjectForExecute		Map of sObjects by Id, which will contain all of the sObjects from Trigger.New. Can be not empty - if, for example we need to add record not from Trigger.new as a parameter
	 * @param mapOldObjectForExecute	Map of sObjects by Id, which will contain all of the sObjects from Trigger.Old. Can be not empty - if, for example we need to add record not from Trigger.new as a parameter
	 * @param alreadyExecutedBefore		Set of Ids of records, that have already been processed by before trigger 
	 * @param alreadyExecutedAfter		Set of Ids of records, that have already been processed by after trigger 
	 * @return							Boolean flag that indicates, if trigger execution is needed. (If the trigger did not run in this context) 
	 */
	public static Boolean needToRunTigger(Set<String> setOfFields, map<Id, sObject> mapObjectForExecute, Map<Id, sObject> mapOldObjectForExecute, Set<Id> alreadyExecutedBefore, Set<Id> alreadyExecutedAfter) {
		// We need run trigger for all records for before statement, becasue there are no IDs. 
		// If there will be issue with execution update after there is some workflow, need to create some custom ID during execution of before insert
		if (trigger.isInsert || trigger.isUndelete) {

			// for each object from Trigger.New - add it to mapObjectForExecute collection
			for (sObject theObject : Trigger.new) {
				mapObjectForExecute.put(theObject.id, theObject);
			}
			// if it's after insert trigger, we do not want run update trigger after there is some workflow, which fire update trigger
			if (trigger.isAfter) {
				for (sObject theObject : trigger.new) {
					alreadyExecutedBefore.add(theObject.Id);
					alreadyExecutedAfter.add(theObject.Id);
				}
			}
		} else if (trigger.isUpdate) {
			Boolean change;
			// check for field updates for each object from trigger.new
			for (sObject theObject : trigger.new) {
				change = false;
				if (setOfFields.isEmpty()) {
					change = true;
				} else {
					// check if monitored fields were changed or not
					for (String field : setOfFields) {
						if (theObject.get(field) != trigger.oldMap.get(theObject.id).get(field)) {
							change = true;
							break;
						}
					}
				}
				// if any field was changed, we want to work with record
				if (change) {
					if (trigger.isBefore) {
						if (!alreadyExecutedBefore.contains(theObject.Id)) {
							alreadyExecutedBefore.add(theObject.Id);
							mapObjectForExecute.put(theObject.Id, theObject);
							mapOldObjectForExecute.put(theObject.id, trigger.oldMap.get(theObject.id));
						}
					} else {
						if (!alreadyExecutedAfter.contains(theObject.Id)) {
							alreadyExecutedAfter.add(theObject.Id);
							mapObjectForExecute.put(theObject.Id, theObject);
							mapOldObjectForExecute.put(theObject.id, trigger.oldMap.get(theObject.id));
						}
					}
				}
			}
		} else if (trigger.isDelete) {
			if (trigger.isBefore) {
				// fill alreadyExecutedBefore - Set of Ids, and mapOldObjectForExecute - map of id -> sObject
				for (sObject theObject : trigger.old) {
					if (!alreadyExecutedBefore.contains(theObject.Id)) {
						alreadyExecutedBefore.add(theObject.Id);
						mapOldObjectForExecute.put(theObject.id, trigger.oldMap.get(theObject.id));
					}
				}
			} else {
				// fill alreadyExecutedAfter - Set of Ids, and mapOldObjectForExecute - map of id -> sObject
				for (sObject theObject : trigger.old) {
					if (!alreadyExecutedAfter.contains(theObject.Id)) {
						alreadyExecutedAfter.add(theObject.Id);
						mapOldObjectForExecute.put(theObject.id, trigger.oldMap.get(theObject.id));
					}
				}
			}
		}
		// if there are not records for execute, we do not need run trigger
		if (mapObjectForExecute.isEmpty() && mapOldObjectForExecute.isEmpty()) {
			system.debug(logginglevel.error, 'mapObjectForExecute1: ' + mapObjectForExecute);
			system.debug(logginglevel.error, 'mapOldObjectForExecute1: ' + mapOldObjectForExecute);
			return false;
		}
		return true;
	}
}