<%@ include file="../module/db.jsp" %>

<%
   JSONObject mainObj =new JSONObject();
try{

    String x = Decrypt(request.getParameter("x"));
    String deviceid = request.getParameter("deviceid");

    if(isControllerBlocked(deviceid)){
        out.print(Status(mainObj, "BLOCKED", "Your controller was blocked by administrator!", "403"));
        return;
    }

    if(x.equals("active_arena") || x.equals("event_list")){ 
        Double appVersion = Double.parseDouble(request.getParameter("appversion"));
        boolean request_grant = Boolean.parseBoolean(request.getParameter("request_grant"));

        if(!CheckDeviceAuthorization(deviceid)){
            if(!request_grant){
                if(!CheckRegisteredDevice(deviceid)){
                    out.print(Status(mainObj, "UNAUTHORIZED", "Your device is not authorized to use this app! Please contact your provider.", "100"));
                    return;
                }else{
                    out.print(Status(mainObj, "DEVICE_REQUESTED", "Your device authorization request is now for approval! Please reload your app controller in a few minutes", "100"));
                    return;
                }
            }else if(request_grant){
                RequestDeviceAuthorization(deviceid);
                out.print(Status(mainObj, "DEVICE_REQUESTED", "Your device authorization request is now for approval! Please reload your app controller in a few minutes", "100"));
                return;
            }
        }
        
        if(CheckAppUpdate(appVersion)){
            mainObj = getControllerUpdate(mainObj);
            out.print(Status(mainObj, "UPDATE", "A new update available! Download it now to proceed.", "100"));
            return;
        }

        String sessionid = UUID.randomUUID().toString();
        ExecuteQuery("update tblcontroller set sessionid='"+sessionid+"', lastlogin=current_timestamp where deviceid='"+deviceid+"'");
       
        mainObj = getActiveArena(mainObj);
        mainObj = getGeneralSettings(mainObj);
        mainObj = getDummySettings(mainObj);
        mainObj.put("sessionid", sessionid);
        out.print(Success(mainObj, "request returned valid"));
 
    }else{
        out.print(Error(mainObj, globalInvalidRequest, "404"));
        
    }
}catch (Exception e){
      out.print(Error(mainObj, e.toString(), "400"));
      logError("controller-x-game",e.toString());
}
%>

<%!public boolean CheckDeviceAuthorization(String deviceid) {
     return CountQry("tblcontroller", "deviceid='"+deviceid+"' and approved=1") > 0;
  }
 %>

  <%!public boolean CheckRegisteredDevice(String deviceid) {
    return CountQry("tblcontroller", "deviceid='"+deviceid+"'") > 0;
  }
 %>

 <%!public boolean CheckAppUpdate(Double appVersion) {
    return CountQry("tblversioncontrol", "controllerversion>" + appVersion + "") > 0;
  }
 %>

  <%!public boolean RequestDeviceAuthorization(String deviceid) {
    if(CountQry("tblcontroller", "deviceid='"+deviceid+"'") == 0){
        ExecuteQuery("insert into tblcontroller set deviceid='"+deviceid+"', lastlogin=current_timestamp");
        return true;
    }else{
        return false;
    }
  }
 %>
 