<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xSabongModule.jsp" %>
<%@ include file="../module/xCasinoModule.jsp" %>
<%@ include file="../module/xCasinoClass.jsp" %>

<%
   JSONObject mainObj =new JSONObject();
try{

    String x = Decrypt(request.getParameter("x"));
    String userid = request.getParameter("userid");
    String appkey = request.getParameter("appkey");
    String sessionid = request.getParameter("sessionid");
 
    if(x.isEmpty() || userid.isEmpty() || appkey.isEmpty() || (sessionid.isEmpty() && !isAllowedMultiSession(userid))){
        mainObj = ErrorResponse(mainObj, "request not valid", "404");
        out.print(mainObj);
        return;

    }else if(globalEnableMaintainance){
        mainObj = ErrorResponse(mainObj, globalMaintainanceMessage, "maintenance");
        out.print(mainObj);
        return;

    }else if(!isAppkeyFound(appkey)){
        mainObj = ErrorResponse(mainObj, "app access is not allowed", "session");
		out.print(mainObj);
        return;

    }else if(!isAppkeyEnabled(appkey)){
        mainObj = ErrorResponse(mainObj, "your application is disabled", "session");
		out.print(mainObj);
        return;

    }else if(isSessionExpired(userid,sessionid)){
        mainObj = ErrorResponse(mainObj, globalExpiredSessionMessage, "session");
		out.print(mainObj);
        return;
    }
 
    if(x.equals("score_ledger")){
        String accountid = request.getParameter("accountid");
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj.put("status", "OK");
        mainObj = LoadScoreLedger(mainObj, accountid, datefrom, dateto);
        mainObj.put("message", "data synchronized");
        out.print(mainObj);

    }else if(x.equals("game_report_cockfight")){
        String accountid = request.getParameter("accountid");
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj = LoadSabongBetsReport(mainObj, accountid, datefrom, dateto);
        mainObj.put("status", "OK");
        mainObj.put("message", "data synchronized");
        out.print(mainObj);

    }else if(x.equals("game_report_casino")){
        String accountid = request.getParameter("accountid");
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj = LoadCasinoGameReport(mainObj, accountid, datefrom, dateto);
        mainObj.put("status", "OK");
        mainObj.put("message", "data synchronized");
        out.print(mainObj);
 
    } else if(x.equals("score_request")){
        boolean customer = Boolean.parseBoolean(request.getParameter("customer"));
        String keyword = request.getParameter("keyword");
        String pageno = request.getParameter("pageno");
        int pgno  =  Integer.parseInt(pageno) * GlobalRecordsLimit;

        String search = " and (userid like '%" + rchar(keyword) + "%' or (select fullname from tblsubscriber where accountid=a.userid) like '%" + rchar(keyword) + "%')";

        mainObj = LoadScoreRequest(mainObj, userid, customer, search, pgno);
        mainObj.put("status", "OK");
        mainObj.put("message","Result synchronized");
        out.print(mainObj);
 
    }else if(x.equals("get_player_bets")){ 
        String fightkey = request.getParameter("fightkey");
        String operatorid = request.getParameter("operatorid");

        mainObj.put("status", "OK");
        mainObj = FetchCurrentBets(mainObj, fightkey, operatorid);
        mainObj.put("message","request returned valid");
        out.print(mainObj);

    }else if(x.equals("load_promo")){ 
        String operatorid = getOperatorid(userid);

        mainObj.put("status", "OK");
        mainObj = LoadPromoApp(mainObj, operatorid);
        mainObj.put("message","request returned valid");
        out.print(mainObj);
        
    }else{
        mainObj.put("status", "ERROR");
        mainObj.put("message","request not valid");
        mainObj.put("errorcode", "404");
        out.print(mainObj);
    }

}catch (Exception e){
      mainObj.put("status", "ERROR");
      mainObj.put("message", e.toString());
      mainObj.put("errorcode", "400");
      out.print(mainObj);
      logError("app-x-report",e.getMessage());
}
%>
 
