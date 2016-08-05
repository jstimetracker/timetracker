global class WeeklyTimesheetCreatorJob implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        Date newWeek = Date.today().toStartOfWeek().addDays(7);
        List<User> managers = [SELECT Id FROM User WHERE Id IN 
                               (SELECT AssigneeId FROM PermissionSetAssignment WHERE
                               PermissionSet.Name ='Time_Tracking_Managers')];

        List<Weekly_Timesheet__c> timesheets = new List<Weekly_Timesheet__c>();
        for(User manager: managers) {
        	Weekly_Timesheet__c timesheet = new Weekly_Timesheet__c();
            timesheet.OwnerId=manager.Id;
            timesheet.Start_Date__c = newWeek;
            timesheet.End_Date__c = newWeek.addDays(6);            
            timesheet.Period_Number__c= Integer.valueOf(Datetime.newInstance(newWeek, Time.newInstance(12, 0,0,0)).format('w'));
            timesheet.Weekly_Id__c = timesheet.Period_Number__c+' '+timesheet.OwnerId;
            timesheets.add(timesheet);
        }
        insert timesheets;
    }
    
    global static Id scheduleMe() {
	  String jobName = 'WeeklyTimesheetCreatorJob';
      if(Test.isRunningTest()) jobName+='Test';
      String jobId = System.schedule(jobName,
      '0 0 0 ? * 1', 
         new WeeklyTimesheetCreatorJob()); 
        return jobId;
    }
}