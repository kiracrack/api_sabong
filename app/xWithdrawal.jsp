<%@ include file="../module/db.jsp" %>

<%
   JSONObject mainObj =new JSONObject();
try{

    String x = Decrypt(request.getParameter("x"));
    String userid = request.getParameter("userid");
    String appkey = request.getParameter("appkey");
    String sessionid = request.getParameter("sessionid");
 
    if(x.isEmpty() || userid.isEmpty() || appkey.isEmpty() || (sessionid.isEmpty() && !isAllowedMultiSession(userid))){
        mainObj = ErrorResponse(mainObj, "request not valid", "404");
        out.print(mainObj);
        return;

    }else if(globalEnableMaintainance){
        mainObj = ErrorResponse(mainObj, globalMaintainanceMessage, "maintenance");
        out.print(mainObj);
        return;

    }else if(!isAppkeyFound(appkey)){
        mainObj = ErrorResponse(mainObj, "app access is not allowed", "session");
		out.print(mainObj);
        return;

    }else if(!isAppkeyEnabled(appkey)){
        mainObj = ErrorResponse(mainObj, "your application is disabled", "session");
		out.print(mainObj);
        return;

    }else if(isSessionExpired(userid,sessionid)){
        mainObj = ErrorResponse(mainObj, globalExpiredSessionMessage, "session");
		out.print(mainObj);
        return;
    }

    if(x.equals("withdrawal_report")){
        String keyword = request.getParameter("keyword");

        String search = " and (" +
                    " accountid like '%" + rchar(keyword) + "%' or " +
                    " accountno like '%" + rchar(keyword) + "%' or " +
                    " accountname like '%" + rchar(keyword) + "%' or " +
                    " note like '%" + rchar(keyword) + "%' or " +
                    " (select bankname from tblbanks where id=a.bankid) like '%" + rchar(keyword) + "%'" +
                    ")";

        mainObj = withdrawal_report(mainObj, userid, search);
        mainObj.put("status", "OK");
        mainObj.put("message","Result synchronized");
        out.print(mainObj);
        
    }else if(x.equals("withdrawal_request")){
        String keyword = request.getParameter("keyword");

       String search = " and (" +
                    " accountid like '%" + rchar(keyword) + "%' or " +
                    " accountno like '%" + rchar(keyword) + "%' or " +
                    " accountname like '%" + rchar(keyword) + "%' or " +
                    " note like '%" + rchar(keyword) + "%' or " +
                    " (select bankname from tblbanks where id=a.bankid) like '%" + rchar(keyword) + "%'" +
                    ")";

        mainObj.put("status", "OK");
        mainObj = withdrawal_request(mainObj, userid, search);
        mainObj = getTotalBankingNotification(mainObj);
        mainObj.put("message","Result synchronized");
        out.print(mainObj);

    }else if(x.equals("new_withdrawal")){
        /*if(isTherePendingWithdrawal(userid)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You have already a pending withdrawal! We only allow one withdrawal at a time");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
        }*/

        mainObj.put("status", "OK");
        mainObj = api_bank_account(mainObj, userid); 
        mainObj = api_account_info(mainObj, userid, false); 
    
        mainObj.put("message", "data synchronized");
        out.print(mainObj); 
        
    }else if(x.equals("query_withdrawal")){
        String refno = request.getParameter("refno");
        
        mainObj = api_query_withdrawal(mainObj, refno);
        mainObj.put("status", "OK");
        mainObj.put("message","Result synchronized");
        out.print(mainObj);
        
    }else if(x.equals("create_withdrawal")){
        String bid = request.getParameter("bid");
        String note = request.getParameter("note");
        double amount = Double.parseDouble(CC(request.getParameter("amount")));
        double cashout = Double.parseDouble(CC(request.getParameter("cashout")));
        String appreference = request.getParameter("appreference");
       
        if(CountQry("tblsubscriber", "accountid='"+userid+"' and creditbal < "+amount+"") > 0){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Amount must be not more than account balance");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;
        
         }else if(CountQry("tblbankaccounts", "id='"+bid+"' and deleted=0") == 0){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Bank account not found!");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;

        }else if(isTherePendingWithdrawal(userid)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You have already a pending withdrawal! We only allow one withdrawal at a time");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;

        }

        AccountInfo info = new AccountInfo(userid);

        BankInfo bank = new BankInfo(bid);
        RemitInfo remit = new RemitInfo(bank.remittanceid);
        
        String refno = getOperatorSeriesID(info.operatorid,"series_withdrawal");  
        if(info.iscashaccount) LogLedger(userid, sessionid, appreference, refno, "withdraw score",amount, 0, userid);

        ExecuteQuery("insert into tblwithdrawal set refno='"+refno+"', "
                        + " accountid='"+userid+"', "
                        + " agentid='"+agentid+"', "
                        + " operatorid='"+info.operatorid+"', "
                        + " isbank="+remit.isbank+", "
                        + " remittanceid='"+bank.remittanceid+"', "
                        + " accountno='"+bank.accountnumber+"', "
                        + " accountname='"+rchar(bank.accountname)+"', "
                        + " note='"+rchar(note)+"', "
                        + " amount='"+amount+"', "
                        + " deducted="+ (amount != cashout) +", "
                        + " cashout='"+cashout+"', "
                        + " datetrn=current_timestamp");

        SendNewWithdrawalNotification(refno, agentid, userid, FormatCurrency(String.valueOf(cashout)));

        mainObj.put("status", "OK");
        mainObj = withdrawal_request(mainObj, userid, "", GlobalRecordsLimit);
        mainObj.put("creditbal", getLatestCreditBalance(userid));
        mainObj.put("message","Your withdrawal successfully posted! Please wait 1-15 minutes while we are processing your request.");
        out.print(mainObj);
        

    }else if(x.equals("confirm_withdrawal")){
        String refno = request.getParameter("refno");
        String accountid = request.getParameter("accountid");
        String imgbase64 = request.getParameter("receipt");
        String appreference = request.getParameter("appreference");
        String fullname = getAccountName(accountid);

        WithdrawalInfo info = new WithdrawalInfo(refno);
        if(info.iscashaccount){
            if(CountQry("tblsubscriber", "accountid='"+userid+"' and creditbal < "+info.amount+"") > 0){
                mainObj.put("status", "ERROR");
                mainObj.put("message","Insufficient credit balance! credit already used");
                mainObj.put("errorcode", "100");
                out.print(mainObj);
                return;
            }
            LogLedger(userid, sessionid, appreference, refno, "approved " +FirstName(fullname)+ " withdrawal", 0, info.amount, userid);
        }

        ServletContext serveapp = request.getSession().getServletContext();
        String url = AttachedReceipt(serveapp, "receipt/withdrawal", imgbase64, refno);

        ExecuteQuery("UPDATE tblwithdrawal set confirmed=1,dateconfirm=current_timestamp,attachment='"+url+"' where refno='"+refno+"' and accountid='"+accountid+"'");
        SendRequestNotificationCount(userid);
        SendBankingNotification(refno, accountid, "withdrawal", "Good News!", "Your withdrawal was approved by your agent! Congratulation..", (info.cashout > 0 ? info.cashout : info.amount));

        mainObj.put("status", "OK");
        mainObj.put("creditbal", getLatestCreditBalance(userid));
        mainObj = api_query_withdrawal(mainObj, refno);
        mainObj = withdrawal_request(mainObj, userid, " and refno='"+refno+"' ", GlobalRecordsLimit);
        mainObj = getTotalBankingNotification(mainObj);
        mainObj.put("message","Downline withdrawal successfully confirmed!");
        out.print(mainObj);
        
    }else if(x.equals("cancel_withdrawal")){
        String refno = request.getParameter("refno");
        String accountid = request.getParameter("accountid");
        String reason = request.getParameter("reason");
        String appreference = request.getParameter("appreference");

        if(CountQry("tblwithdrawal", "refno='"+refno+"' and confirmed=1 and cancelled=0") > 0){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Sorry! withdrawal is already approved");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;

        }else if(CountQry("tblwithdrawal", "refno='"+refno+"' and cancelled=1") > 0){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Sorry! withdrawal is already cancelled");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;
        }

        WithdrawalInfo info = new WithdrawalInfo(refno);
        if(info.iscashaccount){
            LogLedger(info.accountid, sessionid, appreference, refno, "cancelled withdrawal",0, info.amount, info.accountid);
        }

        ExecuteQuery("UPDATE tblwithdrawal set cancelled=1,datecancelled=current_timestamp,cancelledreason='"+rchar(reason)+"' where refno='"+refno+"' and accountid='"+accountid+"'");
        SendRequestNotificationCount(userid);
        SendBankingNotification(refno, accountid, "withdrawal", "Ohhh no!", "Your withdrawal was cancelled by your agent", info.amount);
        
        mainObj.put("status", "OK");
        mainObj = api_query_withdrawal(mainObj, refno);
        mainObj = withdrawal_request(mainObj, userid, " and refno='"+refno+"' ", GlobalRecordsLimit);
        mainObj = getTotalBankingNotification(mainObj);
        mainObj.put("message","Downline withdrawal successfully cancelled!");
        out.print(mainObj);
        
    }else{
        mainObj.put("status", "ERROR");
        mainObj.put("message","request not valid");
        mainObj.put("errorcode", "404");
        out.print(mainObj);
    }
}catch (Exception e){
      mainObj.put("status", "ERROR");
      mainObj.put("message", e.toString());
      mainObj.put("errorcode", "400");
      out.print(mainObj);
      logError("app-x-withdrawal",e.getMessage());
}
%>

 <%!public JSONObject withdrawal_report(JSONObject mainObj,String userid,String search) {
      mainObj = DBtoJson(mainObj, "withdrawal_report", sqlWithdrawalQuery + " where accountid='" + userid + "' " + search + " order by id desc");
      return mainObj;
 }
 %>

 <%!public JSONObject withdrawal_request(JSONObject mainObj, String status, String search) {
      String stat_query = BankingStatus(status);
      mainObj = DBtoJson(mainObj, "withdrawal_request", sqlWithdrawalQuery + "  where " + stat_query + search + " order by id desc limit 50 ");
      return mainObj;
 }
 %>

