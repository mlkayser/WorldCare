({
    getUserInfo: function(component) {
        var action = component.get("c.getUserInfo"); 
        action.setCallback(this, function(a) {
            component.set("v.runningUser", a.getReturnValue()); // variable in the component
        });
        $A.enqueueAction(action);
    },
    
    dropdownAction: function(component, event) {
        var triggerCmp = component.find("trigger");
        if (triggerCmp) {
            var source = event.getSource();
            var label = source.get("v.label");
        }
        
        var user = component.get("v.runningUser");
        var profileLabel = component.get("v.profileLabel");
          
        if (label == profileLabel) {
            var action = component.get("c.getAccountInfo");
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var account = response.getReturnValue();
                }                
                if (account) {
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({"url": "/account/" + account.Id});
                    urlEvent.fire();    
                } 	
            });        
        	$A.enqueueAction(action);
        }                             
        else {            
            var logoutUrl = user.Logout_URL__c;
            if (!logoutUrl) {
                var orgUrl = window.location.hostname;
                var commPrefix = window.location.pathname;
                commPrefix.indexOf(1);
                commPrefix.toLowerCase();
                commPrefix = commPrefix.split("/")[1];
                //var logoutUrl = "https://" + orgUrl + "/" + commPrefix + "/secur/logout.jsp";
                var logoutUrl = "/secur/logout.jsp";
            } 	
            console.log('LOGOUT URL = ' + logoutUrl);
            window.location.href = logoutUrl;            
        } 
    }    
      
})