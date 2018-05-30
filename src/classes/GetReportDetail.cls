public with sharing class GetReportDetail 
{
    public List<Case> Records {get; set;} 
    
    public GetReportDetail(){ 
        
        Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.Case.getRecordTypeInfosByName();
        Id standardRecTypeId = recordTypes.get('Patient Case').getRecordTypeId();
        
        Records = 
            [select CaseNumber, MRN__c, Subject,Initial_Diagnosis__c, Status,CreatedDate, Id from Case where RecordTypeId =: standardRecTypeId ORDER BY CreatedDate DESC limit 100 ]; 
        
       
    } 
}