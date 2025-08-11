<%@ include file="../module/db.jsp" %>
 
<%
    JSONObject mainObj = new JSONObject();
try{
    String x = Decrypt(request.getParameter("x"));
    String userid = request.getParameter("userid");
    String sessionid = request.getParameter("sessionid");

    if(x.isEmpty() || userid.isEmpty() || sessionid.isEmpty()){
        mainObj.put("status", "ERROR");
        mainObj.put("message","request not valid");
        mainObj.put("errorcode", "404");
        out.print(mainObj);
        return;
        
    }else if(isAdminSessionExpired(userid,sessionid)){
        mainObj.put("status", "ERROR");
        mainObj.put("message", globalExpiredSessionMessageDashboard);
        mainObj.put("errorcode", "session");
        out.print(mainObj);
        return;
    
    }else if(isAdminAccountBlocked(userid)){
        mainObj.put("status", "ERROR");
        mainObj.put("message", globalAdminAccountBlocked);
        mainObj.put("errorcode", "blocked");
        out.print(mainObj);
        return;
    }

    if(x.equals("load_promo")){
        String operatorid = request.getParameter("operatorid");

        mainObj.put("status", "OK");
        mainObj = LoadPromo(mainObj, operatorid);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("set_promo_info")){
        String mode = request.getParameter("mode");
        String promoid = request.getParameter("promoid");
        String category = request.getParameter("category");
        String operatorid = request.getParameter("operatorid");
        String sortorder = request.getParameter("sortorder");
        String title = request.getParameter("title");
        String push_message = request.getParameter("push_message");
        boolean validity = Boolean.parseBoolean(request.getParameter("validity"));
        String valid_date = request.getParameter("valid_date");
        String img_filename = request.getParameter("img_filename");
        String img_banner = request.getParameter("img_banner");
        boolean featured = Boolean.parseBoolean(request.getParameter("featured"));
        boolean visible = Boolean.parseBoolean(request.getParameter("visible"));
        boolean push = Boolean.parseBoolean(request.getParameter("push"));
        String banner_url = "";

        if(img_banner.length() > 0){
            img_filename = (img_filename.length() > 0 ? img_filename : UUID.randomUUID().toString());
            ServletContext serveapp = request.getSession().getServletContext();
            banner_url = AttachedPhoto(serveapp, "promo", img_banner, img_filename);
        }
        
        if(featured) ExecuteQuery("UPDATE tblpromo set featured=0 where operatorid='"+operatorid+"'");

        String query = "category=UCASE('"+category+"'), "
                    + " operatorid='"+operatorid+"', "
                    + " sortorder='" + sortorder + "', " 
                    + " title='" + rchar(title) + "', " 
                    + " push_message='" + rchar(push_message) + "', " 
                    + " validity="+validity+", "
                    + (valid_date.length() > 0 ? " valid_date='"+valid_date+"', " : " valid_date=null, ") 
                    + " featured="+featured+", "
                    + " visible="+visible+" ";

        if (mode.equals("add")){
            ExecuteQuery("insert into tblpromo set " + query + (img_banner.length() > 0 ? ", filename='"+img_filename+"', banner_url='"+banner_url+"' " : "") + ", addedby='"+userid+"' , datetrn=current_timestamp");
            mainObj.put("message", category + " successfully added!");
        }else{
            ExecuteQuery("UPDATE tblpromo set " + query + (img_banner.length() > 0 ? ", filename='"+img_filename+"', banner_url='"+banner_url+"' " : "") +  " where id='"+promoid+"'");
            mainObj.put("message", category + " successfully updated!");
        }
        
        if(push){
            SendBroadcastPromo(title, push_message, banner_url);
        }

        mainObj.put("status", "OK");
        mainObj = LoadPromo(mainObj, operatorid);
        out.print(mainObj);
    
    }else if(x.equals("set_promotion")){
        String mode = request.getParameter("mode");
        String promoid = request.getParameter("promoid");
        String category = request.getParameter("category");
        String operatorid = request.getParameter("operatorid");
        String sortorder = request.getParameter("sortorder");
        String filename = request.getParameter("filename");
        String title = request.getParameter("title");
        String push_message = request.getParameter("push_message"); 
        String banner_url = request.getParameter("banner_url"); 
        boolean disabled = Boolean.parseBoolean(request.getParameter("disabled"));

        String query = "category=UCASE('"+category+"'), "
                    + " operatorid='"+operatorid+"', "
                    + " sortorder='" + sortorder + "', " 
                    + " filename='" + filename + "', " 
                    + " title='" + rchar(title) + "', " 
                    + " push_message='" + rchar(push_message) + "', " 
                    + " banner_url='"+banner_url+"', "
                    + " disabled="+disabled+", "
                    + " visible=1";

        if (mode.equals("add")){
            ExecuteQuery("insert into tblpromo set " + query + ", addedby='"+userid+"', datetrn=current_timestamp");
            mainObj.put("message", category + " successfully added!");
        }else{
            ExecuteQuery("UPDATE tblpromo set " + query + " where id='"+promoid+"'");
            mainObj.put("message", category + " successfully updated!");
        }
        
        mainObj.put("status", "OK");
        mainObj = LoadPromo(mainObj, operatorid);
        out.print(mainObj);
    
    }else if(x.equals("delete_promo")){
        String operatorid = request.getParameter("operatorid");
        String promoid = request.getParameter("promoid");
        
        ExecuteQuery("DELETE FROM tblpromo where id = '"+promoid+"';");

        mainObj.put("status", "OK");
        mainObj.put("message","Promo successfully deleted!");
        mainObj = LoadPromo(mainObj, operatorid);
        out.print(mainObj);

    }else if(x.equals("push_notification")){
        String promoid = request.getParameter("promoid");
        PromoInfo promo = new PromoInfo(promoid);

        SendBroadcastPromo(promo.title, promo.push_message, promo.banner_url);

        mainObj.put("status", "OK");
        mainObj.put("message", promo.category + " successfully notified all devices!");
        out.print(mainObj);



    }else{
        mainObj.put("status", "ERROR");
        mainObj.put("message","request not valid ");
        mainObj.put("errorcode", "404");
        out.print(mainObj);
    }
}catch (Exception e){
      mainObj.put("status", "ERROR");
      mainObj.put("message", e.toString());
      mainObj.put("errorcode", "400");
      out.print(mainObj);
      logError("dashboard-x-controller",e.toString());
}
%>
 