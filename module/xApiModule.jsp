 <%!public JSONObject api_jackpot_bonus(JSONObject mainObj,  String userid) {
    mainObj = DBtoJson(mainObj, "jackpot", "select id, amount from tblbonuslogs as a where accountid='"+userid+"' and collected=0 order by datetrn asc limit 1");
    return mainObj;
  }
 %>

 <%!public JSONObject api_active_arena(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "arena", "select arenaid, main_banner_url, arenaname, ifnull((select fightnumber from tblevent where arenaid=a.arenaid and event_active=1),'') as fightnumber, "
              + " ifnull((select eventid from tblevent where arenaid=a.arenaid and event_active=1),'') as eventid, "
              + " ifnull((select date_format(event_date, '%W %M %d, %Y') from tblevent where arenaid=a.arenaid and event_active=1),'') as eventdate "
              + " from tblarena as a where active=1");
    return mainObj;
  }
 %>

<%!public JSONObject api_event_info(JSONObject mainObj, String eventid) {
    mainObj = DBtoJson(mainObj, "event", "select eventid, (select plasada_rate from tblgeneralsettings) as plasada, fight_result, total_win_meron, total_win_wala, total_draw, total_cancelled, (total_win_meron + total_win_wala + total_draw + total_cancelled) as total_fight, current_status,fightnumber from tblevent as a where eventid='"+eventid+"'");
    return mainObj;
  }
 %>

 <%!public JSONObject api_arena_info(JSONObject mainObj, String arenaid) {
    mainObj = DBtoJson(mainObj, "arena", "select arenaid, main_banner_url,vertical_banner_url, arenaname, opposite_bet from tblarena where arenaid='"+arenaid+"'");
    return mainObj;
  }
 %>

 <%!public JSONObject api_fight_number(JSONObject mainObj, String eventid) {
    mainObj = DBtoJson(mainObj, "fightnumber", "select fightnumber from tblevent where eventid='"+eventid+"'");
    return mainObj;
  }
 %>

<%!public JSONObject api_event_notice(JSONObject mainObj, String eventid) {
    mainObj = DBtoJson(mainObj, "notice", "select event_title,event_reminders_warning,event_reminders_message from tblevent where eventid='"+eventid+"'");
    return mainObj;
  }
%>

<%!public JSONObject api_event_video(JSONObject mainObj, String eventid) {
    mainObj = DBtoJson(mainObj, "video", "SELECT a.live_mode as mode, b.source_url as stream_url FROM tblevent a right join tblvideosource b on a.live_sourceid=b.id where eventid='"+eventid+"'");
    return mainObj;
  }
%>

<%!public JSONObject api_result_info(JSONObject mainObj, String eventid) {
    mainObj = DBtoJson(mainObj, "result", "select result as fr, fightnumber as fn from tblfightresult where eventid='"+eventid+"'");
    return mainObj;
  }
 %>

<%!public JSONObject api_current_fight_bet(JSONObject mainObj, String accountid, String fightkey) {
    mainObj = DBtoJson(mainObj, "current_fight_bet", "SELECT eventid,(select arenaname from tblarena where arenaid=a.arenaid) as arena,fightnumber,transactionno,bet_choice,bet_amount FROM tblfightbets as a where accountid='"+accountid+"' and fightkey='"+fightkey+"';");
    mainObj = DBtoJson(mainObj, "current_total_bet", "SELECT bet_choice, sum(bet_amount) as total_bet FROM tblfightbets as a where accountid='"+accountid+"' and fightkey='"+fightkey+"' group by bet_choice;");
    return mainObj;
  }
 %>

<%!public JSONObject api_credit_transaction(JSONObject mainObj, String accountid, String datefrom, String dateto) {
    mainObj = DBtoJson(mainObj, "credit_transaction", "SELECT  *, date_format(datetrn, '%m/%d/%y') as 'date', date_format(datetrn, '%r') as 'time' FROM tblcredittransaction as a where accountid='"+accountid+"' and date_format(datetrn, '%Y-%m-%d') between '" + datefrom + "' and '" + dateto + "';");
    return mainObj;
  }
 %>

<%!public JSONObject api_fight_summary(JSONObject mainObj, String fightkey) {
    mainObj = DBtoJson(mainObj, "summary", "SELECT  "
                            + " (select plasada_rate from tblgeneralsettings) as plasada, "
                            + " sum(if(bet_choice='M',bet_amount,0)) as totalMeron, "
                            + " sum(if(bet_choice='D',bet_amount,0)) as totalDraw, "
                            + " sum(if(bet_choice='W',bet_amount,0)) as totalWala "
                            + " FROM tblfightbets where fightkey='"+fightkey+"'");
    return mainObj;
 }
 %>