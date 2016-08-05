public class TimeTrackerComponentController {

    @AuraEnabled
    public static List<Project__c> getProjects() {
        return [SELECT id, name,createddate, (SELECT id, name, is_Timer_On__c FROM Tasks__r ORDER BY name) 
                FROM Project__c WHERE Id IN 
                (SELECT Project__c FROM Project_Member__c WHERE Member__c = :UserInfo.getUserId()) 
                LIMIT 50];
    }
    
    @AuraEnabled
    public static void startTimer(String taskId) {
        String selectedId = taskId.substring(0, 15);
        Time_Entry__c entry = new Time_Entry__c(Date__c=Date.today(),Logged_Time__c=0, Task__c=(Id)selectedId,
                                               is_Timer_active__c=true,Timer_Started__c=DateTime.now());
        insert entry;

    }    

    @AuraEnabled
    public static void stopTimer(String taskId) {      
        List<Time_Entry__c> entries = [SELECT Id,Logged_Time__c,is_Timer_active__c,Timer_Started__c
                                       FROM Time_Entry__c WHERE is_Timer_active__c=true AND Task__c=:taskId
                                      AND Date__c=:Date.today()];
        for(Time_Entry__c entry: entries) {
            Decimal loggedMinutes = (DateTime.now().getTime() - entry.Timer_Started__c.getTime())/60000;
            entry.Logged_Time__c += loggedMinutes;
            entry.is_Timer_active__c=false;
            entry.Timer_Started__c=null;
        }
        update entries;
    }    
  
}