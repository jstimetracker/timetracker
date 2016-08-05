@isTest
private class TimeEntryTriggerHandler_Test {

    static testmethod void addEntryToTimesheet_whenTimesheetExist_setLookup() {
        Weekly_Timesheet__c timesheet = TestUtils.createTimesheet();
        TestUtils.createTimeEntry();
                
        Time_Entry__c updatedEntry = [SELECT Weekly_Timesheet__c FROM Time_Entry__c];
        System.assertEquals(timesheet.Id, updatedEntry.Weekly_Timesheet__c);
    }

    static testmethod void addEntryToTimesheet_whenTimesheetNotExist_throwException() {
        try {
            TestUtils.createTimeEntry();
            system.assert(false,'Exception should be thrown');            
        } catch(Exception ex){
        }
    }

    static testmethod void ifTimesheetLocked_insertNotAllowed() {
        Weekly_Timesheet__c timesheet = TestUtils.createTimesheet();
        timesheet.Locked__c=true;
        update timesheet;

        try {
            TestUtils.createTimeEntry();
            system.assert(false,'Exception should be thrown');            
        } catch(Exception ex){
        }
    }    
    
    static testmethod void ifTimesheetLocked_updateNotAllowed() {
        Weekly_Timesheet__c timesheet = TestUtils.createTimesheet();
        Time_Entry__c entry = TestUtils.createTimeEntry();
        timesheet.Locked__c=true;
        update timesheet;
        entry.Logged_Time__c = entry.Logged_Time__c+1;

        try {
            update entry;            
            system.assert(false,'Exception should be thrown');            
        } catch(Exception ex){
            System.assert(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }
    }    

    static testmethod void ifTimesheetLocked_deleteNotAllowed() {
        Weekly_Timesheet__c timesheet = TestUtils.createTimesheet();
        Time_Entry__c entry = TestUtils.createTimeEntry();
        timesheet.Locked__c=true;
        update timesheet;

        try {
            delete entry;            
            system.assert(false,'Exception should be thrown');            
        } catch(Exception ex){
            System.assert(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }
    }    
    
    static testmethod void ifNotProjectMember_notAllowedToInsertTimeEntry() {
        Weekly_Timesheet__c timesheet = TestUtils.createTimesheet();

        try {
	        Time_Entry__c entry = TestUtils.createTimeEntryWithoutMember();
            system.assert(false,'Exception should be thrown');            
        } catch(Exception ex){
            System.assert(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }
    }     
    
    static testmethod void incrementTotalsOnTimesheet_whenEntryInserted() {
        Weekly_Timesheet__c timesheet = TestUtils.createTimesheet();
        TestUtils.createTimeEntry();
                
        Weekly_Timesheet__c updatedEntry = [SELECT Id, Total_Time__c FROM Weekly_Timesheet__c];
        System.assertEquals(10, updatedEntry.Total_Time__c);    
    }     
 
    static testmethod void incrementTotalsOnTimesheet_whenEntryUpdated() {
        Weekly_Timesheet__c timesheet = TestUtils.createTimesheet();
        Time_Entry__c entry = TestUtils.createTimeEntry();
        entry.Logged_Time__c=15;
        update entry;
                
        Weekly_Timesheet__c updatedEntry = [SELECT Id, Total_Time__c FROM Weekly_Timesheet__c];
        System.assertEquals(15, updatedEntry.Total_Time__c);    
    }     

    static testmethod void decrementTotalsOnTimesheet_whenEntryDeleted() {
        Weekly_Timesheet__c timesheet = TestUtils.createTimesheet();
        Time_Entry__c entry = TestUtils.createTimeEntry();
        delete entry;
                
        Weekly_Timesheet__c updatedEntry = [SELECT Id, Total_Time__c FROM Weekly_Timesheet__c];
        System.assertEquals(0, updatedEntry.Total_Time__c);    
    }     
}