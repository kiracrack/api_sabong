<%!public boolean isAdminSessionExpired(String userid, String sessionid) {
    return CountQry("tbladminaccounts", "id='" + userid + "' and sessionid='"+sessionid+"'") == 0;
  }
 %>

<%!public boolean isAdminAccountBlocked(String userid) {
    return CountQry("tbladminaccounts", "(id='" + userid + "' or username='" + rchar(userid) + "') and blocked=1") > 0;
  }
 %>

<%!public boolean isControllerRemoved(String deviceid) {
    return CountQry("tblcontroller", "deviceid='"+deviceid+"'") == 0;
 }
 %>

<%!public boolean isControllerBlocked(String deviceid) {
    return CountQry("tblcontroller", "deviceid='"+deviceid+"' and blocked=1") > 0;
 }
 %>

<%!public boolean isOperatorExist(String appkey) {
    return CountQry("tbloperator", "appkey='"+appkey+"'") > 0;
 }
%>

<%!public boolean isOperatorActived(String appkey) {
    return CountQry("tbloperator", "appkey='"+appkey+"' and actived=1") > 0;
 }
%>

<%!public boolean isEventActived(String eventid) {
    return CountQry("tblevent", "eventid='"+eventid+"' and event_active=1") > 0;
 }
%>

<%!public boolean isOperatorBlocked(String appkey) {
    return CountQry("tbloperator", "appkey='"+appkey+"' and blocked=1") > 0;
 }
%>