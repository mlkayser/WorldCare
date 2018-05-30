({
    doInit: function(component, event, helper) {
        // copyright date
        var today = new Date();
        component.set('v.copyrightDate', today.getFullYear());            	
    }
})