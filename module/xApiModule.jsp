 
 <%!public JSONObject api_jackpot_bonus(JSONObject mainObj,  String userid) {
    mainObj = DBtoJson(mainObj, "jackpot", "select id, amount from tblbonuslogs as a where accountid='"+userid+"' and collected=0 order by datetrn asc limit 1");
    return mainObj;
  }
 %>

<%!public JSONObject api_event_info(JSONObject mainObj, String eventid) {
    mainObj = DBtoJson(mainObj, "event", "select eventid, (select plasada_rate from tblgeneralsettings) as plasada, event_standby, fight_result, total_win_meron, total_win_wala, total_draw, total_cancelled, current_status,fightnumber, UCASE(concat((select arenaname from tblarena where arenaid=a.arenaid),' LIVE EVENT (',DAYNAME(current_date),')')) as arenaname from tblevent as a where eventid='"+eventid+"'");
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
    mainObj = DBtoJson(mainObj, "video", "SELECT a.event_standby as standby, a.live_mode as mode, b.source_url as stream_url, b.player_type as stream_player, b.web_available, b.web_url, b.web_player,if(fightnumber=0,false,true) as live_open FROM tblevent a right join tblvideosource b on a.live_sourceid=b.id where eventid='"+eventid+"'");
    return mainObj;
  }
%>

<%!public JSONObject api_result_info(JSONObject mainObj, String eventid) {
    mainObj = DBtoJson(mainObj, "result", "select result as r, fightnumber as rd from tblfightresult where eventid='"+eventid+"'");
    return mainObj;
  }
 %>

<%!public JSONObject api_total_bonus(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "bonus", "SELECT (randamount+totalbonus) as totalbonus FROM tblbonusinfo as a where closed=0 and totalbonus > displayminamount;");
    return mainObj;
  }
 %>

<%!public JSONObject api_current_fight_bet(JSONObject mainObj, String accountid, String fightkey) {
    mainObj = DBtoJson(mainObj, "bet", "SELECT eventid,(select arenaname from tblarena where arenaid=a.arenaid) as arena,fightnumber,transactionno,bet_choice,bet_amount FROM tblfightbets as a where accountid='"+accountid+"' and fightkey='"+fightkey+"';");
    mainObj = DBtoJson(mainObj, "bet_total", "SELECT bet_choice, sum(bet_amount) as total_bet FROM tblfightbets as a where accountid='"+accountid+"' and fightkey='"+fightkey+"' group by bet_choice;");
    return mainObj;
  }
 %>
 
 <%!public JSONObject api_current_event_bet(JSONObject mainObj, String accountid, String eventid) {
    mainObj = DBtoJson(mainObj, "current_event_bet", "SELECT fightnumber, bet_choice, result,  bet_amount, odd, winloss FROM tblfightbets2 as a where accountid='"+accountid+"' and eventid='"+eventid+"' order by id desc limit 5;");
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