<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xCasinoClass.jsp" %>
<%@ include file="../module/xCasinoModule.jsp" %>

<%
   JSONObject mainObj =new JSONObject();
try{

    String x = Decrypt(request.getParameter("x"));
    String userid = request.getParameter("userid");
    String appkey = request.getParameter("appkey");
    String sessionid = request.getParameter("sessionid");

 
    if(x.isEmpty() || userid.isEmpty() || appkey.isEmpty() || sessionid.isEmpty()){
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

    if(x.equals("open_game")){
        String gamesession = request.getParameter("gamesession");
        if(!isSessionAvailable(gamesession)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Game session expired");
            out.print(mainObj);
            return;
        }

        mainObj.put("status", "OK");
        mainObj = LoadGameSession(mainObj, gamesession);
        mainObj.put("message", "response valid");
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
      logError("app-x-play",e.getMessage());
}
%>
 
<%!public boolean isSessionAvailable(String gamesession) {
    return CountQry("tblgamesession", "gamesession='"+gamesession+"'") > 0;
  }
%>

<%!public JSONObject LoadGameSession(JSONObject mainObj, String gamesession) {
    mainObj = DBtoJson(mainObj, "select gameurl from tblgamesession where gamesession='"+gamesession+"'");
    return mainObj;
 }
 %>