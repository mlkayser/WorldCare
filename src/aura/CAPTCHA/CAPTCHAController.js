({
    doInit : function(component) {
        var vfOrigin = "https://c.cs12.visual.force.com";
        window.addEventListener("message", function(event) {
            if (event.origin !== vfOrigin) {
                // Not the expected origin: Reject the message!
                return;
            }
            
            if(event.data.action == 'alohaCallingCAPTCHA' && event.data.alohaResponseCAPTCHA == 'NOK'){
                alert('Please do the captcha before submit!');
            }
            else if(event.data.action == 'alohaCallingCAPTCHA' && event.data.alohaResponseCAPTCHA == 'OK'){
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                        "url": vfOrigin + '/members/s/login/'
                });
                urlEvent.fire();
            }
        }, false);
    },

	submitSomething : function(component, event, helper) {
        var message = 'alohaCallingCAPTCHA';
		var vfOrigin = "https://c.cs12.visual.force.com";
        var vfWindow = component.find("vfFrame").getElement().contentWindow;
		vfWindow.postMessage({ action: "alohaCallingCAPTCHA" }, vfOrigin);

	}
})