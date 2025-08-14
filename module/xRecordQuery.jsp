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