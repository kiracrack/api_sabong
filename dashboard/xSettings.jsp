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

    if(x.equals("load_settings")){
        mainObj = general_settings(mainObj);
        mainObj = dummy_accounts(mainObj);
        out.print(Success(mainObj, "Successfull Synchronized"));

    }else if(x.equals("update_settings")){
        String draw_rate = request.getParameter("draw_rate");
        String video_min_credit = request.getParameter("video_min_credit");
        String minbet = request.getParameter("minbet");
        String maxbet = request.getParameter("maxbet");
        boolean enablebetwatcher = Boolean.parseBoolean(request.getParameter("enablebetwatcher"));
        String betwacherid = request.getParameter("betwacherid");
        String betwatchermaxamount = request.getParameter("betwatchermaxamount");
        String betwatcherodds = request.getParameter("betwatcherodds");
        boolean dummy_enable = Boolean.parseBoolean(request.getParameter("dummy_enable"));
        String dummy_account_1 = request.getParameter("dummy_account_1");
        String dummy_account_2 = request.getParameter("dummy_account_2");

        ExecuteQuery("UPDATE tblgeneralsettings set "
                            + " draw_rate='"+draw_rate+"', " 
                            + " video_min_credit='"+video_min_credit+"', "
                            + " minbet='"+minbet+"', "
                            + " maxbet='"+maxbet+"', "
                            + " enablebetwatcher="+enablebetwatcher+", "
                            + " betwacherid='"+betwacherid+"', "
                            + " betwatchermaxamount='"+betwatchermaxamount+"', " 
                            + " betwatcherodds='"+betwatcherodds+"', " 
                            + " dummy_enable="+dummy_enable+", "
                            + " dummy_account_1='"+dummy_account_1+"', "
                            + " dummy_account_2='"+dummy_account_2+"'");

        mainObj = general_settings(mainObj);
        out.print(Success(mainObj, "Settings successfully updated")); 
 
    }else{
        out.print(Error(mainObj, globalInvalidRequest, "404"));
    }

}catch (Exception e){
      out.print(Error(mainObj, e.toString(), "400"));
      logError("dashboard-x-settings",e.toString());
}
%>