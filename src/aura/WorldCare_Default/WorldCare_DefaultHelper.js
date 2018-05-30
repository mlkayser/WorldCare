({
    getYear: function(component) {
        // copyright date
        var today = new Date();
        component.set('v.copyrightDate', today.getFullYear());  
    },
    
    getUserInfo: function(component) {    	
        // user info
        var action = component.get("c.getUserInfo"); 
        action.setCallback(this, function(a) {
            component.set("v.runningUser", a.getReturnValue()); 
        });
        $A.enqueueAction(action);
    },

    getResourceURL: function(component) {
        var url = $A.get('$Resource.worldcarelogo');
        var tempUrl = url.substr(0, url.lastIndexOf("/"));
        var resourceUrl = tempUrl.substr(0, tempUrl.lastIndexOf("/")); // remove resource folder id
        
        var orgUrl = window.location.hostname;
        console.log("Org URL: " + orgUrl); 
        console.log("Resource URL: " + resourceUrl); 
        console.log("Logo url = " + 'https://' + orgUrl + resourceUrl)
        component.set("v.resourceURL", resourceUrl);
    }     
      
})