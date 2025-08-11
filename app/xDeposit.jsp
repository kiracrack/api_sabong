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

    if(x.equals("deposit_report")){
        String keyword = request.getParameter("keyword");
 
        String search = " and (" +
                    " refno like '%" + rchar(keyword) + "%' or " +
                    " accountid like '%" + rchar(keyword) + "%' or " +
                    " accountname like '%" + rchar(keyword) + "%' or " +
                    " note like '%" + rchar(keyword) + "%' or " +
                    " referenceno like '%" + rchar(keyword) + "%')";

        mainObj = deposit_report(mainObj, userid, search);
        mainObj.put("status", "OK");
        mainObj.put("message","Result synchronized");
        out.print(mainObj);

    }else if(x.equals("deposit_request")){
        String keyword = request.getParameter("keyword"); 
        String status = request.getParameter("status");

        AccountInfo info = new AccountInfo(userid);
        if(!info.masteragent){
            mainObj = ErrorResponse(mainObj, "Your access is not allowed!", "403");
            out.print(mainObj);
            return;
        }

        String search = " and (" +
                    " refno like '%" + rchar(keyword) + "%' or " +
                    " accountid like '%" + rchar(keyword) + "%' or " +
                    " accountname like '%" + rchar(keyword) + "%' or " +
                    " note like '%" + rchar(keyword) + "%' or " +
                    " referenceno like '%" + rchar(keyword) + "%')";
        
        mainObj.put("status", "OK");
        mainObj = deposit_request(mainObj, status, search);
        mainObj = getTotalBankingNotification(mainObj);
        mainObj.put("message","Result synchronized");
        out.print(mainObj);
    
    }else if(x.equals("new_deposit")){        
        /*if(!isBankAccountExist(userid)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Please create bank account first");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;

        }else */
        
        if(isTherePendingDeposit(userid)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You have already a pending deposit! Multiple deposits is not allowed");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
        }

        mainObj.put("status", "OK");
        mainObj = api_telco_list(mainObj);
        mainObj = api_operator_bank(mainObj);
        mainObj = api_account_info(mainObj, userid, false);  
        mainObj.put("message","Result synchronized");
        out.print(mainObj);


    }else if(x.equals("query_deposit")){
        String refno = request.getParameter("refno");
        
        mainObj = api_query_deposit(mainObj, refno);
        mainObj.put("status", "OK");
        mainObj.put("message","Result synchronized");
        out.print(mainObj);

    }else if(x.equals("create_deposit")){
        String appreference = request.getParameter("appreference");
        String deposit_type = request.getParameter("deposit_type");
        String bankcode = request.getParameter("bankcode");
        String sender_name = request.getParameter("sender_name");
        String date_deposit = request.getParameter("date_deposit");
        String time_deposit = request.getParameter("time_deposit");
        String amount = request.getParameter("amount");
        String referenceno = request.getParameter("referenceno");
        String note = request.getParameter("note");
        AccountInfo info = new AccountInfo(userid);
        
        /*if(isTherePendingDeposit(userid)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You have already a pending deposit! Multiple deposits is not allowed");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
        }*/

        String imgbase64 = request.getParameter("receipt");
        ServletContext serveapp = request.getSession().getServletContext();

        String refno = getOperatorSeriesID(info.operatorid,"series_deposit");  
        String url = AttachedReceipt(serveapp, "receipt/deposit", imgbase64, refno);
        
        OperatorBankInfo ops = new OperatorBankInfo(bankcode);
        if(!isLogLedgerFound(userid, sessionid, appreference, "making deposit", 0, Double.parseDouble(amount), userid)){
            LogLedgerTransaction(userid, sessionid, appreference, "making deposit", 0, Double.parseDouble(amount), userid);

            ExecuteQuery("insert into tbldeposits set refno='"+refno+"', "
                        + " accountid='"+userid+"', "
                        + " bankcode='"+bankcode+"', "
                        + " operatorid='"+info.operatorid+"', "
                        + " bankid='"+ops.bankid+"', "
                        + " agentid='"+info.agentid+"', "
                        + " deposit_type='"+deposit_type+"', "
                        + " sender_name='"+rchar(sender_name)+"', "
                        + " date_deposit='"+date_deposit+"', "
                        + " time_deposit='"+time_deposit+":00', "
                        + " amount='"+amount+"', "
                        + " referenceno='"+referenceno+"', "
                        + " note='"+rchar(note)+"', "
                        + " datetrn=current_timestamp, " 
                        + " attachment='"+url+"'");
            SendNewDepositNotification(refno, info.agentid, userid, FormatCurrency(amount));
        }
        
        mainObj.put("status", "OK");
        mainObj = deposit_report(mainObj, userid, "");
        mainObj.put("message","Your deposit successfully posted! Please wait 1-15 minutes while we are processing your request. Your deposit reference no. is " + refno);
        out.print(mainObj);
 
    }else if(x.equals("approve_deposit")){
        String refno = request.getParameter("refno");
        String accountid = request.getParameter("accountid");
        String appreference = request.getParameter("appreference");

        if(isDepositAlreadyConfirmed(userid, refno)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Deposit already confirmed!");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
        }

        DepositInfo dep = new DepositInfo(refno);
        
        //log ledger sender
        Boolean sent = LogLedger(userid, sessionid, appreference, refno,"approved deposit "+ FirstName(getAccountName(accountid)), dep.amount, 0, userid);
        
        //log ledger receiver
        Boolean received = LogLedger(accountid,sessionid, appreference, refno, "approve deposit", 0, dep.amount, userid);
        
        ExecuteQuery("UPDATE tblsubscriber set isnewaccount=0 where accountid='"+accountid+"'");
        ExecuteQuery("UPDATE tbldeposits set confirmed=1,dateconfirm=current_timestamp where refno='"+refno+"' and accountid='"+accountid+"'");

        mainObj = api_query_deposit(mainObj, refno);
        mainObj = getTotalBankingNotification(mainObj);
        mainObj.put("message","deposit successfully approved!");

        SendBankingNotification(refno, accountid, "deposit", "Good News!", "Your deposit was approved by your agent! Congratulation..", dep.amount);
        
        mainObj.put("creditbal", getLatestCreditBalance(userid));
        mainObj.put("status", "OK");
        out.print(mainObj);

    }else if(x.equals("cancel_deposit")){
        String refno = request.getParameter("refno");
        String accountid = request.getParameter("accountid");
        String appreference = request.getParameter("appreference");
        String reason = request.getParameter("reason");

        DepositInfo dep = new DepositInfo(refno);
        ExecuteQuery("UPDATE tbldeposits set cancelled=1,datecancelled=current_timestamp,cancelledreason='"+rchar(reason)+"' where refno='"+refno+"' and accountid='"+accountid+"'");
        SendRequestNotificationCount(userid);
        SendBankingNotification(refno, accountid, "deposit", "Ohhh no!", "Your deposit was cancelled by your agent", dep.amount);

        mainObj.put("status", "OK");
        mainObj = api_query_deposit(mainObj, refno);
        mainObj = getTotalBankingNotification(mainObj);
        mainObj.put("message","Downline deposit successfully cancelled!");
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
      logError("app-x-deposit",e.getMessage());
}
%>

<%!public JSONObject deposit_report(JSONObject mainObj,String userid,String search) {
      mainObj = DBtoJson(mainObj, "deposit_report", sqlDepositQuery + " where accountid='" + userid + "' " + search + " order by id desc");
      return mainObj;
 }
%>

<%!public JSONObject deposit_request(JSONObject mainObj, String status, String search) {
    String stat_query = BankingStatus(status);
    mainObj = DBtoJson(mainObj, "deposit_request", sqlDepositQuery + " where " + stat_query + search + " order by id desc limit 50");
    return mainObj;
}
%>


