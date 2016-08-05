@isTest
private class WeeklyTimesheetCreatorJob_Test {

    static testmethod void scheduleJob_everySundayMidnight() {
        User manager = TestUtils.createManagers(5)[0];

        Test.startTest();
        System.runAs(manager) {
            String jobId = WeeklyTimesheetCreatorJob.scheduleMe();
        }
        Test.stopTest();

        List<User> managers = [SELECT Id FROM User WHERE Id IN 
                               (SELECT AssigneeId FROM PermissionSetAssignment WHERE
                               PermissionSet.Name ='Time_Tracking_Managers')];        
        List<Weekly_Timesheet__c> timesheets = [SELECT Id FROM Weekly_Timesheet__c];
        system.assertEquals(managers.size(), timesheets.size());
    }
    
    static testmethod void setWeeklyId() {
        User manager = TestUtils.createManagers(1)[0];

        Test.startTest();
        System.runAs(manager) {
            String jobId = WeeklyTimesheetCreatorJob.scheduleMe();
        }
        Test.stopTest();
    
        Weekly_Timesheet__c timesheet = [SELECT Id, Weekly_Id__c FROM Weekly_Timesheet__c WHERE OwnerId=:manager.Id];
        String properId = Integer.valueOf(Datetime.newInstance(Date.today().toStartOfWeek().addDays(7), 
                                                               Time.newInstance(12, 0,0,0)).format('w')) +' '+manager.Id;
        system.assertEquals(properId, timesheet.Weekly_Id__c);
    }    
}