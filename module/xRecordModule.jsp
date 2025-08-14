
<%!public JSONObject general_settings(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "settings", "select * from tblgeneralsettings");
    return mainObj;
  }
 %>

<%!public JSONObject active_arena(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "arena", "select *, ifnull((select eventid from tblevent where arenaid=a.arenaid and event_active=1),'') as eventid from tblarena as a where active=1");
    return mainObj;
  }
 %>


<%!public JSONObject load_admin_profile(JSONObject mainObj,  String userid) {
    mainObj = DBtoJson(mainObj, "profile", "select *, date_format(current_timestamp, '%M %d, %Y %r') as datelogin from tbladminaccounts as a where id='"+userid+"'");
    return mainObj;
}
%>

<%!public JSONObject load_operators(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "operators", "select *, if(blocked,'Blocked',case when actived=1 then 'Active' else 'In-Active' end) as status from tbloperator as a order by companyname asc");           
    return mainObj;
 }
 %>

 <%!public JSONObject select_operators(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "select_operator", "select companyid, companyname from tbloperator order by companyname asc");       
    return mainObj;
 }
 %>

 <%!public JSONObject dummy_accounts(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "dummy_account", "select * from tbldummyaccount");
    return mainObj;
  }
 %>

 <%!public JSONObject dummy_settings(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "dummy_names", "select * from tbldummyname ORDER BY RAND()");
    mainObj = DBtoJson(mainObj, "dummy_settings", "select * from tbldummysettings");
    return mainObj;
  }
 %>

<%!public JSONObject dash_load_arena(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "arena", "select * from tblarena");       
    return mainObj;
 }
 %>

<%!public JSONObject dash_app_update(JSONObject mainObj, String dversion) {
    mainObj = DBtoJson(mainObj, "select *,dashboardupdateurl as downloadurl, date_format(str_to_date(dashboardversion, '%Y.%m.%d'), '%Y-%m-%d') as 'version' " 
                    + " from tblversioncontrol where date_format(str_to_date(dashboardversion, '%Y.%m.%d'), '%Y-%m-%d') > '" + dversion + "'");
    return mainObj;
  }
 %>

<%!public JSONObject controller_update(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "select controllerupdateurl from tblversioncontrol");
    return mainObj;
 }
 %>
 