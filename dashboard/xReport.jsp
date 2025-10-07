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
        out.print(Success(mainObj, globaApiValidMessage));

    }else if(x.equals("fight_bets_report")){
        String operatorid = request.getParameter("operatorid");
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj = fight_bets_report(mainObj,operatorid,datefrom,dateto);
        out.print(Success(mainObj, globaApiValidMessage));

    }else if(x.equals("fight_bets_summary")){
        String operatorid = request.getParameter("operatorid");
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj = fight_bets_summary(mainObj,operatorid,datefrom,dateto);
        out.print(Success(mainObj, globaApiValidMessage));

    }else if(x.equals("winloss_report")){
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj = winloss_report(mainObj,datefrom,dateto);
        out.print(Success(mainObj, globaApiValidMessage));
        
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
      mainObj = DBtoJson(mainObj, "report", "select accountid, accountname, "
                              + " (select companyname from tbloperator where companyid = a.operatorid) as 'Operator', "
                              + " accountid as 'Account ID', "
                              + " accountname as 'Account Name', "
                              + " (select arenaname from tblarena where arenaid=a.arenaid) as 'Arena', " 
                              + " eventid as 'Event', " 
                              + " fightnumber as 'Fight No.', " 
                              + " case when bet_choice='M' then 'Meron' when bet_choice='W' then 'Wala' else 'Draw' end as 'Choice', " 
                              + " bet_amount as 'Bet Amount', "
                              + " transactionno as 'Transaction No.', " 
                              + " case when result='M' then 'Meron' when result='W' then 'Wala' else 'Draw' end as 'Result', "
                              + " if(win, 'WIN', if(result='D','CANCELLED','LOSS')) as 'Bet Status', "
                              + " concat(ROUND(odd,3),'%') as 'Odd', "
                              + " payout_amount as 'Payout', "
                              + " payback_rate as 'PB Rate', "
                              + " payback_total as 'PB Total', "
                              + " winloss as 'Win/Loss', "
                              + " date_format(datetrn,'%Y-%m-%d') as 'Date', " 
                              + " date_format(datetrn,'%r') as 'Time' "
                              + " from tblfightbets2 as a where cancelled=0 and winloss != 0 " 
                              + " and operatorid='"+operatorid+"' and date_format(datetrn,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"' " 
                              + " order by id asc");

      mainObj = DBtoJson(mainObj, "column", "select 0 as colIndex, '' as colname, '' as colalign union all "
                              + " select 1, 'Operator', 'center'  union all "
                              + " select 2, 'Account ID', 'center'  union all "
                              + " select 3, 'Account Name', 'left'  union all "
                              + " select 4, 'Arena', 'center'  union all "
                              + " select 5, 'Event', 'center'  union all "
                              + " select 6, 'Fight No.', 'center'  union all "
                              + " select 7, 'Choice', 'center'  union all "
                              + " select 8, 'Bet Amount', 'right'  union all "
                              + " select 9, 'Transaction No.', 'center'  union all "
                              + " select 10, 'Result', 'center'  union all "
                              + " select 11, 'Bet Status', 'center'  union all "
                              + " select 12, 'Odd', 'center'  union all "
                              + " select 13, 'Payout', 'right'  union all "
                              + " select 14, 'PB Rate', 'center'  union all "
                              + " select 15, 'PB Total', 'right'  union all "
                              + " select 16, 'Win/Loss', 'right'  union all "
                              + " select 17, 'Date', 'center'  union all "
                              + " select 18, 'Time', 'center' "
                              + "");
      return mainObj;
 }
 %>

<%!public JSONObject fight_bets_summary(JSONObject mainObj, String operatorid, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "report", "select "
                              + " accountid, accountname, " 
                              + " (select companyname from tbloperator where companyid = a.operatorid) as 'Operator', "
                              + " accountid as 'Account ID.', " 
                              + " accountname as 'Account Name', "
                              + " group_concat(distinct (select arenaname from tblarena where arenaid=a.arenaid)) as 'Arena', " 
                              + " sum(winloss) as 'Win/Loss' "
                              + " from tblfightbets2 as a where operatorid='"+operatorid+"' and date_format(datetrn,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"' and cancelled=0 "
                              + " group by accountid");

      mainObj = DBtoJson(mainObj, "column", "select 0 as colIndex, '' as colname, '' as colalign union all "
                              + " select 1, 'Operator', 'center'  union all "
                              + " select 2, 'Account ID', 'center'  union all "
                              + " select 3, 'Account Name', 'left'  union all "
                              + " select 4, 'Arena', 'left'  union all "
                              + " select 5, 'Win/Loss', 'right'"
                              + "");
      return mainObj;
 }
 %>
  
  <%!public JSONObject winloss_report(JSONObject mainObj, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "report", "select Operator, gross as 'Gross Sales', (gross*0.10) as 'BE Charges', gross-(gross*0.10) as 'Net Sales', "
                              + " (select companyname from tbloperator where companyid = a.operatorid) as operator, "
                              + " sum(winloss) as gross from tblfightbets2 as a where date_format(datetrn,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"' and cancelled=0 "
                              + " group by operatorid");

      mainObj = DBtoJson(mainObj, "column", "select 0 as colIndex, '' as colname, '' as colalign union all "
                              + " select 1, 'Operator', 'center'  union all "
                              + " select 2, 'Gross Sales', 'right'  union all "
                              + " select 3, 'BE Charges', 'right'  union all "
                              + " select 4, 'Net Sales', 'right'"
                              + "");
      return mainObj;
 }
 %>