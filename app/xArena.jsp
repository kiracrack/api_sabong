<%@ include file="../module/db.jsp" %>

<%
    JSONObject mainObj =new JSONObject();
    JSONObject apiObj = new JSONObject();
try{

    String x = Decrypt(request.getParameter("x"));
    String appkey = request.getParameter("appkey");
    
   if(x.isEmpty() || appkey.isEmpty()){
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

    if(x.equals("arena")){ 
        mainObj = api_active_arena(mainObj);
        out.print(mainObj);
 
    }else{
        out.print(Error(mainObj, globalInvalidRequest, "404"));
        
    }

}catch (Exception e){
      out.print(Error(mainObj, e.toString(), "400"));
      logError("app-x-arena",e.toString());
}
%>

