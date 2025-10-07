 
<%!public JSONObject DBtoJson(JSONObject mainObj, String param, String query) {
    try {
          JSONArray ja =new JSONArray();
          ResultSet rst = null;  
		  rst =  SelectQuery(query); 
          while(rst.next()){
            JSONObject obj =new JSONObject();
            ResultSetMetaData columns = rst.getMetaData();
            for (int i = 1; i < columns.getColumnCount() + 1; i++) {
                if(!columns.getColumnLabel(i).equals("password")){
                    if(columns.getColumnType(i) == -7){
                        obj.put(columns.getColumnLabel(i), rst.getBoolean(columns.getColumnLabel(i)));
                    }else if(columns.getColumnType(i) == 8  || columns.getColumnType(i) == -5){
                        obj.put(columns.getColumnLabel(i), rst.getDouble(columns.getColumnLabel(i)));
                    }else{
                        String data = rst.getString(columns.getColumnLabel(i)); if(data == null){ data = "";}
                        if(data.equals("true") || data.equals("false")){
                            obj.put(columns.getColumnLabel(i), rst.getBoolean(columns.getColumnLabel(i)));
                        }else{
                            obj.put(columns.getColumnLabel(i), rst.getString(columns.getColumnLabel(i)));
                        }
                    }
                }
            }
            ja.add(obj);
        }
        rst.close();
        mainObj.put(param, ja);
  }catch(SQLException e){
        logError("DBtoJson_sql1",e.toString());
  }catch(Exception e){
      logError("DBtoJson1",e.toString());
  }
  return mainObj;
  }
 %>

 <%!public JSONObject DBtoJson(JSONObject mainObj, String query) {
    try {
          ResultSet rst = null;  
		  rst =  SelectQuery(query);
          while(rst.next()){
            ResultSetMetaData columns = rst.getMetaData();
            for (int i = 1; i < columns.getColumnCount() + 1; i++) {
                if(columns.getColumnType(i) == -7){
                    mainObj.put(columns.getColumnLabel(i), rst.getBoolean(columns.getColumnLabel(i)));
                }else if(columns.getColumnType(i) == 8 ||  columns.getColumnType(i) == -5){
                    mainObj.put(columns.getColumnLabel(i), rst.getDouble(columns.getColumnLabel(i)));
                }else{
                    String data = rst.getString(columns.getColumnLabel(i)); if(data == null){ data = "";}
                    if(data.equals("true") || data.equals("false")){
                        mainObj.put(columns.getColumnLabel(i), rst.getBoolean(columns.getColumnLabel(i)));
                    }else{
                        mainObj.put(columns.getColumnLabel(i), rst.getString(columns.getColumnLabel(i)));
                    }
                }
            }
        }
        rst.close();
  }catch(SQLException e){
        logError("DBtoJson_sql2",e.toString());
  }catch(Exception e){
      logError("DBtoJson2",e.toString());
  }
  return mainObj;
  }
 %>
 
<%!public String getRandomAlphaNumeric() {
    Random rnd = new Random();
    int number = rnd.nextInt(999999);
    return String.format("%06d", number);
}
%>

<%!public String RemovedStr(String htmlString){	
	 	htmlString = htmlString.replaceAll("qwertyuiopasdfghjklzxcvbnm", "");
	 	return htmlString;
}
%>

<%!public String getSystemSeriesID(String columnname) {
   	int newid = 0; 
    try{
        ResultSet rst_db = null;  
        rst_db =  SelectQuery("select "+columnname+" from tblgeneralsettings");
        while(rst_db.next()){
            newid  = rst_db.getInt(columnname)+1;
            ExecuteQuery("update tblgeneralsettings set "+columnname+"="+newid);			
        }
        rst_db.close();
    }catch(SQLException e){
		logError("getSystemSeriesID",e.toString());
	}
    return String.format("%03d", newid);
}
%>
<%!public String getSystemSeriesID(String columnname, int lenght) {
   	int newid = 0; 
    try{
        ResultSet rst_db = null;  
        rst_db =  SelectQuery("select "+columnname+" from tblgeneralsettings");
        while(rst_db.next()){
            newid  = rst_db.getInt(columnname)+1;
            ExecuteQuery("update tblgeneralsettings set "+columnname+"="+newid);			
        }
        rst_db.close();
    }catch(SQLException e){
		logError("getSystemSeriesID",e.toString());
	}
    return String.format("%0"+lenght+"d", newid);
}
%>

<%!public String getOperatorAccount(String operatorid, String columnname) {
   	int newid = 0; 
    try{
        ResultSet rst_db = null;  
        rst_db =  SelectQuery("select "+columnname+" from tbloperator where companyid='"+operatorid+"'");
        while(rst_db.next()){
                newid  = rst_db.getInt(columnname)+1;
                ExecuteQuery("update tbloperator set "+columnname+"="+newid+" where companyid='"+operatorid+"'");			
        }
        rst_db.close();
    }catch(SQLException e){
		logError("getSystemSeriesID",e.toString());
	}
    return operatorid + "-" + String.format("%05d", newid);
}
%>
 

<%!public String AttachedPhoto(ServletContext application, String folder, String imageString, String filename) {
     String PhotoUrl = "";
    if(imageString.length() > 0) {
        String directory = application.getRealPath("/images/"+folder+"");
        File theDir = new File(directory);
        if (!theDir.exists()){
            theDir.mkdirs();
        }
        
        String PhotoLocation = directory + "/"+filename+".png";
        PhotoUrl = GlobalHostName + "/images/"+folder+"/"+filename+".png";
        byte[] data = DatatypeConverter.parseBase64Binary(imageString);
        File file= new File(PhotoLocation);
        
        try (OutputStream outputStream = new BufferedOutputStream(new FileOutputStream(file))) {
            outputStream.write(data);
        } catch (IOException e) {
            e.printStackTrace();
            PhotoUrl = "";
        }
    }else{
         PhotoUrl = "";
    }
    return PhotoUrl;
}
%>

<%!public String AttachedImage(ServletContext application, String imageString, String filename) {
     String PhotoUrl = "";
    if(imageString.length() > 0) {
        String directory = application.getRealPath("/media/");
        File theDir = new File(directory);
        if (!theDir.exists()){
            theDir.mkdirs();
        }
        
        String PhotoLocation = directory + "/" + filename;
        PhotoUrl = GlobalHostName + "/media/"+filename;
        byte[] data = DatatypeConverter.parseBase64Binary(imageString);
        File file= new File(PhotoLocation);
        
        try (OutputStream outputStream = new BufferedOutputStream(new FileOutputStream(file))) {
            outputStream.write(data);
        } catch (IOException e) {
            e.printStackTrace();
            PhotoUrl = "";
        }
    }else{
         PhotoUrl = "";
    }
    return PhotoUrl;
}
%>

<%!public void DeleteImage(ServletContext application, String filename) {
    String imgfile = application.getRealPath("/media/" + filename);
    File theFile = new File(imgfile);
    if(theFile.exists()) theFile.delete();
}
%>

<%!public void LogActivity(String userid, String details) {
    ExecuteQuery("insert into tblactivitylogs set datetrn=current_timestamp, userid='"+userid+"',details=lcase('"+rchar(details.toString())+"')");
}
%>

 <%!public String CurrentMonth(){
    LocalDateTime myDateObj = LocalDateTime.now();
    DateTimeFormatter myFormatObj = DateTimeFormatter.ofPattern("yyyy-MM");
    return myDateObj.format(myFormatObj);
  }
%>

<%!public JSONObject Success(JSONObject mainObj, String message) {
    mainObj.put("status", "OK");
    mainObj.put("message", message); 
    return mainObj;
 }
 %>

 <%!public JSONObject Error(JSONObject mainObj, String message, String errorcode) {
    mainObj.put("status", "ERROR");
    mainObj.put("message", message);
    mainObj.put("errorcode", errorcode);
    return mainObj;
 }
 %>

 <%!public JSONObject Status(JSONObject mainObj, String Status, String message, String errorcode) {
    mainObj.put("status", Status);
    mainObj.put("message", message); 
    mainObj.put("errorcode", errorcode); 
    return mainObj;
 }
 %>