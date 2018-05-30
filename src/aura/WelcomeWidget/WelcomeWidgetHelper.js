({
	getAccountInformation: function(component) {
		var action = component.get("c.getAccountInformation");
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set("v.account", response.getReturnValue());
                
                 console.log("The Account: ", response.getReturnValue());
			}
            
            
        });
        
        $A.enqueueAction(action);
       
	}})