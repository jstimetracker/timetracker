({
	myAction : function(component, event, helper) {
        var action = component.get("c.getProjects");
        action.setCallback(this, function(data) {
            console.log(data.getReturnValue());
        	component.set("v.projects", data.getReturnValue());
        });
        $A.enqueueAction(action);		
	}   
})