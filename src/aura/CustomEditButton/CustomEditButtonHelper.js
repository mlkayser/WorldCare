({  
    getAccount : function(component) {
        var action = component.get("c.getAccount");
        action.setParams({
            parentId : component.get("v.recordId")
        });
        
        
        $A.enqueueAction(action);
    }
})