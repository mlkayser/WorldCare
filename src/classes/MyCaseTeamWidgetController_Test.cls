@isTest(SeeAllData=true)
private class MyCaseTeamWidgetController_Test {

    @isTest static void testmethod1(){
        ID caseRecordType1 = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Patient Case').getRecordTypeId();
        Case testCase = new Case(RecordTypeId=caseRecordType1, Subject='Test Case', Status='Admin Intake', Type='Primary Read');
        insert testCase;

        Test.startTest();
        MyCaseTeamWidgetController.getCases();
        Test.stopTest();   
        
        // verify results
        System.debug(testCase);
    }

    @isTest static void testGetCurrentURL() {        
        Test.startTest();
        String url = customProfileMenuController.getCurrentURL();
        Test.stopTest();
        
        // verify results
        System.assert(url != null);           
	}
}