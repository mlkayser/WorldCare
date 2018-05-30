global class UpdateElapsedHoursSchedule implements Schedulable{
    
    global UpdateElapsedHoursBatch BatchUEB;
    
    global UpdateElapsedHoursSchedule(){
        BatchUEB = new UpdateElapsedHoursBatch();
    }
    
    private boolean RunMeFlag = false;//used for testing from UI
    
    global void execute(SchedulableContext SC) {
        ID BObatchprocessid = Database.executeBatch(BatchUEB, 5);
        
        //UpdateElapsedHoursSchedule.ProcessMe();
        
        if(RunMeFlag){//used for testing from UI
            System.abortJob(SC.getTriggerId());
        }
    }
    
    /*public static void ProcessMe(){
        //In case that there could be more than 10,000 Case records (If a request is outstanding), use Batch class. But now we have to use batch class in order to decrease number of prosecced records. Flows cause exceeding of CPU time.
        
        UpdateElapsedHoursBatch BatchUEB = new UpdateElapsedHoursBatch();
        ID BObatchprocessid = Database.executeBatch(BatchUEB, 5);
        
        
        //In case that there are not more than 10,000 Case records (If a request is outstanding), use static method
        //list<case> lstCase = [Select id, Days_at_Hospital__c, Request_Submitted__c, Report_Received__c, Request_Submitted_Not_Received_Hours__c, Today_is_Holiday__c, BusinessHoursId from case where Request_Submitted__c != null AND Report_Received__c = null];
        //UpdateElapsedHoursSchedule.ProcessUpdateElapsedHours(lstCase);
        
    }*/
    
    public static void ProcessUpdateElapsedHours(list<case> lstCase, boolean runMethod){
        
        BusinessHours defaultHours = [select Id from BusinessHours where IsDefault=true];
        //--------------------------------------------------------------------------------
        for(case objCase : lstCase){
            
            //----------------in case that we USE business hours functionality--------
            //On the off-chance that the business hours on the case are null, use the default ones instead
            Id hoursToUse = objCase.BusinessHoursId!=null?objCase.BusinessHoursId:defaultHours.Id;

            //The diff method comes back in milliseconds, so we divide by 3600000 to get hours.
            datetime TodayAt1201am = datetime.newInstance(date.today(), time.newInstance(0, 1, 0, 0));
            Double submittedToTodayAt1201am = BusinessHours.diff(hoursToUse, objCase.Request_Submitted__c, TodayAt1201am)/3600000.0;
            objCase.Request_Submitted_Not_Received_Hours__c = submittedToTodayAt1201am;
            //To determine whether today is holiday, we use Noon Time
            Datetime NoonTime = datetime.newInstance(date.today(), time.newInstance(12, 0, 0, 0));
            //Boolean whether today is holiday
            objCase.Today_is_Holiday__c = !BusinessHours.isWithin(hoursToUse, NoonTime);
            //--------------------------------------------------------------------------------
        }
        // If the method of starting from the trigger will not update case 
        if(runMethod){
        	update lstCase;
        }	
    }
     
    public static string GetCron(){
        Datetime RightNow = datetime.now();
        RightNow = RightNow.addSeconds(30);
        String strSec = string.valueof(RightNow.second());
        String strMin = string.valueof(RightNow.minute());
        String strHour = string.valueof(RightNow.hour());

        String strDay = string.valueof(date.today().day());
        String strMonth = string.valueof(date.today().month());
        String strYear = string.valueof(date.today().year());

        String sch = strSec+' '+strMin+' '+strHour+' * * ? *';
        return sch;
    }
    
    //used for testing from UI
    public static void runMe(){
        UpdateElapsedHoursSchedule MyUpdateElapsedHoursSchedule = new UpdateElapsedHoursSchedule();
        MyUpdateElapsedHoursSchedule.RunMeFlag = true;
        Datetime RightNow = datetime.now();
        string UniqueStr = string.valueof(date.today().year())+'-'+string.valueof(date.today().month())+'-'+string.valueof(date.today().day())+'_'+string.valueof(RightNow.hour())+':'+string.valueof(RightNow.minute())+':'+string.valueof(RightNow.second());
        system.schedule('UpdateElapsedHoursSchedule_'+UniqueStr, GetCron(), MyUpdateElapsedHoursSchedule);
    }  
}