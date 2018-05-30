// Local Time App trigger on the User object
// to calculate UTC Offset
// 11/07/2017 - Initial implementation - Success Software, info@success-software.biz
//
trigger LocalTimeUserTrigger on User (before insert, before update) {
    // Populate the timezone fields
    for(User u : Trigger.new) {
        // sample JSON response:{"offset":"-5.00","dst_offset":"-4.00","abbreviation":"EST","dst_abbreviation":"EDT","region":"NA","tz_iana":"America/New_York"};
        try {
            String jsonStr = tz.LocalTime.getOffsetFull(u.Country, u.State, u.City);
            if(jsonStr != null) {            
                Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(jsonStr);
                String offset = (String) m.get('offset');
                if(offset != 'N/A') {
                    u.LT_UTC_Offset__c = Decimal.valueof(offset);
                    String dst_offset = (String) m.get('dst_offset');
                    if(dst_offset != 'N/A') u.LT_UTC_DST_Offset__c = Decimal.valueof(dst_offset);
    
                    u.LT_Region__c = (String) m.get('region');                
                }
            }
        }
        catch(System.JSONException e) {}
    }
}