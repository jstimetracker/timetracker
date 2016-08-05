@isTest
private class TimeTrackerComponentController_Test {

    static testmethod void getProjects_WhenUserIsNotTeamMember_EmptyList() {
        Weekly_Timesheet__c timesheet = TestUtils.createTimesheet();
                
        List<Project__c> projects = TimeTrackerComponentController.getProjects();
        System.assertEquals(0, projects.size()); 
    }  
    
    static testmethod void getProjects_WhenUserIsTeamMember_ReturnProjectsWithTasks() {
        Weekly_Timesheet__c timesheet = TestUtils.createTimesheet();
        TestUtils.createTimeEntry();
                
        List<Project__c> projects = TimeTrackerComponentController.getProjects();
        System.assertEquals(1, projects.size());
        System.assertEquals(1, projects[0].Tasks__r.size()); 
    }  
    
    static testmethod void startTimer_createTimeEntry() {
        Weekly_Timesheet__c timesheet = TestUtils.createTimesheet();
        Task__c task = TestUtils.createTask();
                
        TimeTrackerComponentController.startTimer(''+task.Id);
        
        List<Time_Entry__c> entries = [SELECT Id,is_Timer_active__c FROM Time_Entry__c];
        System.assertEquals(1, entries.size());
        System.assertEquals(true, entries[0].is_Timer_active__c); 
    }       
    
    static testmethod void stopTimer_createTimeEntry() {
        Weekly_Timesheet__c timesheet = TestUtils.createTimesheet();
        Time_Entry__c entry = TestUtils.createTimeEntry();
        entry.is_Timer_active__c=true;
        entry.Timer_Started__c=DateTime.Now().addMinutes(-15);
        update entry;        

        TimeTrackerComponentController.stopTimer(entry.Task__c);
        
        List<Time_Entry__c> entries = [SELECT Id,is_Timer_active__c,Logged_Time__c FROM Time_Entry__c];
        System.assertEquals(1, entries.size());
        System.assertEquals(false, entries[0].is_Timer_active__c); 
        System.assertEquals(25, entries[0].Logged_Time__c); // 10 set at begining + logged 15
    }     
}