({
	doInit : function(component, event, helper) {
        helper.getUserInfo(component);	
	},
    
    handleClick : function(component, event, helper) {
        helper.dropdownAction(component,event);
    }    
        
})