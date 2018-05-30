/**
 *  Helper class for Trg_Case class. Class contains method for copy all Team Members from Parent.  
 */
public with sharing class Trg_Case_CopyCaseTeamMember {
	//Static map for copy Team Members to child case
	static map<Id,list<CaseTeamMember>> mapTeamMmebersForInsert;
	// Static set for save existed Id Team Members
	static Set<Id> setIdExistTeamMembers ;
	/**
	 * @description Called for copy all Team Members from parent to new Case
	 *
	 * @param mapNewCasesById 	new Cases records that were inserted
	 */
	public void AddParentCaseTeamMemberToNewCase(Map<Id, Case> mapNewCasesById){
		// Map new Cases
		map<Id,Id> mapNewCases = new map<Id,Id>();
		// Map Team Members by Parent Id
		map<Id,list<CaseTeamMember>> mapMemberByParentId = new map<Id,list<CaseTeamMember>>();
		// List Team Members
		list<CaseTeamMember> listTeamMembers = new list<CaseTeamMember>();
		// List Team Members which will be inserted to new Case
		list<CaseTeamMember> listNewTeamMember = new list <CaseTeamMember>();
		
		// Loop for obtain id parents
		for(Case newCase: mapNewCasesById.values()){
			mapNewCases.put(newCase.Id,newCase.ParentId);
		}
		// Loop for obtain all team members by ParentId
		for(CaseTeamMember members: [Select ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId IN : mapNewCases.values()]){
			if(!mapMemberByParentId.containsKey(members.ParentId)) {
				// Add team member to map
				mapMemberByParentId.put(members.ParentId,new list<CaseTeamMember>());
			}
			listTeamMembers = mapMemberByParentId.get(members.ParentId);
			// Add team member to list
			listTeamMembers.add(members);
		}
		// Loop for creating and assignment Team Members to Case
		for(Id UpdateCase : mapNewCases.keySet()){
			// Condition for empty map
			if (mapNewCases.get(UpdateCase) != null && mapMemberByParentId.get(mapNewCases.get(UpdateCase)) != null){
				//Loop for creating new Team Members
				for (CaseTeamMember addTeamMember : mapMemberByParentId.get(mapNewCases.get(UpdateCase))){
					listNewTeamMember.add(new CaseTeamMember(
						ParentId = UpdateCase,
						MemberId = addTeamMember.MemberId,
						TeamRoleId= addTeamMember.TeamRoleId));
				}
			}	
		}
		// Insert Team Members to DB
		if (!listNewTeamMember.isEmpty()){
			insert listNewTeamMember;
		}	
	}
	
	/**
	 * @description Called for copy all Team Members from parent to child Case
	 *
	 * @param mapNewCasesById 	Cases records that were updated
	 * @param mapOldCasesById	Cases records before updated
	 */
	public void CopyTeamMemberToChild(Map<Id, Case> mapNewCasesById, Map<Id, Case> mapOldCasesById){
		//Map Id Cases that were updated
		map<Id,Case> mapIdUpdateCases = new map<Id,Case>();
		// Declare a variable for Map Case Team Memebers that were updated 
		mapTeamMmebersForInsert = new map<Id, list<CaseTeamMember>>();
		// Declare a variable for Map existing Team Members
		setIdExistTeamMembers = new set<id>();
		
		// Loop for obtain Case id that were updated		
		for (Case updateCase : mapNewCasesById.values()){
			// Copy the Case Team Member only if the changed value in the fielde Case_Team_Updated__c.
			if (updateCase.Case_Team_Updated__c !=null && updateCase.Case_Team_Updated__c != mapOldCasesById.get(updateCase.Id).Case_Team_Updated__c ){
				mapIdUpdateCases.put(updateCase.Id,updateCase);
			}
		}
		// Calling the method for copying Case Team Member to child Cases
		CopyTeamMemberToSubChild(mapIdUpdateCases,null);
		// List existing Case Team Members that were delete
		list<CaseTeamMember> listDelExistTeamMembers = [Select Id FROM CaseTeamMember WHERE parentid IN :setIdExistTeamMembers];
		//Delete existing Case Team Members
		delete listDelExistTeamMembers;
		// List Case Team Memmbers that were inserted
		list<CaseTeamMember> lstCTMforInsert = new list<CaseTeamMember>();
		// Loop for adding Case Team Members to List
		for(Id caseId : mapTeamMmebersForInsert.keySet()){
			lstCTMforInsert.addAll(mapTeamMmebersForInsert.get(caseId));
		}
		// Insert Case Team Members to database
		insert lstCTMforInsert;
		// Clear list
		lstCTMforInsert.clear();
	}
	/**
	 * @description Called for copy all Team Members from parent to child Case
	 *
	 * @param caseId 	Id Cases records that were updated
	 * @param mapCaseTeamMemberforAllParent	Case Team Members from Parent Case
	 */
	public void CopyTeamMemberToSubChild(Map<Id, Case> caseId, Map<Id,List<CaseTeamMember>> mapCaseTeamMemberforAllParent){
		// Map Case Team Members by Parent Id
		map<Id,List<CaseTeamMember>> mapCaseTeamMembers = new map<Id,List<CaseTeamMember>>();
		// Map child Case by Parent Id
		map<Id,Case> mapChildCasebyParentId = new map<Id,Case>();
		// Map Case Team Members form Parent
		map<Id,List<CaseTeamMember>> mapCaseTeamMembersfromParent = new map<Id,List<CaseTeamMember>>();
		// List Team Members
		list<CaseTeamMember> listTeamMembers = new list<CaseTeamMember>();
		// List Team Members
		list<CaseTeamMember> lstCTMs;
		if (mapCaseTeamMemberforAllParent == null ){
			// Loop for finding Team Members by Parent Id
			for(CaseTeamMember teamMembers: [Select Id,ParentId,MemberId,TeamRoleId FROM CaseTeamMember WHERE parentId IN : caseId.keySet()]){	
					if(!mapCaseTeamMembers.containsKey(teamMembers.ParentId)) {
						// Add team member to map
						mapCaseTeamMembers.put(teamMembers.ParentId,new list<CaseTeamMember>());
					}
					listTeamMembers = mapCaseTeamMembers.get(teamMembers.ParentId);
					// Add team member to list
					listTeamMembers.add(teamMembers);
			}
		}
		else {
		 	mapCaseTeamMembers = mapCaseTeamMemberforAllParent;
		}
		// Loop for finding child Case by Parent Id
		for(Case childCase :[Select Id,ParentId FROM Case WHERE parentId IN : caseId.values()]){
			mapChildCasebyParentId.put(childCase.Id,childCase);
		}
		
		if (!mapChildCasebyParentId.isEmpty()){
			// Loop for added new Team Members to child Cases
			for(Id updateCase : mapChildCasebyParentId.keySet()){
				if(mapTeamMmebersForInsert.get(updateCase) == null) {
					mapTeamMmebersForInsert.put(updateCase, new list<CaseTeamMember>());
				}
				// Add Case Team Member to list
				lstCTMs = mapTeamMmebersForInsert.get(updateCase);
				// Condition for empty map
				if(mapCaseTeamMembers.containsKey(mapChildCasebyParentId.get(updateCase).ParentId)){
					//Loop for creating new Team Members
					for (CaseTeamMember addTeamMember : mapCaseTeamMembers.get(mapChildCasebyParentId.get(updateCase).ParentId)){
						lstCTMs.add(new CaseTeamMember(
							ParentId = updateCase,
							MemberId = addTeamMember.MemberId,
							TeamRoleId= addTeamMember.TeamRoleId));
					}
				}
				// Add new Case Team Member to map by Parent Id
				mapCaseTeamMembersfromParent.put(updateCase, lstCTMs);
				// Set Id Parents
				setIdExistTeamMembers.add(updateCase);
			}
			// Call recursive method for copying Case Team Members to sub Child Case
			CopyTeamMemberToSubChild(mapChildCasebyParentId,mapCaseTeamMembersfromParent);
		}
			
	}	
	
}