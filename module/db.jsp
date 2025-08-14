<%@ page trimDirectiveWhitespaces="true" %>
<%@ page import="java.io.*,java.sql.*,java.util.*,java.text.*,javax.mail.*,java.text.SimpleDateFormat,java.net.URL,java.sql.Timestamp,java.util.Date" %>
<%@ page language="java" contentType="application/json;charset=UTF-8" %>
<%@ page import="org.json.simple.JSONArray"%>
<%@ page import="org.json.simple.JSONObject"%>
<%@ page import="org.json.simple.parser.JSONParser"%>
<%@ page import="org.json.simple.parser.ParseException"%>
<%@ page import="org.apache.catalina.tribes.util.Arrays"%>
<%@ page import="org.apache.commons.lang3.RandomStringUtils"%>
<%@ page import="org.apache.commons.io.FileUtils" %>
<%@ page import="java.security.GeneralSecurityException" %>
<%@ page import="javax.crypto.Cipher" %>
<%@ page import="javax.crypto.spec.IvParameterSpec" %>
<%@ page import="javax.crypto.spec.SecretKeySpec" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="java.net.HttpURLConnection" %>
<%@ page import="java.net.URLConnection" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.net.URL" %>
<%@ page import="java.util.regex.Matcher" %>
<%@ page import="java.util.regex.Pattern" %>
<%@ page import="java.util.concurrent.TimeUnit" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@page pageEncoding="UTF-8"%>
 
<%@ page import="com.pusher.rest.Pusher" %>
<%@ page import="javax.mail.internet.*,javax.activation.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
<%@ page import="javax.xml.bind.DatatypeConverter" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="java.util.SortedMap" %>
<%@ page import="java.util.stream.Collectors" %>

<%@ page import="connection.*" %>
<%@ include file="xLibrary.jsp" %>
<%@ include file="xSecurity.jsp" %>
<%@ include file="xFormatting.jsp" %>
<%@ include file="xRecordClass.jsp" %>
<%@ include file="xDatabaseClass.jsp" %>
<%@ include file="xRecordModule.jsp" %>
<%@ include file="xRecordQuery.jsp" %>

<%!
public String GlobalHostName = "";

public String GlobalEnvironment = "";
public String GlobalDefaultOperator = "";
public double GlobalPlasada = 0;

public String globalInvalidRequest = "Invalid request command code";
public String globalMaintainanceMessage = "Server is currently undergoing maintenance. please try again later";
public String globalExpiredSessionMessage = "System detected new device login! Your session from this device will be disconnected. <br><br> If this wasn't you, or if you believe that an unauthorized person has accessed your account, please reset your password right away.";

public String globalExpiredSessionMessageDashboard = "System detected new device login! Your session from this device will be disconnected.";
public String globalAdminAccountBlocked = "Your account was blocked! Please contact admin operator";

public String GlobalDatetrn = "";
public String GlobalDate = "";
public String GlobalTime = "";
public boolean globalMaintenance = false;
%>

<%
try{
	//ExecuteQuery("SET time_zone = '+08:00'");
	ResultSet rs = null;  
	rs =  SelectQuery("select *, DATE_FORMAT(CURRENT_TIMESTAMP, '%m/%d/%Y') as date_today, " 
					+ " DATE_FORMAT(CURRENT_TIMESTAMP, '%r') as time_today, " 
					+ " date_format(current_timestamp, '%M %d, %y %r') as datetrn from tblgeneralsettings");
	while(rs.next()){
		globalMaintenance = rs.getBoolean("maintenance");
		GlobalEnvironment = rs.getString("environment");
		GlobalPlasada = rs.getDouble("plasada");
         
		GlobalDatetrn = rs.getString("datetrn");
		GlobalDate = rs.getString("date_today");
		GlobalTime = rs.getString("time_today");

		GlobalHostName = "https://" + request.getServerName();
	}
	rs.close();

}catch(SQLException e){
	logError("db-sql-exception", e.toString());
}catch(Exception e){
	logError("db-runtime-exception", e.toString());
	throw e;
}
%>