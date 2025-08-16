<%@ include file="../module/db.jsp" %>
 
<%
    JSONObject mainObj = new JSONObject();
try{
    String x = Decrypt(request.getParameter("x"));
    String userid = request.getParameter("userid");
    String sessionid = request.getParameter("sessionid");

    if(x.isEmpty() || userid.isEmpty() || sessionid.isEmpty()){
        out.print(Error(mainObj, globalInvalidRequest, "404"));
        return;
        
    }else if(isAdminSessionExpired(userid,sessionid)){
        out.print(Error(mainObj, globalExpiredSessionMessageDashboard, "session"));
        return;
        
    }else if(isAdminAccountBlocked(userid)){
        out.print(Error(mainObj, globalAdminAccountBlocked, "blocked"));
        return;
    }

    if(x.equals("report_template")){
        mainObj = load_report_template(mainObj);
        out.print(Success(mainObj, "Successfull Synchronized"));

    }else if(x.equals("fight_bets_report")){
        String operatorid = request.getParameter("operatorid");
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj = fight_bets_report(mainObj,operatorid,datefrom,dateto);
        out.print(Success(mainObj, "Successfull Synchronized"));

    }else if(x.equals("fight_bets_summary")){
        String operatorid = request.getParameter("operatorid");
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj = fight_bets_summary(mainObj,operatorid,datefrom,dateto);
        out.print(Success(mainObj, "Successfull Synchronized"));

    }else if(x.equals("betting_sabong_report")){
        String accountid = request.getParameter("accountid");
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        //mainObj = LoadSabongBetsReport(mainObj, accountid, datefrom, dateto);
        out.print(Success(mainObj, "data synchronized"));
        
    }else{
        out.print(Error(mainObj, globalInvalidRequest, "404"));
    }

}catch (Exception e){
      out.print(Error(mainObj, e.toString(), "400"));
      logError("dashboard-x-event",e.toString());
}
%>

<%!public JSONObject load_report_template(JSONObject mainObj) {
      mainObj = DBtoJson(mainObj, "report_template", "select * from tblreporttemplate order by id asc");
      return mainObj;
 }
 %>

<%!public JSONObject fight_bets_report(JSONObject mainObj, String operatorid, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "report", "select accountid, " 
                              + " accountname, "
                              + " accountid as 'Account No.', "
                              + " accountname as 'Account Name', "
                              + " platform as 'Platform', " 
                              + " (select arenaname from tblarena where arenaid=a.arenaid) as 'Arena', " 
                              + " eventid as 'Event', " 
                              + " fightnumber as 'Fight No.', " 
                              + " case when bet_choice='M' then 'Meron' when bet_choice='W' then 'Wala' else 'Draw' end as 'Choice', " 
                              + " bet_amount as 'Bet Amount', "
                              + " transactionno as 'Transaction No.', " 
                              + " case when result='M' then 'Meron' when result='W' then 'Wala' else 'Draw' end as 'Result', "
                              + " if(win, 'WIN', if(result='D','CANCELLED','LOSS')) as 'Bet Status', "
                              + " if(win_amount > 0, win_amount, -lose_amount) as 'Win/Loss', "
                              + " concat(ROUND(odd,3),'%') as 'Odd', "
                              + " payout_amount as 'Payout', "
                              + " gros_ge_rate as 'GC Rate', "
                              + " gros_ge_total as 'GC Total', "
                              + " gros_op_rate as 'OP Rate', "
                              + " gros_op_total as 'OP Total', "
                              + " gros_be_rate as 'BE Rate', "
                              + " gros_be_total as 'BE Total', "
                              + " date_format(datetrn,'%Y-%m-%d') as 'Date', " 
                              + " date_format(datetrn,'%r') as 'Time' "
                              + " from tblfightbets2 as a where cancelled=0 and if(win_amount > 0, win_amount, -lose_amount) != 0 " 
                              + " and operatorid='"+operatorid+"' and date_format(datetrn,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"' " 
                              + " order by id asc");

      mainObj = DBtoJson(mainObj, "column", "select 0 as colIndex, '' as colname, '' as colalign union all "
                              + " select 1, 'Account No.', 'center'  union all "
                              + " select 2, 'Account Name', 'left'  union all "
                              + " select 3, 'Master Agent', 'left'  union all "
                              + " select 4, 'Agent', 'left'  union all "
                              + " select 5, 'Platform', 'center'  union all "
                              + " select 6, 'Arena', 'center'  union all "
                              + " select 7, 'Event', 'center'  union all "
                              + " select 8, 'Fight No.', 'center'  union all "
                              + " select 9, 'Choice', 'center'  union all "
                              + " select 10, 'Bet Amount', 'right'  union all "
                              + " select 11, 'Transaction No.', 'center'  union all "
                              + " select 12, 'Result', 'center'  union all "
                              + " select 13, 'Bet Status', 'center'  union all "
                              + " select 14, 'Win/Loss', 'right'  union all "
                              + " select 15, 'Odd', 'center'  union all "
                              + " select 16, 'Payout', 'right'  union all "
                              + " select 17, 'GC Rate', 'center'  union all "
                              + " select 18, 'GC Total', 'right'  union all "
                              + " select 19, 'OP Rate', 'center'  union all "
                              + " select 20, 'OP Total', 'right'  union all "
                              + " select 21, 'BE Rate', 'center'  union all "
                              + " select 22, 'BE Total', 'right'  union all "
                              + " select 23, 'Date', 'center'  union all "
                              + " select 24, 'Time', 'center' "
                              + "");
      return mainObj;
 }
 %>

<%!public JSONObject fight_bets_summary(JSONObject mainObj, String operatorid, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "report", "select "
                              + " accountid, " 
                              + " accountname as fullname, "
                              + " accountid as 'Account No.', " 
                              + " group_concat(distinct (select arenaname from tblarena where arenaid=a.arenaid)) as 'Arena', " 
                              + " group_concat(distinct platform) as 'Platform', " 
                              + " sum(win_amount) - sum(lose_amount) as 'Win/Loss' "
                              + " from tblfightbets2 as a where operatorid='"+operatorid+"' and date_format(datetrn,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"' and cancelled=0 "
                              + " group by accountid");

      mainObj = DBtoJson(mainObj, "column", "select 0 as colIndex, '' as colname, '' as colalign union all "
                              + " select 1, 'Account No.', 'center'  union all "
                              + " select 2, 'Account Name', 'left'  union all "
                              + " select 3, 'Master Agent', 'left'  union all "
                              + " select 4, 'Agent', 'left'  union all "
                              + " select 5, 'Arena', 'center'  union all "
                              + " select 6, 'Platform', 'center'  union all "
                              + " select 7, 'Score Balance', 'right'  union all "
                              + " select 8, 'Win/Loss', 'right'"
                              + "");
      return mainObj;
 }
 %>
 
<%!public JSONObject bet_watcher_report(JSONObject mainObj, String operatorid, boolean range, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "report", "select "
                              + " eventid as 'Arena', " 
                              + " fightnumber as 'Fight No.', " 
                              + " total_meron as 'Total Meron', " 
                              + " total_wala as 'Total Wala', " 
                              + " total_difference as 'Total Difference', " 
                              + " case when auto_bet_choice='M' then 'Meron' when auto_bet_choice='W' then 'Wala' else 'Draw' end as 'Auto Bet Choice', " 
                              + " auto_bet_amount as 'Auto Bet Amount', " 
                              + " CONCAT(ROUND(auto_bet_percent,2),'%') as 'Bet Percentage', " 
                              + " date_format(datetrn,'%Y-%m-%d') as 'Date', " 
                              + " date_format(datetrn,'%r') as 'Time' "
                              + " from tblbetwatcher as a where id > 0 " 
                              + " and operatorid='"+operatorid+"' " 
                              + (range ? " and date_format(datetrn,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"'" : "") 
                              + " order by id asc");

      mainObj = DBtoJson(mainObj, "column", "select 0 as colIndex, '' as colname, '' as colalign union all "
                              + " select 1, 'Arena', 'center' union all "
                              + " select 2, 'Fight No.', 'center'  union all "
                              + " select 3, 'Total Meron', 'right'  union all "
                              + " select 4, 'Total Wala', 'right'  union all "
                              + " select 5, 'Total Difference', 'right'  union all "
                              + " select 6, 'Auto Bet Choice', 'center'  union all "
                              + " select 7, 'Auto Bet Amount', 'right'  union all "
                              + " select 8, 'Bet Percentage', 'center'  union all "
                              + " select 9, 'Date', 'center'  union all "
                              + " select 10, 'Time', 'center' "
                              + "");
      return mainObj;
 }
 %>
 