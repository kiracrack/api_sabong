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

    if(x.equals("load_controller")){
        mainObj = LoadController(mainObj);
        out.print(Success(mainObj, "Successfull Synchronized"));

    }else if(x.equals("approved_controller")){
        boolean approved = Boolean.parseBoolean(request.getParameter("approved"));
        String deviceid = request.getParameter("deviceid");
        String devicename = request.getParameter("devicename");
        
        if(approved){
                ExecuteQuery("update tblcontroller set approved=1, devicename='"+rchar(devicename)+"' where deviceid = '"+deviceid+"';");
                LogActivity(userid,"approved controller " + devicename);   
        }else{
                ExecuteQuery("update tblcontroller set devicename='"+rchar(devicename)+"' where deviceid = '"+deviceid+"';");
                LogActivity(userid,"change controller name " + devicename);   
        }
    
        mainObj = LoadController(mainObj);
        out.print(Success(mainObj, "Controller successfully "+(approved ? "approved!" : "saved!")));

    }else if(x.equals("block_unblock_controller")){
        boolean block = Boolean.parseBoolean(request.getParameter("block"));
        String deviceid = request.getParameter("deviceid");
        
        if(block){
            ExecuteQuery("update tblcontroller set blocked=1 where deviceid = '"+deviceid+"';");
            LogActivity(userid,"blocked controller " + deviceid); 
        }else{
            ExecuteQuery("update tblcontroller set blocked=0 where deviceid = '"+deviceid+"';");
            LogActivity(userid,"unblocked controller " + deviceid); 
        }

        mainObj = LoadController(mainObj);
        out.print(Success(mainObj, "Controller successfully "+(block ? "blocked!" : "unblocked!")));

    }else if(x.equals("delete_controller")){
        String deviceid = request.getParameter("deviceid");
        
        ExecuteQuery("DELETE FROM tblcontroller where deviceid = '"+deviceid+"';");

        mainObj = LoadController(mainObj);
        out.print(Success(mainObj, "Controller successfully deleted!"));

     }else{
        out.print(Error(mainObj, globalInvalidRequest, "404"));
    }
    
}catch (Exception e){
      out.print(Error(mainObj, e.toString(), "400"));
      logError("dashboard-x-controller",e.toString());
}
%>

<%!public JSONObject LoadController(JSONObject mainObj) {
      mainObj = DBtoJson(mainObj, "controller", "select *, if(blocked,'BLOCKED',if(approved,'APPROVED','FOR APPROVAL')) as status, "
                              + " date_format(lastlogin,'%Y-%m-%d') as 'date', " 
                              + " date_format(lastlogin,'%r') as 'time' from tblcontroller");
      return mainObj;
 }
 %>
