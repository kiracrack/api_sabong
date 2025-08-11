<%@ include file="../module/db.jsp" %>

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
    
    if(x.equals("arena")){ 
        mainObj.put("status", "OK");
        mainObj = getActiveArena(mainObj);
        mainObj.put("message", "data synchronized");
        out.print(mainObj); 

    }else if(x.equals("event_info")){
        String eventid = request.getParameter("eventid");

        mainObj.put("status", "OK");
        mainObj = getAccountInformation(mainObj, userid);
        mainObj = getEventInfo(mainObj, eventid);
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
      logError("app-x-event",e.getMessage());
}
%>

<%!public boolean MaxBet(String userid, String fightkey, double addBet, double maxbet) {
    double totalBet = Double.parseDouble(QuerySingleData("ifnull(sum(bet_amount),0)","totalbet", "tblfightbets where accountid='" + userid + "' and fightkey='"+fightkey+"'")); 
    if((totalBet+addBet) > maxbet){
        return true;
    }else{
        return false;
    }
  }
 %>