public with sharing class MyCaseTeamWidgetController {
    @AuraEnabled
    public static List<Case> getCases() {
        
        ID caseRecordType1 = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Patient Case').getRecordTypeId();
        ID caseRecordType2 = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Patient Case - Acq Site Submitted').getRecordTypeId();
        ID medRecRecordType = Schema.SObjectType.MedRec__c.getRecordTypeInfosByName().get('Booklet/ES').getRecordTypeId();
        
        User user = [SELECT Id, Name from User where Id=: UserInfo.getUserId()]; 
        List<Case> recentlyCreatedCases = [SELECT Id, CreatedDate FROM Case ORDER BY CreatedDate DESC];
        Id caseId; 
        Map<Id,DateTime> caseIds = new Map<Id,DateTime>();
        for (Case recView : recentlyCreatedCases) {
            caseIds.put(recView.Id, recView.CreatedDate);
            System.debug('recView ID');
            System.debug(recView.Id);
            System.debug('CreatedDate');
            System.debug(recView.CreatedDate);
        }
        
        if (!caseIds.isEmpty()) {
            for(Case c : [Select Id, RecordTypeId from Case where Id IN: caseIds.keySet()]){
                if(c.RecordTypeId == caseRecordType1 || c.RecordTypeId == caseRecordType2){
                    if(caseId == null || (caseId != null && caseIds.get(caseId) < caseIds.get(c.Id)))
                        caseId = c.Id;
                }
            }                
        }
    
        if (caseId!=Null) {
            return [
                SELECT Id, CaseNumber, Nurse_Assignment__c,Nurse_Assignment_Email__c,Admin_Assignment__c,Admin_Assignment_Email__c,What_is_the_diagnosis_disease_or_condit__c,Initial_Diagnosis__c, OwnerId, Owner.Name, Status, CreatedDate, 
                (SELECT Id, Type__c, CreatedDate, CreatedDate_Without_Time__c, Status__c,Attachment_ID__c, Attachment_Name__c 
                 FROM MedRecs__r 
                 WHERE RecordTypeId =: medRecRecordType AND (Status__c='Ready to Send' OR Status__c='Sent - Nurse F/U')), 
                (SELECT Member.Name, Member.Email, TeamRole.Name 
                 FROM TeamMembers 
                 WHERE TeamRole.Name = 'Nurse' OR TeamRole.Name = 'Admin'),
                Initial_Complaint__c 
                FROM Case
                WHERE Id =: caseId];     
        }
        
        return new List<Case>();         
    }
    
    @AuraEnabled
    public static String getCurrentURL(){
        string Currenturl = URL.getSalesforceBaseUrl().toExternalForm();
        return (Currenturl);
    }
}