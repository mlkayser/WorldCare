// Mass update records with this batch class
global class InvokeUpdateBatch implements Database.Batchable<sObject> {
  private String sObjectName;
 
    global InvokeUpdateBatch(String sObjectName) {
        this.sObjectName = sObjectName;
    }
 
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id FROM ' + sObjectName;
        return Database.getQueryLocator(query); 
    }
 
    global void execute(Database.BatchableContext BC, List<sObject> scope){ 
        database.update(scope, false);
    }
 
    global void finish(Database.BatchableContext BC){
    }
 
}