<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xGameModule.jsp" %>

<%
   JSONObject mainObj =new JSONObject();
try{

    String x = Decrypt(request.getParameter("x"));
    String deviceid = request.getParameter("deviceid");
    String sessionid = request.getParameter("sessionid");

    if(x.isEmpty() || deviceid.isEmpty() || sessionid.isEmpty()){
        out.print(Error(mainObj, globalInvalidRequest, "404"));
        return;

    }else if(isControllerRemoved(deviceid)){
        out.print(Status(mainObj, "BLOCKED", "Your controller was removed by administrator!", "403"));
        return;

    }else if(isControllerBlocked(deviceid)){
        out.print(Status(mainObj, "BLOCKED", "Your controller was removed by administrator!", "403"));
        return;
    }

    if(x.equals("dummy_post_bet")){ 
        String eventid = request.getParameter("eventid");
        String accountid = request.getParameter("accountid");
        String dummy_id = request.getParameter("dummy_id");
        String dummy_name = request.getParameter("dummy_name");
        String bet_choice = request.getParameter("bet_choice");
        String bet_amount = request.getParameter("bet_amount");
        String appreference = request.getParameter("appreference");

        EventInfo event = new EventInfo(eventid, false);
        String fightkey = event.fightkey;
        
        if(CountQry("tblevent", "eventid='"+eventid+"' and (current_status='closed' or current_status='result')") > 0 ){
            out.print(Error(mainObj, "Current fight is already closed!", "100"));
            return;
            
        }else if(CountQry("tblevent", "eventid='"+eventid+"' and current_status='standby'") > 0 ){
            out.print(Error(mainObj, "Current fight is not yet open!", "100"));
            return;

        }else if(CountQry("tblevent", "eventid='"+eventid+"' and current_status='cancelled'") > 0 ){
            out.print(Error(mainObj, "Current fight is cancelled!", "100"));
            return;
        }

        ExecutePostBet(eventid, sessionid, appreference, "", accountid, dummy_name, bet_choice, Double.parseDouble(bet_amount), false, true);

        mainObj = getBetSummary(mainObj, fightkey);
        out.print(Success(mainObj, "request returned valid"));

        JSONObject apiObj = new JSONObject();
        apiObj.put("plasada", GlobalPlasadaRate);
        apiObj =  api_fight_summary(apiObj, fightkey);
        PusherPost(eventid, apiObj);
       
    }else{
        out.print(Error(mainObj, globalInvalidRequest, "404"));
        
    }
}catch (Exception e){
      out.print(Error(mainObj, e.toString(), "400"));
      logError("controller-x-dummy",e.toString());
}
%>



