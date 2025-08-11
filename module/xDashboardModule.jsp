 
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
 
<%!public JSONObject dash_bank_list(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "bank_list", "select * from tblbanks where isbank=1 order by bankname asc");
    return mainObj;
 }
 %>

<%!public JSONObject dash_operator_bank(JSONObject mainObj) {
      mainObj = DBtoJson(mainObj, "operator_bank", "select *, (select logourl from tblbanks where id=a.bankid) as logourl, "
                                + " (select bankname from tblbanks where id=a.bankid) as bankname, if(actived, 'Active','Disabled') as status "
                                + " from tblbankoperator as a where deleted=0");
      return mainObj;
 }
 %>