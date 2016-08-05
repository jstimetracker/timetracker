@isTest
public class TestUtils {
    public static Weekly_Timesheet__c createTimesheet() {
        Date newWeek = Date.today().toStartOfWeek();        
        Weekly_Timesheet__c timesheet = new Weekly_Timesheet__c();
        timesheet.OwnerId=UserInfo.getUserId();
        timesheet.Start_Date__c = newWeek;
        timesheet.End_Date__c = newWeek.addDays(6);            
        timesheet.Period_Number__c= Integer.valueOf(Datetime.newInstance(newWeek, Time.newInstance(12, 0,0,0)).format('w'));
        timesheet.Weekly_Id__c = timesheet.Period_Number__c+' '+(Id)timesheet.OwnerId;
        insert timesheet;
        return timesheet;
    }
    
    public static Time_Entry__c createTimeEntry() {
        Task__c task = createTask();
	    Time_Entry__c entry = new Time_Entry__c(Date__c=Date.today(),Logged_Time__c=10, Task__c=task.Id);
        insert entry;
        return entry;        
    }
    
    public static Time_Entry__c createTimeEntryWithoutMember() {
        Project__c project = new Project__c(Name='TestProj');
        insert project;
        Task__c task = new Task__c(Name = 'Test', Project__c=project.Id);
        insert task;
	    Time_Entry__c entry = new Time_Entry__c(Date__c=Date.today(),Logged_Time__c=10, Task__c=task.Id);
        insert entry;
        return entry;        
    }
    
    public static Task__c createTask() {
        Project__c project = new Project__c(Name='TestProj');
        insert project;
        Task__c task = new Task__c(Name = 'Test', Project__c=project.Id);
        insert task;
        Project_Member__c member = new Project_Member__c(Project__c=project.Id, Member__c=UserInfo.getUserId());
        insert member;
        return task;
    }
    
    public static List<User> createManagers(Integer count) {
        PermissionSet ps = [
                select Id
                from PermissionSet
                where Name = 'Time_Tracking_Managers'
        ];

        Profile profile = [
                select Id
                from Profile
                where Name = 'Standard User'
        ];
        List<User> testUsers = new List<User>();
        for (Integer i = 0; i < count; i++) {
            User testUser = new User(
                    alias = 'tuser' + i,
                    email = 'testuser@myexample.com' + i,
                    emailencodingkey = 'UTF-8',
                    lastname = 'Testing' + i,
                    languagelocalekey = 'en_US',
                    localesidkey = 'en_US',
                    profileid = profile.Id,
                    timezonesidkey = 'America/New_York',
                    username = 'testuser@myexample.com' + i
            );
            testUsers.add(testUser);
        }
        insert testUsers;
        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
        for (User manager: testUsers) {
            PermissionSetAssignment assignment = new PermissionSetAssignment(
                    AssigneeId = manager.Id,
                    PermissionSetId = ps.Id
            );
            assignments.add(assignment);
        }
        insert assignments;
        return testUsers;
    }

}