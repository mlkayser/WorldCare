({
	getCases: function(component) {
		var action = component.get("c.getCases");
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set("v.cases", response.getReturnValue());
            }           
        });        
        $A.enqueueAction(action);       
	},
    
    getCurrentURL: function(component) {
		var action = component.get("c.getCurrentURL");
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set("v.CurrentURL", response.getReturnValue());
            }
            
        });        
        $A.enqueueAction(action);       
	}
    
});