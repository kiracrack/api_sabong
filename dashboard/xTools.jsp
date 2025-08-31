<%@ include file="../module/db.jsp" %>
 
<%
    JSONObject mainObj = new JSONObject();
    JSONObject apiObj = new JSONObject();

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

    if(x.equals("emergency_disable_app")){
        Boolean disable = Boolean.parseBoolean(request.getParameter("disable"));
    
        ExecuteQuery("UPDATE tblgeneralsettings set under_maintenance="+disable+"");
        LogActivity(userid,(disable? "set emergency disabled app" : "set app enabled"));   
        
        mainObj = getGeneralSettings(mainObj);
        out.print(Success(mainObj, (disable?  "Server maintenance mode sucessfully enabled" : "Server maintenance mode sucessfully disabled"))); 

        if(disable){
            apiObj.put("maintenance", disable);
            apiObj.put("title", "Notice");
            apiObj.put("message", globalMaintainanceMessage);
            //PusherPost("global", apiObj);
        }
        
    
    }else if(x.equals("clear_ledger_logs")){
        if(!globalMaintenance){
            out.print(Error(mainObj, "Cannot proceed clearing game ledger logs! Please enable maintenance mode", "101"));
            return;
        }

        ExecuteQuery("TRUNCATE tblcreditledgerlogs");
        LogActivity(userid,"cleared game ledger logs");   
        out.print(Success(mainObj, "Game ledger successfully cleared")); 

    }else if(x.equals("clear_dummy_transaction")){
        if(!globalMaintenance){
            out.print(Error(mainObj, "Cannot proceed clearing dummy transaction! Please enable maintenance mode", "100"));
            return;
        }

        ExecuteQuery("truncate tblfightbetsdummy");
        LogActivity(userid,"cleared dummy transaction");   
        
        out.print(Success(mainObj, "Dummy transaction successfully cleared")); 

    }else if(x.equals("reverse_result")){
        
    }else if(x.equals("cancel_result")){
        
       
    }else if(x.equals("fight_result_logs")){
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj = LoadFightResultLogs(mainObj, datefrom, dateto);
        out.print(Success(mainObj, globaApiValidMessage)); 

    }else if(x.equals("fight_transaction")){
        String fightkey = request.getParameter("fightkey");
        String mode = request.getParameter("mode");

        mainObj = LoadFightResultDetails(mainObj, fightkey);
        out.print(Success(mainObj, globaApiValidMessage)); 

    }else if(x.equals("cancelled_fight_logs")){
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj = LoadCancelledFightLogs(mainObj, datefrom, dateto);
        out.print(Success(mainObj, globaApiValidMessage)); 


    }else if(x.equals("missing_bet_logs")){
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj = LoadMissingBetLogs(mainObj, datefrom, dateto);
        out.print(Success(mainObj, globaApiValidMessage)); 

    }else{
        out.print(Error(mainObj, globalInvalidRequest, "404"));
    }

}catch (Exception e){
      out.print(Error(mainObj, e.toString(), "400"));
      logError("dashboard-x-tools",e.toString());
}
%>

<%!public boolean isCancelled(String fightkey) {
    return CountQry("tblfightsummary", "fightkey='"+fightkey+"' and result='C'") > 0;
  }
%>

<%!public boolean isTransactionFound(String fightkey) {
    return CountQry("tblfightbets", "fightkey='"+fightkey+"'") > 0;
  }
%>

<%!public JSONObject LoadFightResultLogs(JSONObject mainObj, String datefrom, String dateto) {
    mainObj = DBtoJson(mainObj, "fight_result", "select eventid,fightkey,fightnumber, case  when result='M' then 'MERON'  when result='D' then 'DRAW' when result='W' then 'WALA' else 'CANCELLED' end as result, "
                            + " date_format(datetrn,'%Y-%m-%d') as 'date', " 
                            + " date_format(datetrn,'%r') as 'time' " 
                            + " from tblfightresult as a where date_format(datetrn,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"'");
    return mainObj;
}
%>

<%!public JSONObject LoadFightResultDetails(JSONObject mainObj, String fightkey) {
    mainObj = DBtoJson(mainObj, "fight_transaction", "select accountid, " 
                              + " accountname as fullname, "
                              + " eventid, " 
                              + " fightnumber, " 
                              + " case when bet_choice='M' then 'Meron' when bet_choice='W' then 'Wala' else 'Draw' end as 'bet_choice', " 
                              + " bet_amount, "
                              + " case when result='M' then 'Meron' when result='W' then 'Wala' else 'Draw' end as 'result', "
                              + " if(win, 'WIN', if(result='D','CANCELLED','LOSS')) as 'bet_status', "
                              + " concat(ROUND(odd,3),'%') as 'odd', "
                              + " payout_amount, "
                              + " date_format(datetrn,'%Y-%m-%d') as 'date', " 
                              + " date_format(datetrn,'%r') as 'time' "
                              + " from tblfightbets2 as a where fightkey='"+fightkey+"' and dummy=0 order by id asc");
    return mainObj;
}
%>

<%!public JSONObject LoadCancelledFightLogs(JSONObject mainObj, String datefrom, String dateto) {
    mainObj = DBtoJson(mainObj, "cancelled_fight", "select eventid,fightkey,fightnumber, "
                            + " if((select count(*) from tblfightlogs where fightkey=a.fightkey)>0,(select count(*) from tblfightlogs where fightkey=a.fightkey  and (accountid<> (select dummy_account_1 from tbloperator where companyid=a.operatorid) and accountid<> (select dummy_account_2 from tbloperator where companyid=a.operatorid))),(select count(*) from tblfightlogs2 where fightkey=a.fightkey  and (accountid<> (select dummy_account_1 from tbloperator where companyid=a.operatorid) and accountid<> (select dummy_account_2 from tbloperator where companyid=a.operatorid)))) as return_count,"
                            + " (select count(distinct accountid) from tblfightbets2 where fightkey=a.fightkey  and (accountid<> (select dummy_account_1 from tbloperator where companyid=a.operatorid) and accountid<> (select dummy_account_2 from tbloperator where companyid=a.operatorid))) as bets_count,"
                            + " (select count(*) from tblcreditledger where appreference=a.fightkey and (accountid<> (select dummy_account_1 from tbloperator where companyid=a.operatorid) and accountid<> (select dummy_account_2 from tbloperator where companyid=a.operatorid))) as ledger_count,"
                            + " date_format(datetrn,'%Y-%m-%d') as 'date', " 
                            + " date_format(datetrn,'%r') as 'time' " 
                            + " from tblfightsummary as a where result='C' and date_format(datetrn,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"'");
    return mainObj;
}
%>


<%!public JSONObject LoadMissingBetLogs(JSONObject mainObj, String datefrom, String dateto) {
    mainObj = DBtoJson(mainObj, "missing_bet", "select  date_format(datetrn,'%Y-%m-%d') as 'date', eventid, fightkey, fightnumber, " 
                              + " count(*) totalbettors, "
                              + " sum(bet_amount) totalbets "
                              + " from tblfightbets as a where fightkey not in (select fightkey from tblevent where event_active=1) and dummy=0 and " 
                              + " date_format(datetrn,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"' group by fightkey");
    return mainObj;
}
%>

 
<%!public void RestoreBetsTable(String fightkey) {
    if(CountQry("tblfightbets2", "fightkey='"+fightkey+"'") > 0){
        ExecuteResult("DELETE from tblfightbets where fightkey='"+fightkey+"'");

        ExecuteResult("INSERT INTO tblfightbets (operatorid,accountid,accountname,banker,dummy,sessionid,appreference,arenaid,eventid,eventkey,fightkey,fightnumber,postingdate,transactionno,bet_choice,bet_amount,result,win,odd,win_amount,lose_amount,payout_amount,plasada,payback_rate,payback_total,winloss,datetrn,cancelled,cancelledreason) " 
            + " SELECT operatorid,accountid,accountname,banker,dummy,sessionid,appreference,arenaid,eventid,eventkey,fightkey,fightnumber,postingdate,transactionno,bet_choice,bet_amount,result,win,odd,win_amount,lose_amount,payout_amount,plasada,payback_rate,payback_total,winloss,datetrn,cancelled,cancelledreason FROM tblfightbets2 where fightkey='"+fightkey+"'");
    }
}
%>

<%!public void BackupBetsTable(String fightkey) {
    if(CountQry("tblfightbets", "fightkey='"+fightkey+"'") > 0){
        ExecuteResult("DELETE from tblfightbets2 where fightkey='"+fightkey+"'");

        ExecuteResult("INSERT INTO tblfightbets2 (operatorid,accountid,accountname,banker,dummy,sessionid,appreference,arenaid,eventid,eventkey,fightkey,fightnumber,postingdate,transactionno,bet_choice,bet_amount,result,win,odd,win_amount,lose_amount,payout_amount,plasada,payback_rate,payback_total,winloss,datetrn,cancelled,cancelledreason) " 
            + " SELECT operatorid,accountid,accountname,banker,dummy,sessionid,appreference,arenaid,eventid,eventkey,fightkey,fightnumber,postingdate,transactionno,bet_choice,bet_amount,result,win,odd,win_amount,lose_amount,payout_amount,plasada,payback_rate,payback_total,winloss,datetrn,cancelled,cancelledreason FROM tblfightbets where fightkey='"+fightkey+"' and dummy=0");
    }
}
%>
