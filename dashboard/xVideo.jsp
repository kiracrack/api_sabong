<%@ include file="../module/db.jsp" %>
 
<%
    JSONObject mainObj = new JSONObject();
    JSONObject apiObj = new JSONObject();

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

    if(x.equals("load_video")){
        mainObj = LoadVideos(mainObj);
        out.print(Success(mainObj, "Successfull Synchronized"));


    }else if(x.equals("set_video_youtube_info")){
        String mode = request.getParameter("mode");
        String videoid = request.getParameter("videoid");
        String source_name = request.getParameter("source_name");
        String source_url = request.getParameter("source_url");
    
        if (CountQry("tblvideosource", "source_name='"+source_name+"' and id<>'"+videoid+"'") > 0) {
                out.print(Error(mainObj, "Video title already exists", "100"));
                return;
                

        }else if (CountQry("tblvideosource", "source_url='"+source_url+"' and id<>'"+videoid+"'") > 0) {
                out.print(Error(mainObj, "Youtube id already exists", "100"));
                return;
        }

        if (mode.equals("add")){
                ExecuteQuery("insert into tblvideosource set source_name='"+rchar(source_name)+"', source_url='"+rchar(source_url)+"', isyoutube=1, source_working=1, player_type='YOUTUBE'");
                mainObj.put("message","Youtube video sucessfully added");
                LogActivity(userid,"added youtube video " + source_name);   
        }else{
                ExecuteQuery("UPDATE tblvideosource set source_name='"+rchar(source_name)+"', source_url='"+rchar(source_url)+"',isyoutube=1, source_working=1, player_type='YOUTUBE' where id='"+videoid+"'");
                mainObj.put("message","Youtube video sucessfully Updated");
                LogActivity(userid,"update youtube video " + source_name);   
        }
        mainObj = LoadVideos(mainObj);
        mainObj.put("status", "OK");
        out.print(mainObj);  

    }else if(x.equals("set_video_stream_info")){
        String mode = request.getParameter("mode");
        String videoid = request.getParameter("videoid");
        String source_name = request.getParameter("source_name");
        String source_url = request.getParameter("source_url");
        String player_type = request.getParameter("player_type");
        String web_url = request.getParameter("web_url");
        String web_player = request.getParameter("web_player");
        Boolean web_available = Boolean.parseBoolean(request.getParameter("web_available"));
        Boolean push_web_update = Boolean.parseBoolean(request.getParameter("push_web_update"));
        Boolean source_working = Boolean.parseBoolean(request.getParameter("source_working"));
    
        if (CountQry("tblvideosource", "source_name='"+source_name+"' and id<>'"+videoid+"' and deleted=0") > 0) {
                out.print(Error(mainObj, "Video title already exists", "100"));
                return;

        }else if (CountQry("tblvideosource", "source_url='"+source_url+"' and id<>'"+videoid+"' and deleted=0") > 0) {
                out.print(mainObj);
                out.print(Error(mainObj, "Stream URL already exists", "100"));
                return;
        }

        if (mode.equals("add")){
                ExecuteQuery("insert into tblvideosource set source_name='"+rchar(source_name)+"', source_url='"+rchar(source_url)+"', web_available=" + web_available + ", web_url='" + web_url + "', web_player='" + web_player + "', source_working="+source_working+", isyoutube=0, player_type='"+player_type+"'");
                mainObj.put("message","Stream video sucessfully added");
                LogActivity(userid,"added stream video " + source_name);   
        }else{
                ExecuteQuery("UPDATE tblvideosource set source_name='"+rchar(source_name)+"', source_url='"+rchar(source_url)+"', web_available=" + web_available + ", web_url='" + web_url + "', web_player='" + web_player + "', source_working="+source_working+", isyoutube=0, player_type='"+player_type+"' where id='"+videoid+"'");
                mainObj.put("message","Stream video sucessfully Updated");
                LogActivity(userid,"update stream video " + source_name);   
        }
        mainObj = LoadVideos(mainObj);
        mainObj.put("status", "OK");
        out.print(mainObj);  

        /*if(push_web_update){
            ActiveEventVideo event = new ActiveEventVideo(videoid);
            apiObj = controller_event_video(apiObj, event.eventid);
            PusherPost(event.eventid, apiObj);
        }*/
        
    
    }else if(x.equals("delete_video")){
        String videoid = request.getParameter("videoid");

        ExecuteQuery("UPDATE tblvideosource set deleted=1 where id='"+videoid+"'");
        LogActivity(userid,"delete video id#" + videoid);   

        mainObj = LoadVideos(mainObj);
        out.print(Success(mainObj, "Video sucessfully deleted"));
    
    }else{
        out.print(Error(mainObj, globalInvalidRequest, "404"));
    }

}catch (Exception e){
      out.print(Error(mainObj, e.toString(), "400"));
      logError("dashboard-x-video",e.toString());
}
%>

<%!public JSONObject LoadVideos(JSONObject mainObj) {
      mainObj = DBtoJson(mainObj, "video", "select *,ifnull((select 'IN-USED' from tblevent where live_sourceid=a.id and event_active=1 limit 1),'-') as inused, ucase(web_player) as w_player,ucase(web_player) as w_player, if(source_working,'YES','NO') as working, case when player_type='webview_player' then 'WEBVIEW' when player_type='video_player' then 'VIDEO' when player_type='stream_player' then 'STREAM' end as 'player' from tblvideosource as a where deleted=0 order by source_name asc");
      return mainObj;
}
%>