 
<%!public void SendScoreNotification(String accountid, boolean add, double amount) {
    JSONObject param = new JSONObject();
    param.put("accountid", accountid);
    param.put("amount", (add ? String.valueOf(amount) : String.valueOf(-amount)));
    
    AccountInfo ai = new AccountInfo(accountid);
    param.put("creditbal", String.valueOf(ai.creditbal));
    String description = (add ? "You have received "+String.format("%,.2f", amount) + " credit score." : "You have deducted "+String.format("%,.2f", amount) + " from your credit score.");

    param.put("title", "Credit Score");
    param.put("description", description);
    JSONObject apiObj = new JSONObject();
    apiObj.put("score", param);
    PusherPost(accountid, apiObj);
  }%>

 
<%!public void SendTransferScoreNotification(String accountid, String agentid, String sender, double amount) {
    JSONObject param = new JSONObject();
    param.put("accountid", accountid);
    param.put("amount", String.valueOf(amount));
    AccountInfo ai = new AccountInfo(accountid);
    param.put("creditbal", String.valueOf(ai.creditbal));

    param.put("title", "Credit Score");
    param.put("description", "You have received "+String.format("%,.2f", amount) + " credit score from " + sender);
    JSONObject apiObj = new JSONObject();
    apiObj.put("score", param);
    PusherPost(accountid, apiObj);
  }%>

<%!public void SendAccountStatusNotification(String accountid, String status, String title, String message) {
    if(status.equals("block")){
        JSONObject param = new JSONObject();
        param.put("accountid", accountid);
        param.put("title", title);
        param.put("message", message);
        JSONObject apiObj = new JSONObject();
        apiObj.put("blocked", param);
        PusherPost(accountid, apiObj);
    }
  }%>

<%!public void SendResultNotification(String platform, String title, String accountid, String result, String event, double amount, double payout,  boolean cancelled, String description) {
    JSONObject param = new JSONObject();
    param.put("accountid", accountid);
    param.put("amount", String.valueOf(amount));
    param.put("payout", String.valueOf(payout));
    param.put("result", result);
    param.put("event", event);
    param.put("cancelled", String.valueOf(cancelled));

    AccountInfo ai = new AccountInfo(accountid);
    param.put("creditbal", String.valueOf(ai.creditbal));
    param.put("title", title);
    param.put("description", description);

    JSONObject apiObj = new JSONObject();
    apiObj.put("notification", param);
    PusherPost(accountid, apiObj);
  }%>

<%!public void SendNewDepositNotification(String refno, String accountid, String amount) {
    AccountInfo ai = new AccountInfo(accountid);
    JSONObject param = new JSONObject();
    param.put("accountid", accountid);
    param.put("refno", refno);
    param.put("message", "You have new deposit from:. \n\nAccount No: "+accountid+"\nAccount Name: "+ai.fullname+"\nAmount: "+amount);
    PusherPost("deposit_request", param);
  }%>

<%!public void SendNewWithdrawalNotification(String refno, String accountid, String amount) {
    AccountInfo ai = new AccountInfo(accountid);
    JSONObject param = new JSONObject();
    param.put("accountid", accountid);
    param.put("refno", refno);
    param.put("message", "You have new withdrawal request from:. \n\nAccount No: "+accountid+"\nAccount Name: "+ai.fullname+"\nAmount: "+amount);
    PusherPost("withdrawal_request", param);
  }%>

 
<%!public void SendBankingNotification(String refno, String accountid, String mode, String title, String message, double amount) {
    JSONObject apiObj = new JSONObject();
    apiObj.put("amount", String.valueOf(amount));
    apiObj.put("title", title);
    apiObj.put("description", message);
    PusherPost(accountid, apiObj);
}%>

<%!public void SendRequestNotificationCount(String accountid) {
    JSONObject apiObj = new JSONObject();
    apiObj.put("request",  getTotalRequestNotification(accountid).toString());
    PusherPost(accountid, apiObj);
}%>
 