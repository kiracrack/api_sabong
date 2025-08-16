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

    if(x.equals("load_dummy_Account")){
        mainObj = LoadDummyNames(mainObj);
        out.print(Success(mainObj, "Successfull Synchronized"));

    }else if(x.equals("upload_dummy_name")){
        String file_content = request.getParameter("file_content");
        
        ExecuteQuery("DELETE FROM tbldummyname");
        String line = "";
        BufferedReader bufReader = new BufferedReader(new StringReader(file_content));
        while((line=bufReader.readLine()) != null ){
            String[] parts = line.split(",");
            ExecuteQuery("INSERT INTO tbldummyname set accountno='"+QuoteValue(parts[0])+"', dummyname='"+QuoteValue(parts[1])+"'");
        }


        mainObj = LoadDummyNames(mainObj);
        out.print(Success(mainObj, "Dummy account successfully uploaded!"));

    }else if(x.equals("load_getDummySettings")){
        mainObj = LoadDummySettings(mainObj);
        out.print(Success(mainObj, "Successfull Synchronized"));
    
    }else if(x.equals("set_getDummySettings")){
        String am_amt_from = request.getParameter("am_amt_from");
        String am_amt_to = request.getParameter("am_amt_to");
        String am_amt_time = request.getParameter("am_amt_time");
        String pm_amt_from = request.getParameter("pm_amt_from");
        String pm_amt_to = request.getParameter("pm_amt_to");
        String pm_amt_time = request.getParameter("pm_amt_time");
        String eve_amt_from = request.getParameter("eve_amt_from");
        String eve_amt_to = request.getParameter("eve_amt_to");
        String eve_amt_time = request.getParameter("eve_amt_time");
        String mid_amt_from = request.getParameter("mid_amt_from");
        String mid_amt_to = request.getParameter("mid_amt_to");
        String mid_amt_time = request.getParameter("mid_amt_time");
        String time_am = request.getParameter("time_am");
        String range_am_from = request.getParameter("range_am_from");
        String range_am_to = request.getParameter("range_am_to");
        String time_pm = request.getParameter("time_pm");
        String range_pm_from = request.getParameter("range_pm_from");
        String range_pm_to = request.getParameter("range_pm_to");
        String time_eve = request.getParameter("time_eve");
        String range_eve_from = request.getParameter("range_eve_from");
        String range_eve_to = request.getParameter("range_eve_to");
        String time_mid = request.getParameter("time_mid");
        String range_mid_from = request.getParameter("range_mid_from");
        String range_mid_to = request.getParameter("range_mid_to");
        
        String CommandQuery = " am_amt_from='"+am_amt_from+"', "
                    + " am_amt_to='"+am_amt_to+"', "
                    + " am_amt_time='"+am_amt_time+"', "
                    + " pm_amt_from='"+pm_amt_from+"', "
                    + " pm_amt_to='"+pm_amt_to+"', "
                    + " pm_amt_time='"+pm_amt_time+"', "
                    + " eve_amt_from='"+eve_amt_from+"', "
                    + " eve_amt_to='"+eve_amt_to+"', "
                    + " eve_amt_time='"+eve_amt_time+"', "
                    + " mid_amt_from='"+mid_amt_from+"', "
                    + " mid_amt_to='"+mid_amt_to+"', "
                    + " mid_amt_time='"+mid_amt_time+"', "
                    + " time_am='"+time_am+"', "
                    + " range_am_from='"+range_am_from+"', "
                    + " range_am_to='"+range_am_to+"', "
                    + " time_pm='"+time_pm+"', " 
                    + " range_pm_from='"+range_pm_from+"', " 
                    + " range_pm_to='"+range_pm_to+"', " 
                    + " time_eve='"+time_eve+"', "
                    + " range_eve_from='"+range_eve_from+"', "
                    + " range_eve_to='"+range_eve_to+"', "
                    + " time_mid='"+time_mid+"', "
                    + " range_mid_from='"+range_mid_from+"', "
                    + " range_mid_to='"+range_mid_to+"'";

        if(CountRecord("tbldummysettings") > 0){
            ExecuteQuery("update tbldummysettings set " + CommandQuery);
        }else{
            ExecuteQuery("insert into tbldummysettings set " + CommandQuery);
        }

        mainObj = LoadDummySettings(mainObj);
        out.print(Success(mainObj, "Settings successfully saved"));

    }else{
        out.print(Error(mainObj, globalInvalidRequest, "404"));
    }
    
}catch (Exception e){
      out.print(Error(mainObj, e.toString(), "400"));
      logError("dashboard-x-DUMMY",e.toString());
}
%>

<%!public JSONObject LoadDummyNames(JSONObject mainObj) {
      mainObj = DBtoJson(mainObj, "dummy_account", "select * from tbldummyname");
      return mainObj;
}
%>

<%!public JSONObject LoadDummySettings(JSONObject mainObj) {
      mainObj = DBtoJson(mainObj, "getDummySettings", "select * from tbldummysettings");
      return mainObj;
}
%>