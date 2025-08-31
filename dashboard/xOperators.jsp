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

    if(x.equals("load_operator")){
        mainObj = getOperators(mainObj);
        mainObj = getSelectOperator(mainObj);
        out.print(Success(mainObj, globaApiValidMessage));
    
    }else if(x.equals("select_operator")){
        mainObj = getSelectOperator(mainObj);
        out.print(Success(mainObj, globaApiValidMessage));

    }else if(x.equals("set_operator_info")){
        String mode = request.getParameter("mode");
        String appkey = request.getParameter("appkey");
        String companyid = request.getParameter("companyid");
        String companyname = request.getParameter("companyname");
        String shortname = request.getParameter("shortname");
        String website = request.getParameter("website");
        String email = request.getParameter("email");
        String whatsapp = request.getParameter("whatsapp");
        String messenger = request.getParameter("messenger");
        boolean active = Boolean.parseBoolean(request.getParameter("active"));

        if (CountQry("tbloperator", "companyname='"+companyname+"'  and companyid<>'"+companyid+"'") > 0) {
            out.print(Error(mainObj, "Operator already exists", "100"));
            return;
        }
        
        String query = "appkey='"+appkey+"', "
                    + " companyname='"+rchar(companyname)+"', "
                    + " shortname='"+rchar(shortname)+"', "
                    + " website='"+rchar(website)+"', "
                    + " email='"+rchar(email)+"', "
                    + " whatsapp='"+whatsapp+"', " 
                    + " messenger='"+messenger+"', "
                    + " actived="+active+"";

        if (mode.equals("add")){
            String id = getSystemSeriesID("series_operator");
            ExecuteQuery("insert into tbloperator set companyid='"+id+"', " + query);
            mainObj.put("message","Operator Sucessfully Added");
            LogActivity(userid,"added operator's name " + companyname);   
        }else{
            ExecuteQuery("UPDATE tbloperator set " + query + " where companyid='"+companyid+"'");
            mainObj.put("message","Operator Sucessfully Updated");
            LogActivity(userid,"update operator's " + companyname + " information");   
        }
        mainObj = getOperators(mainObj);
        mainObj.put("status", "OK");
        out.print(mainObj);    
        
    } else if(x.equals("block_operator")){
        String companyid = request.getParameter("companyid");
        String companyname = request.getParameter("companyname");
        String reason = request.getParameter("reason");

        ExecuteQuery("update tbloperator set actived=0, blocked=1, blockedreason='"+rchar(reason)+"',dateblocked=current_timestamp where companyid = '"+companyid+"';");
        LogActivity(userid,"blocked operator " + companyname + "");   

        mainObj = getOperators(mainObj);
        out.print(Success(mainObj, "Operator successfully blocked"));

    }else if(x.equals("unblock_operator")){
        String companyid = request.getParameter("companyid");
        String companyname = request.getParameter("companyname");
        
        ExecuteQuery("update tbloperator set blocked=0, blockedreason='',dateblocked=null where companyid = '"+companyid+"';");
        LogActivity(userid,"unblocked operator " + companyname + "");   

        mainObj = getOperators(mainObj);
        out.print(Success(mainObj, "Operator successfully unblocked"));
 
    }else{
        out.print(Error(mainObj, globalInvalidRequest, "404"));
    }

}catch (Exception e){
      out.print(Error(mainObj, e.toString(), "400"));
      logError("dashboard-x-operator",e.toString());
}
%>