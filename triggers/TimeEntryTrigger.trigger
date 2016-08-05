trigger TimeEntryTrigger on Time_Entry__c (before insert, before update, after update, before delete) {

    if(Trigger.isInsert) {
        TimeEntryTriggerHandler.checkIsUserAllowedToAddEntry(Trigger.New);
        TimeEntryTriggerHandler.addEntryToTimesheet(Trigger.New);
        TimeEntryTriggerHandler.incrementTotalsOnTimesheet(Trigger.New);
    }
    
    if(Trigger.isUpdate && Trigger.isBefore) {
    	TimeEntryTriggerHandler.prohibitActionIfTimesheetIsLocked(Trigger.New);    
    }
    
    if(Trigger.isUpdate && Trigger.isAfter) {
        TimeEntryTriggerHandler.incrementTotalsOnTimesheet(Trigger.New);        
        TimeEntryTriggerHandler.decrementTotalsOnTimesheet(Trigger.Old);        
    }
    
    if(Trigger.isDelete) {
    	TimeEntryTriggerHandler.prohibitActionIfTimesheetIsLocked(Trigger.Old);    
        TimeEntryTriggerHandler.decrementTotalsOnTimesheet(Trigger.Old);        
    }

}