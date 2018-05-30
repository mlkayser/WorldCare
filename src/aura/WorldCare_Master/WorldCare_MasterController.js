({
    doInit: function(component, event, helper) {
        // copyright date
        var today = new Date();
        component.set('v.copyrightDate', today.getFullYear());        
    	
        // user info
        var action = component.get("c.getUserInfo"); 
        action.setCallback(this, function(a) {
            component.set("v.runningUser", a.getReturnValue()); // variable in the component
        });
        $A.enqueueAction(action);
    }
})