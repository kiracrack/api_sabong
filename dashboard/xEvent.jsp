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
      
    if(x.equals("load_arena")){
        mainObj = getArenaList(mainObj);
        out.print(Success(mainObj, globaApiValidMessage));

    }else if(x.equals("set_arena_info")){
        String mode = request.getParameter("mode");
        String arenaid = request.getParameter("arenaid");
        String arenaname = request.getParameter("arenaname");
        String main_banner_url = request.getParameter("main_banner_url");
        String vertical_banner = request.getParameter("vertical_banner");
        String vertical_banner_name = request.getParameter("vertical_banner_name");
        boolean active = Boolean.parseBoolean(request.getParameter("active"));
        boolean opposite_bet = Boolean.parseBoolean(request.getParameter("opposite_bet"));
        String vertical_banner_url = "";

        if(vertical_banner.length() > 10){
            vertical_banner_name = (vertical_banner_name.length() > 0 ? vertical_banner_name : UUID.randomUUID().toString());
            ServletContext serveapp = request.getSession().getServletContext();
            vertical_banner_url = AttachedPhoto(serveapp, "arena", vertical_banner, vertical_banner_name);
        }
    
        if (mode.equals("add")){
            ExecuteQuery("insert into tblarena set arenaname='" +rchar(arenaname)+ "', active=" + active + ", opposite_bet=" + opposite_bet + ", main_banner_url='"+main_banner_url+"' " + (vertical_banner.length() > 0 ? ", vertical_banner_name='"+vertical_banner_name+"', vertical_banner_url='"+vertical_banner_url+"' " : ""));
            mainObj.put("message", " Arena successfully added!");
        }else{
            ExecuteQuery("UPDATE tblarena set arenaname='" +rchar(arenaname)+ "', active=" + active + ", opposite_bet=" + opposite_bet + ", main_banner_url='"+main_banner_url+"' " + (vertical_banner.length() > 0 ? ", vertical_banner_name='"+vertical_banner_name+"', vertical_banner_url='"+vertical_banner_url+"' " : "") + " where arenaid='"+arenaid+"'");
            mainObj.put("message", "Arena successfully updated!");
        }

        mainObj.put("status", "OK");
        mainObj = getArenaList(mainObj);
        out.print(mainObj);

    }else if(x.equals("delete_arena")){
        String arenaid = request.getParameter("arenaid");
        
        ExecuteQuery("DELETE FROM tblarena where arenaid = '"+arenaid+"';");

        mainObj = getArenaList(mainObj);
        out.print(Success(mainObj, "Arena successfully deleted!"));

    }else if(x.equals("load_event")){
        String arenaid = request.getParameter("arenaid");
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj = LoadEvents(mainObj, arenaid, datefrom, dateto);
        out.print(Success(mainObj, globaApiValidMessage));

    }else{
        out.print(Error(mainObj, globalInvalidRequest, "404"));
    }

}catch (Exception e){
      out.print(Error(mainObj, e.toString(), "400"));
      logError("dashboard-x-event",e.toString());
}
%>

<%!public JSONObject LoadEvents(JSONObject mainObj, String arenaid, String datefrom, String dateto) {
    mainObj = DBtoJson(mainObj, "event", "select *, (select arenaname from tblarena where arenaid=a.arenaid) as arena, " 
        + " case when event_active=1 then 'ACTIVE' when event_cancelled=1 then 'CANCELLED' when event_closed=1 then 'CLOSED' else 'DRAFT' end as status, "
        + " if(live_mode='YOUTUBE', live_youtube_id,live_stream_url) as live_url from tblevent as a where arenaid='"+arenaid+"' and event_date between '"+datefrom+"' and '"+dateto+"' order by event_date asc");
    return mainObj;
} %>