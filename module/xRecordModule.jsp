
<%!public JSONObject getGeneralSettings(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "settings", "select * from tblgeneralsettings");
    return mainObj;
  }
 %>

<%!public JSONObject getActiveArena(JSONObject mainObj) {
    //mainObj = DBtoJson(mainObj, "arena", "select *, ifnull((select eventid from tblevent where arenaid=a.arenaid and event_active=1),'') as eventid from tblarena as a where active=1");
    mainObj = DBtoJson(mainObj, "arena", "select *, ifnull((select fightnumber from tblevent where arenaid=a.arenaid and event_active=1),'') as fightnumber, ifnull((select eventid from tblevent where arenaid=a.arenaid and event_active=1),'') as eventid from tblarena as a where active=1");
    return mainObj;
  }
 %>


<%!public JSONObject getAdminProfile(JSONObject mainObj,  String userid) {
    mainObj = DBtoJson(mainObj, "profile", "select *, date_format(current_timestamp, '%M %d, %Y %r') as datelogin from tbladminaccounts as a where id='"+userid+"'");
    return mainObj;
}
%>

<%!public JSONObject getOperators(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "operators", "select *, if(blocked,'Blocked',case when actived=1 then 'Active' else 'In-Active' end) as status from tbloperator as a order by companyname asc");           
    return mainObj;
 }
 %>

 <%!public JSONObject getSelectOperator(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "select_operator", "select companyid, companyname from tbloperator order by companyname asc");       
    return mainObj;
 }
 %>

 <%!public JSONObject getDummaryAccount(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "dummy_account", "select * from tbldummyaccount");
    return mainObj;
  }
 %>

 <%!public JSONObject getDummySettings(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "dummy_names", "select * from tbldummyname ORDER BY RAND()");
    mainObj = DBtoJson(mainObj, "dummy_settings", "select *,(select dummy_account_1 from tblgeneralsettings) as dummy_account_1, (select dummy_account_2 from tblgeneralsettings) as dummy_account_2 from tbldummysettings");
    return mainObj;
  }
 %>

<%!public JSONObject getArenaList(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "arena", "select * from tblarena");       
    return mainObj;
 }
 %>

<%!public JSONObject getDashboardUpdate(JSONObject mainObj, String dversion) {
    mainObj = DBtoJson(mainObj, "select *,dashboardupdateurl as downloadurl, date_format(str_to_date(dashboardversion, '%Y.%m.%d'), '%Y-%m-%d') as 'version' " 
                    + " from tblversioncontrol where date_format(str_to_date(dashboardversion, '%Y.%m.%d'), '%Y-%m-%d') > '" + dversion + "'");
    return mainObj;
  }
 %>

<%!public JSONObject getControllerUpdate(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "select controllerupdateurl from tblversioncontrol");
    return mainObj;
 }
 %>
 
<%!public JSONObject getEventInfo(JSONObject mainObj, String eventid) {
    mainObj = DBtoJson(mainObj, "event", "select *, (select plasada_rate from tblgeneralsettings) as plasada, concat(eventid, '-', event_key) as eventkey from tblevent where eventid='"+eventid+"'");
    mainObj = DBtoJson(mainObj, "result", "select id, eventid, fightnumber, result, if(result='C','X',fightnumber) as resultdisplay, case when result='W' then 'wala' when result='M' then 'meron' when result='D' then 'draw' when result='C' then 'cancelled' end as 'resultkey' from tblfightresult where eventid='"+eventid+"'");
    return mainObj;
  }
 %>

<%!public JSONObject getVideoSource(JSONObject mainObj) {
      mainObj = DBtoJson(mainObj, "video",  "select * from tblvideosource where source_working=1 and deleted=0");
      return mainObj;
 }
 %>

<%!public JSONObject getMessageTemplate(JSONObject mainObj) {
      mainObj = DBtoJson(mainObj, "template",  "select * from tbltemplate");
      return mainObj;
 }
 %>

 <%!public JSONObject getAnnouncement(JSONObject mainObj) {
      mainObj = DBtoJson(mainObj, "announcement",  "SELECT * FROM `tblpromo` where category='ANNOUNCEMENT';");
      return mainObj;
 }
 %>

<%!public JSONObject getEventVideo(JSONObject mainObj, String eventid) {
    mainObj = DBtoJson(mainObj, "video", "SELECT a.event_standby as standby, a.live_mode as mode, b.source_url as stream_url, b.player_type as stream_player, b.web_available, b.web_url, b.web_player,if(fightnumber=0,false,true) as live_open FROM tblevent a right join tblvideosource b on a.live_sourceid=b.id where eventid='"+eventid+"'");
    return mainObj;
  }
%>

<%!public JSONObject getEventNotice(JSONObject mainObj, String eventid) {
    mainObj = DBtoJson(mainObj, "notice", "select event_title,event_reminders_warning,event_reminders_message from tblevent where eventid='"+eventid+"'");
    return mainObj;
  }
%>

 <%!public JSONObject getFightNumber(JSONObject mainObj, String eventid) {
    mainObj = DBtoJson(mainObj, "fightnumber", "select fightnumber from tblevent where eventid='"+eventid+"'");
    return mainObj;
  }
 %>
 
<%!public JSONObject getPlayerBets(JSONObject mainObj, String fightkey) {
    mainObj = DBtoJson(mainObj, "player_bets", "SELECT (select arenaname from tblarena where arenaid=a.arenaid) as arena, accountid, accountname, bet_choice, bet_amount FROM tblfightbets as a where fightkey='"+fightkey+"';");
    return mainObj;
}
%>

<%!public JSONObject getBetSummary(JSONObject mainObj, String fightkey) {
    mainObj = DBtoJson(mainObj, "bet_summary",  "SELECT "
                            + " count(if(bet_choice='M',1,null)) as countMeron, "
                            + " count(if(bet_choice='D',1,null)) as countDraw, "
                            + " count(if(bet_choice='W',1,null)) as countWala, "
                            + " sum(if(bet_choice='M',bet_amount,0)) as totalMeron, "
                            + " sum(if(bet_choice='D',bet_amount,0)) as totalDraw, "
                            + " sum(if(bet_choice='W',bet_amount,0)) as totalWala "
                            + " FROM tblfightbets where fightkey='"+fightkey+"'");
    return mainObj;
 }
 %>

