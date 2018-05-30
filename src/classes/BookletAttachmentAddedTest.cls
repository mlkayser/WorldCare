@isTest
private class BookletAttachmentAddedTest 
{
    static testMethod void testBookletAttachmentAdded()
    {
        list<MedRec__c> ListMedRecs = new list<MedRec__c>();
        String MedRecPrefix = Schema.SObjectType.MedRec__c.getKeyPrefix();
        String currentURL = URL.getSalesforceBaseUrl().toExternalForm();
   
        //Body to Attachment object
        list<string>strlst=new list<string>{'a','b'};
        string bod='';
        for(string s:strlst)
        {
            bod=bod+''+s;
        }
        Blob b = Blob.valueOf(bod);
        
        //Account test Object
        Account acc = new Account(Name = 'testaccount');
        insert acc;
        
        //Contact Test Object to create new case
        Contact cc = new Contact(LastName = 'TestLastName', Account = acc);
        insert cc;
        
        //Case test to create a MedRec__c Object
        Case cse = new Case(Account = acc, Contact =cc);
        insert cse;
        
        //New MedRec__c object to create Attachment object test
        MedRec__c med = new MedRec__c(Case__c = cse.Id);
        insert med;
        
        //Create the new Attachment test object
        Attachment Att = new Attachment(Name = 'BookletAttachment Test', ParentId = med.Id, Body = b);
        insert Att;
        
        //if Attachment is related to a MedRec
        if(Att.ParentId != null && String.valueOf(Att.ParentId).left(3) == MedRecPrefix)
        {
            ListMedRecs.add(new MedRec__c (
            Id = Att.ParentId, Attachment_ID__c = Att.Id, Attachment_Name__c = Att.Name, Download_Booklet__c = currentURL + '/servlet/servlet.FileDownload?file=' + Att.Id )); 
        }
        
        if(ListMedRecs.size() > 0)
        {
            update ListMedRecs;
        }
    }
    
}