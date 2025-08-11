
<%!public boolean isPromotionEnabled(String filename) {
    return CountQry("tblpromo", "filename='" + filename + "' and disabled=0") > 0;
  }
 %>
 
 <%!public String getAccountid(String mobilenumber) {
    return QueryDirectData("accountid","tblsubscriber where mobilenumber='"+mobilenumber+"'");
 }
 %>

<%!public String getAccountid(String username, String password) {
    return QueryDirectData("accountid","tblsubscriber where username='"+username+"' and password=AES_ENCRYPT('"+password.replace("'","")+"', '"+globalPassKey+"')");
 }
 %>

<%!public String getOperatorid(String userid) {
   return QueryDirectData("operatorid", "tblsubscriber where accountid='"+userid+"'");
 }
 %>

 <%!public boolean isAppkeyFound(String appkey) {
    return CountQry("tblapplication", "appkey='" + appkey + "'") > 0;
  }
 %>

 <%!public boolean isAppkeyEnabled(String appkey) {
    return CountQry("tblapplication", "appkey='" + appkey + "' and enabled=1") > 0;
  }
 %>

<%!public boolean isAccountExist(String accountid) {
    return CountQry("tblsubscriber", "accountid='"+accountid+"'") > 0;
  }
%>

<%!public boolean isSessionExpired(String userid, String sessionid) {
    return CountQry("tblsubscriber", "accountid='" + userid + "' and sessionid='"+sessionid+"'") == 0;
  }
 %>

 <%!public boolean isAllowedMultiSession(String userid) {
    return CountQry("tblmultisession", "accountid='" + userid + "'") > 0;
  }
 %>

<%!public boolean isAdminSessionExpired(String userid, String sessionid) {
    return CountQry("tbladminaccounts", "id='" + userid + "' and sessionid='"+sessionid+"'") == 0;
  }
 %>

<%!public boolean isAdminAccountBlocked(String userid) {
    return CountQry("tbladminaccounts", "(id='" + userid + "' or username='" + rchar(userid) + "') and blocked=1") > 0;
  }
 %>

<%!public String getMasterAgentid(String userid) {
   return QueryDirectData("masteragentid", "tblsubscriber where accountid='"+userid+"'");
 }
 %>

<%!public String getAccountName(String userid) {
   return QueryDirectData("displayname", "tblsubscriber where accountid='"+userid+"'");
 }
 %>

 <%!public String getFullname(String userid) {
   return QueryDirectData("fullname", "tblsubscriber where accountid='"+userid+"'");
 }
 %>

 <%!public String getAgentID(String userid) {
   return QueryDirectData("agentid", "tblsubscriber where accountid='"+userid+"'");
 }
 %>

<%!public String getLatestCreditBalance(String userid) {
   return QueryDirectData("creditbal", "tblsubscriber where accountid='"+userid+"'");
 }
 %>

<%!public boolean isBalanceAvailable(String userid) {
   return CountQry("tblsubscriber", "accountid='"+userid+"' and creditbal > 1 ") > 0;
 }
 %>

<%!public boolean isProfileConfirmed(String userid) {
    return CountQry("tblsubscriber","accountid='"+userid+"' and confirmed=1") > 0;
 }
 %>

<%!public boolean isControllerRemoved(String deviceid) {
    return CountQry("tblcontroller", "deviceid='"+deviceid+"'") == 0;
 }
 %>

<%!public boolean isControllerBlocked(String deviceid) {
    return CountQry("tblcontroller", "deviceid='"+deviceid+"' and blocked=1") > 0;
 }
 %>

 <%!public boolean isBankAccountExist(String userid) {
    return CountQry("tblbankaccounts", "accountid='"+userid+"' and deleted=0") > 0;
  }
%>

 <%!public boolean isTherePendingDeposit(String userid) {
    return CountQry("tbldeposits", "accountid='"+userid+"' and confirmed=0 and cancelled=0") > 0;
  }
%>

<%!public boolean isDepositAlreadyConfirmed(String userid, String refno) {
    return CountQry("tbldeposits", "accountid='"+userid+"' and refno='"+refno+"' and confirmed=1 and cancelled=0") > 0;
  }
%>

<%!public boolean isTherePendingWithdrawal(String userid) {
    return CountQry("tblwithdrawal", "accountid='"+userid+"' and confirmed=0 and cancelled=0") > 0;
  }
%>

<%!public boolean isBonusExists(String userid, String bonuscode) {
    return CountQry("tblbonus", "accountid='"+userid+"' and bonuscode='"+bonuscode+"'") > 0;
 }
 %>

 <%!public boolean isBonusExistsByDate(String userid, String bonuscode, String bonusdate) {
    return CountQry("tblbonus", "accountid='"+userid+"' and bonuscode='"+bonuscode+"' and bonusdate='"+bonusdate+"'") > 0;
 }
 %>
 
 <%!public boolean isBonusExistsByReference(String userid, String bonuscode, String appreference) {
    return CountQry("tblbonus", "accountid='"+userid+"' and bonuscode='"+bonuscode+"' and appreference='"+appreference+"'") > 0;
 }
 %>

 <%!public boolean isRebateIsValid(String userid) {
    return CountQry("tblsubscriber", "accountid='"+userid+"' and rebate_claim_date >= current_date and rebate_enabled=0 and totaldeposit > 0") > 0;
 }
 %>

<%!public boolean isMasterAgentDisplayOperatorBank(String masteragentid) {
    return CountQry("tblsubscriber", "accountid='"+masteragentid+"' and displayoperatorbank=1") > 0;
  }
%>

<%!public boolean isAgentDisplayOperatorBank(String agentid) {
    return CountQry("tblsubscriber", "accountid='"+agentid+"' and displayoperatorbank=1") > 0;
  }
%>

<%!public int CountWinstrike(String category, String accountid, String eventid) {
    return CountQry("tblfightwinstrike", "category='"+category+"' and accountid='" + accountid + "' and eventid='"+eventid+"' and (result<>'C' and result<>'D')");
  }
 %>