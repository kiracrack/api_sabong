
<%!public JSONObject api_general_settings(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "settings", "select * from tblgeneralsettings");
    return mainObj;
  }
 %>

 <%!public JSONObject api_account_info(JSONObject mainObj,  String userid, boolean login) {
    AccountInfo info = new AccountInfo(userid);
    JSONObject obj = new JSONObject();
    obj.put("accountid", userid);
    obj.put("operatorid", info.operatorid);
    obj.put("sessionid", info.sessionid);
    obj.put("fullname", info.fullname);
    obj.put("username", info.username);
    obj.put("mobilenumber", info.mobilenumber);
    obj.put("creditbal", info.creditbal);
    obj.put("agentid", info.agentid);
    obj.put("agentname", info.agentname);
    obj.put("isnewaccount", info.isnewaccount);
    obj.put("ismasteragent", info.masteragent);
    obj.put("masteragentid", info.masteragentid);
    obj.put("commissionrate", info.commissionrate);
    obj.put("blocked", info.blocked);
    obj.put("blockedreason", info.blockedreason);
    obj.put("video_min_credit", info.videomincredit);
    obj.put("minbet", info.minbet);
    obj.put("maxbet", info.maxbet);
    obj.put("imageurl", info.imageurl);
    obj.put("datelogin", info.date_now);
    obj.put("timelogin", info.time_now);
    obj.put("totalonline", info.totalonline);
    obj.put("api_player", info.api_player);
    obj.put("isagent", info.isagent);
    obj.put("referralcode", info.referralcode);
    obj.put("iscashaccount", info.iscashaccount);
    obj.put("isonlineagent", info.isonlineagent);
    obj.put("date_registered", info.date_registered);
    
    JSONArray objarray =new JSONArray();
    objarray.add(obj);
    
    mainObj.put("profile", objarray);
    return mainObj;
  }
 %>

<%!public JSONObject api_bank_account(JSONObject mainObj,  String userid) {
    mainObj = DBtoJson(mainObj, "bank_account", "select * from (select *, "
                    + " (select bankname from tblbanks where id=a.bankid) as bankname, "
                    + " (select logourl from tblbanks where id=a.bankid) as logourl, "
                    + " (select if(isbank,'true','false') from tblbanks where id=a.bankid) as isbank "
                    + " from tblbankaccounts as a where accountid='"+userid+"' and deleted=0) as x order by bankname asc");
    return mainObj;
 }
 %>

<%!public JSONObject api_request_count(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "request", "select (select count(*) from tbldeposits where confirmed=0 and cancelled=0) as count_deposit_request, "
                    + " (select count(*) from tblwithdrawal where confirmed=0 and cancelled=0) as count_withdrawal_request "
                    + " from tblsubscriber as a where accountid='"+userid+"'");
    return mainObj;
 }
 %>

<%!public JSONObject api_android_update(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "select apkupdateurl from tblversioncontrol");
    return mainObj;
 }
 %>

<%!public JSONObject api_controller_update(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "select controllerupdateurl from tblversioncontrol");
    return mainObj;
 }
 %>

<%!public JSONObject api_bank_list(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "bank_list", "select * from tblbanks where isbank=1 order by bankname asc");
    return mainObj;
 }
 %>

<%!public JSONObject api_query_deposit(JSONObject mainObj, String refno) {
      mainObj = DBtoJson(mainObj, "deposit_info", sqlDepositQuery + " where refno='"+refno+"'");
      return mainObj;
 }
 %>

<%!public JSONObject api_query_withdrawal(JSONObject mainObj,String refno) {
      mainObj = DBtoJson(mainObj, "withdrawal_info", sqlWithdrawalQuery + " where refno='"+refno+"'");
      return mainObj;
 }
 %>

 

 <%!public JSONObject api_game_statistic(JSONObject mainObj,  String userid) {
    mainObj = DBtoJson(mainObj, "game_statistic", "select imgurl, gameid, game_type, play_count, if(game_type='cockfight', ifnull((select eventid from tblevent where arenaid=a.gameid and event_active=1),''),'') as eventid from tblgamestatistics as a where accountid='"+userid+"' order by play_count desc limit 5");
    return mainObj;
  }
 %>

 <%!public JSONObject api_account_creditbal(JSONObject mainObj,  String userid) {
    mainObj = DBtoJson(mainObj, "creditbal", "select creditbal from tblsubscriber as a where accountid='"+userid+"'");
    return mainObj;
  }
 %>

 <%!public JSONObject api_casino_games(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "game_list", "select a.id, a.gameid, a.gamename, a.provider, b.isnewgame, a.category, IF(IFNULL(a.imgurl2, '') = '',a.imgurl1,a.imgurl2) as imageurl from tblgamelist as a inner join tblgamesource as b on a.gameid=b.gamecode where isenable=1 and category in (select code from tblgamecategory) and a.provider in (select provider from tblgameprovider where active=1) order by rand() ;");            
    return mainObj;
 }
 %>

<%!public JSONObject api_casino_featured(JSONObject mainObj, String masteragentid) {
    mainObj = DBtoJson(mainObj, "game_featured", "select title, imgurl, linkurl from tblgamefeatured where id in (select bannerid from tblbannerfilter where modetype='game_featured' " + (masteragentid.length() > 0 ? "and masteragentid='"+masteragentid+"'" : "") + ") order by priority asc");       
    return mainObj;
 }
 %>

 <%!public JSONObject api_casino_category(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "game_category", "select if(_default,'ALL',code) as code, categoryname, imgurl from tblgamecategory order by priority asc");       
    return mainObj;
 }
 %>

 <%!public JSONObject api_casino_popular(JSONObject mainObj, String mode) {
    mainObj = DBtoJson(mainObj, "game_" + mode, "SELECT a.gameid,a.gamename, isnewgame, a.provider,IF(IFNULL((select imgurl2 from tblgamelist where gameid=a.gameid), '') = '', a.imageurl, (select imgurl2 from tblgamelist where gameid=a.gameid)) as imageurl FROM tblgamepopular as a inner join tblgamesource as b on a.gameid=b.gamecode where `mode`='"+mode+"' and a.provider in (select provider from tblgameprovider where active=1) order by rand() limit 6");       
    return mainObj;
 }
 %>

<%!public JSONObject api_active_arena(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "game_arena", "select *, ifnull((select eventid from tblevent where arenaid=a.arenaid and event_active=1),'') as eventid from tblarena as a where active=1");
    return mainObj;
  }
 %>

<%!public JSONObject api_event_info(JSONObject mainObj, String eventid) {
    mainObj = DBtoJson(mainObj, "event", "select eventid, event_standby, fight_result, total_win_meron, total_win_wala, total_draw, total_cancelled, current_status,fightnumber, (select vertical_banner_url from tblarena where arenaid=a.arenaid) as vertical_banner, (select opposite_bet from tblarena where arenaid=a.arenaid) as opposite_bet, (select if(disabled,'false','true') from tblpromo where filename='promo_win_strike') as winstrike_enabled from tblevent as a where eventid='"+eventid+"'");
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
    mainObj = DBtoJson(mainObj, "video", "SELECT a.event_standby as standby, a.live_mode as mode, b.source_url as stream_url, b.player_type as stream_player, b.web_available, b.web_url, b.web_player FROM tblevent a right join tblvideosource b on a.live_sourceid=b.id where eventid='"+eventid+"'");
    return mainObj;
  }
%>

<%!public JSONObject api_result_info(JSONObject mainObj, String eventid) {
    mainObj = DBtoJson(mainObj, "result", "select result as r, if(result='C','X',fightnumber) as rd from tblfightresult where eventid='"+eventid+"'");
    return mainObj;
  }
 %>

<%!public JSONObject api_current_fight_bet(JSONObject mainObj, String accountid, String fightkey) {
    mainObj = DBtoJson(mainObj, "bet", "SELECT eventid,(select arenaname from tblarena where arenaid=a.arenaid) as arena,concat(fightnumber, if(length(ws_selection) > 0,concat(' (',ws_selection,')',''),'')) as fightnumber,transactionno,bet_choice,bet_amount FROM tblfightbets as a where accountid='"+accountid+"' and fightkey='"+fightkey+"';");
    mainObj = DBtoJson(mainObj, "bet_total", "SELECT  bet_choice, sum(bet_amount) as total_bet FROM tblfightbets as a where accountid='"+accountid+"' and fightkey='"+fightkey+"' group by bet_choice;");
    return mainObj;
  }
 %>
 
 <%!public JSONObject api_current_event_bet(JSONObject mainObj, String accountid, String eventid) {
    mainObj = DBtoJson(mainObj, "current_event_bet", "SELECT fightnumber, bet_choice, result,  bet_amount, round(odd,3) as odd, round(if(cancelled,0,if(win,win_amount, if(result='D', 0, -lose_amount) )),2) as win_loss FROM tblfightbets2 as a where accountid='"+accountid+"' and eventid='"+eventid+"' order by id desc limit 5;");
    return mainObj;
  }
 %>

<%!public JSONObject api_credit_load_logs(JSONObject mainObj, String accountid, String datefrom, String dateto) {
    mainObj = DBtoJson(mainObj, "credit_logs", "SELECT  *, date_format(datetrn, '%m/%d/%y') as 'date', result, date_format(datetrn, '%r') as 'time' FROM tblcreditloadlogs as a where accountid='"+accountid+"' and date_format(datetrn, '%Y-%m-%d') between '" + datefrom + "' and '" + dateto + "';");
    return mainObj;
  }
 %>
 
<%!public JSONObject api_operator_bank(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "bank_list", "select bankid, code as bankcode, accountnumber,accountname,qrcode_url, (select logourl from tblbanks where id=a.bankid) as logourl, " 
                        + " (select bankname from tblbanks where id=a.bankid) as bankname " 
                        + " from tblbankoperator as a where actived=1 and deleted=0");
    return mainObj;
 }
 %>

<%!public JSONObject api_telco_list(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "telco_list", "select id as bankid, bankname, logourl from tblbanks where isbank=0 and deleted=0");
    return mainObj;
 }
 %>

<%!public JSONObject api_account_list(JSONObject mainObj,String userid, boolean isagent) {
    mainObj = DBtoJson(mainObj, "accounts", "select accountid,fullname,username,mobilenumber,creditbal,commissionrate,iscashaccount,photourl,photoupdated,isagent,agentid,blocked,lastlogindate,current_timestamp from tblsubscriber as a where (agentid='"+userid+"' or agentid in (select accountid from tblsubscriber where agentid='"+userid+"' and iscashaccount=1)) and isagent=" + isagent + " and deleted=0 order by fullname asc");
    return mainObj;
}
%>

<%!public JSONObject api_deposit_list(JSONObject mainObj,String userid) {
    mainObj = DBtoJson(mainObj, "deposit", sqlDepositQuery + " where accountid='" + userid + "' order by id desc");
    return mainObj;
 }
 %>
 
<%!public JSONObject api_turnover_promo(JSONObject mainObj, String userid) {
    mainObj = DBtoJson(mainObj, "turnover_promo", sqlDailyTurnoverQuery(userid));
    return mainObj;
 }
 %>

<%!public JSONObject api_winstrike_promo(JSONObject mainObj, String userid, String eventid, String category) {
    mainObj = DBtoJson(mainObj, "winstrike_promo", sqlWinstrikeQuery(userid, eventid, category));
    return mainObj;
 }
 %>

<%!public JSONObject api_promo_list(JSONObject mainObj, String operatorid) {
    mainObj = DBtoJson(mainObj, "promo", "select banner_url from tblpromo where " +(operatorid.length() > 0 ? "operatorid='"+operatorid+"' and" : "")+ " visible=1 order by sortorder asc");
    return mainObj;
 }
 %>

<%!public JSONObject api_promotion_list(JSONObject mainObj, String operatorid) {
    mainObj = DBtoJson(mainObj, "promotion", "select title, filename, push_message, banner_url, disabled, visible from tblpromo where category='PROMOTION' " +(operatorid.length() > 0 ? " and operatorid='"+operatorid+"'" : "")+ " and disabled=0 order by sortorder asc");
    return mainObj;
 }
 %>

<%!public JSONObject api_promotion_status(JSONObject mainObj, String operatorid) {
    mainObj = DBtoJson(mainObj, "promotion", "select filename, disabled from tblpromo where category='PROMOTION' " +(operatorid.length() > 0 ? " and operatorid='"+operatorid+"'" : "")+ " order by sortorder asc");
    return mainObj;
 }
 %>
 

