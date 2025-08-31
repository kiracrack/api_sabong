<%@ include file="../module/db.jsp" %>

<%
    JSONObject mainObj =new JSONObject();
    JSONObject apiObj = new JSONObject();
try{

    String x = Decrypt(request.getParameter("x"));
    String appkey = request.getParameter("appkey");
    String userid = request.getParameter("userid");
    String sessionid = request.getParameter("sessionid");

   if(x.isEmpty() || appkey.isEmpty() || userid.isEmpty() || sessionid.isEmpty()){
        out.print(Error(mainObj, globalInvalidRequest, "404"));
        return;

    }else if(!isOperatorExist(appkey)){
        out.print(Status(mainObj, "ERROR", "Operator is not permitted to use this app!", "403"));
        return;

    }else if(!isOperatorActived(appkey)){
        out.print(Status(mainObj, "ERROR", "Operator is inactived!", "403"));
        return;

    }else if(isOperatorBlocked(appkey)){
        out.print(Status(mainObj, "ERROR", "Operator is currently blocked", "403"));
        return;

    }

    if(x.equals("event")){ 
        String eventid = request.getParameter("eventid");
        EventInfo event = new EventInfo(eventid, false);
        ArenaInfo arena = new ArenaInfo(event.arenaid);

        OperatorInfo op = new OperatorInfo(appkey);
        String accountid = op.operatorid + userid;

        mainObj.put("plasada", GlobalPlasadaRate);
       
        mainObj = api_event_info(mainObj, eventid);
        mainObj = api_event_notice(mainObj, eventid);
        mainObj = api_event_video(mainObj, eventid);
        mainObj = api_result_info(mainObj, eventid);
        mainObj = api_arena_info(mainObj, event.arenaid);
        mainObj = api_fight_summary(mainObj, event.fightkey);
        mainObj = api_current_fight_bet(mainObj, accountid, event.fightkey);
        
        out.print(Success(mainObj, globaApiValidMessage));

    }else{
        out.print(Error(mainObj, globalInvalidRequest, "404"));
        
    }

}catch (Exception e){
      out.print(Error(mainObj, e.toString(), "400"));
      logError("controller-x-event",e.toString());
}
%>

