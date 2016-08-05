public class TimeEntryTriggerHandler {
    
    public static void checkIsUserAllowedToAddEntry(List<Time_Entry__c> entries) {
        Set<Id> projectIds = new Set<Id>();
        for(Time_Entry__c entry: entries) {
            projectIds.add(entry.Related_Project__c);  
        }
      
        Map<Id,Project__c> projects = new Map<Id,Project__c>([SELECT Id, (SELECT Id, Member__c FROM Project_Members__r) 
                                    FROM Project__c WHERE Id IN:projectIds]);
        for(Time_Entry__c entry: entries) {
            Project__c project = projects.get(entry.Related_Project__c);
            Boolean error = true;
	        for(Project_Member__c member: project.Project_Members__r) {

                if(member.Member__c == entry.Owner_Id__c) error=false;
            }
            if(error) entry.addError(Label.Not_Project_Member);
        }        
    }

    public static void addEntryToTimesheet(List<Time_Entry__c> entries) {
        Set<String> timesheetIds = new Set<String>();

        for(Time_Entry__c entry: entries) {      
            String properTimesheet = Datetime.newInstance(entry.Date__c.toStartOfWeek(), 
                                     Time.newInstance(12, 0,0,0)).format('w') +' '+(Id)entry.Related_Manager__c;
            timesheetIds.add(properTimesheet);            
        }
        List<Weekly_Timesheet__c> timesheets = [SELECT Id, Weekly_Id__c, Locked__c FROM Weekly_Timesheet__c 
                                                WHERE Weekly_Id__c IN :timesheetIds];
        Map<String,Weekly_Timesheet__c> timesheetsById = new Map<String,Weekly_Timesheet__c>();
        for(Weekly_Timesheet__c timesheet: timesheets) {
            timesheetsById.put(timesheet.Weekly_Id__c,timesheet);
        }
        for(Time_Entry__c entry: entries) {
            String properTimesheet = Datetime.newInstance(entry.Date__c.toStartOfWeek(), 
                                     Time.newInstance(12, 0,0,0)).format('w') +' '+(Id)entry.Related_Manager__c;
            try {
                Weekly_Timesheet__c timesheet = timesheetsById.get(properTimesheet);
                if(timesheet.Locked__c==false) entry.Weekly_Timesheet__c = timesheet.Id;
                else entry.addError(Label.Timesheet_is_locked);
            } catch(Exception ex) {
				entry.addError(Label.Timesheet_not_found);            
            }
        }
    }
    
    public static void prohibitActionIfTimesheetIsLocked(List<Time_Entry__c> entries) {
        for(Time_Entry__c entry: entries) {
        	if(entry.is_Locked__c) entry.addError(Label.Timesheet_is_locked);
        }
    }
    
    public static void incrementTotalsOnTimesheet(List<Time_Entry__c> entries) {
        Set<Id> timesheetIds = new Set<Id>();
        for(Time_Entry__c entry: entries) {
            timesheetIds.add(entry.Weekly_Timesheet__c);        
        }  
        Map<Id,Weekly_Timesheet__c> timesheets = new Map<Id,Weekly_Timesheet__c> ([SELECT Id, 	Total_Time__c FROM Weekly_Timesheet__c 
                                                WHERE Id IN :timesheetIds]);
        for(Time_Entry__c entry: entries) {
            Weekly_Timesheet__c timesheet = timesheets.get(entry.Weekly_Timesheet__c);    
            if(timesheet.Total_Time__c==null) timesheet.Total_Time__c=0;
            timesheet.Total_Time__c += entry.Logged_Time__c;            
        }  
        update timesheets.values();
    }

    public static void decrementTotalsOnTimesheet(List<Time_Entry__c> entries) {
        Set<Id> timesheetIds = new Set<Id>();
        for(Time_Entry__c entry: entries) {
            timesheetIds.add(entry.Weekly_Timesheet__c);        
        }  
        Map<Id,Weekly_Timesheet__c> timesheets = new Map<Id,Weekly_Timesheet__c> ([SELECT Id, 	Total_Time__c FROM Weekly_Timesheet__c 
                                                WHERE Id IN :timesheetIds]);
        for(Time_Entry__c entry: entries) {
            Weekly_Timesheet__c timesheet = timesheets.get(entry.Weekly_Timesheet__c);    
            timesheet.Total_Time__c -= entry.Logged_Time__c;            
        }  
        update timesheets.values();        
    }
    
}