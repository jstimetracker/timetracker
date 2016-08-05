({
	myAction : function(component, event, helper) {
        var isActive = false;
        if(component.get("v.task.jstimetracker__is_Timer_On__c") > 0) isActive=true;
		component.set("v.isTimerOn", isActive);
	},
    handleStartTimer : function(component, event, helper) {
        var action = component.get("c.startTimer"); 
		action.setParams({
			"taskId" : component.get("v.task.Id")
		});         
        action.setCallback(this,function(a){
            component.set("v.isTimerOn", true);
            console.log(a.getReturnValue());
        });   
        $A.enqueueAction(action);	
    },
    handleStopTimer : function(component, event, helper) {
        console.log('stop task'+component.get("v.task.Id"));
        var action = component.get("c.stopTimer");    
		action.setParams({
			"taskId" : component.get("v.task.Id")
		});  
        action.setCallback(this,function(a){
            component.set("v.isTimerOn", false);
            console.log(a.getReturnValue());
        });   
        $A.enqueueAction(action);	
    }    
})