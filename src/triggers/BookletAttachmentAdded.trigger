trigger BookletAttachmentAdded on Attachment (after insert) {
 list<MedRec__c> MedRecs = new list<MedRec__c>();
    String MedRecPrefix = Schema.SObjectType.MedRec__c.getKeyPrefix();
    String currentURL = URL.getSalesforceBaseUrl().toExternalForm();
    
    for (Attachment objAtt : trigger.new) {
        //if Attachment is related to a MedRec
        if(objAtt.ParentId !=null && String.valueOf(objAtt.ParentId).left(3) == MedRecPrefix){
            
            MedRecs.add(new MedRec__c (
                Id = ObjAtt.ParentId, Attachment_ID__c = objAtt.Id, Attachment_Name__c = objAtt.Name, Download_Booklet__c = currentURL + '/servlet/servlet.FileDownload?file=' + objAtt.Id )); 
        }       
    }
    
    If(MedRecs.size() > 0) {
        update MedRecs;
    }   
}