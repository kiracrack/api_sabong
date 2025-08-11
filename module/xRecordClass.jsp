<%!public class EventInfo{
    public String arena, arenaid, eventkey, result, fightkey, fightnumber, status, postingdate;
    public String event_title, live_mode, live_stream_title, live_stream_url, live_youtube_id, live_sourceid;
    public String event_standby_message, event_reminders_warning;
    public EventInfo(String eventid, boolean priority){
        try{
            ResultSet rst = null; 
            if(priority){
                 rst =  SelectQuery("select *,(select arenaname from tblarena where arenaid=a.arenaid) as arena from tblevent as a where eventid='"+eventid+"'");
            }else{
                 rst =  QuerySelect("select *,(select arenaname from tblarena where arenaid=a.arenaid) as arena from tblevent as a where eventid='"+eventid+"'");
            }
           
            while(rst.next()){
                this.status = rst.getString("current_status");
                this.arena = rst.getString("arena");
                this.arenaid = rst.getString("arenaid");
                this.eventkey = rst.getString("event_key");
                this.fightkey = rst.getString("fightkey");
                this.fightnumber = rst.getString("fightnumber");
                this.postingdate = rst.getString("event_date");
                this.result = rst.getString("fight_result");

                this.event_title = rst.getString("event_title");
                this.live_mode = rst.getString("live_mode");
                this.live_stream_title = rst.getString("live_stream_title");
                this.live_stream_url = rst.getString("live_stream_url");
                this.live_youtube_id = rst.getString("live_youtube_id");
                this.live_sourceid = rst.getString("live_sourceid");
                this.event_standby_message = rst.getString("event_standby_message");
                this.event_reminders_warning = rst.getString("event_reminders_warning");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-event-info",e.toString());
        }
    }
}%>

<%!public class GameResultInfo{
    public String eventid, result, fightnumber, resultdisplay, resultKey;
    public GameResultInfo(String eventid, String resultid){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select eventid, result, fightnumber, if(result='C','X',fightnumber) as resultdisplay, " 
                        + " case when result='W' then 'wala' when result='M' then 'meron' when result='D' then 'draw' when result='C' then 'cancelled' end as 'resultkey' " 
                        + " from tblfightresult where eventid='"+eventid+"' and referenceno='"+resultid+"'");
            while(rst.next()){
                this.eventid = rst.getString("eventid");
                this.result = rst.getString("result");
                this.fightnumber = rst.getString("fightnumber");
                this.resultdisplay = rst.getString("resultdisplay");
                this.resultKey = rst.getString("resultkey");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-result-info",e.toString());
        }
    }
}%>

<%!public class OperatorInfo{
    public String betwacherid, testaccountid, dummy_account_1, dummy_account_2;
    public boolean enable_agent_commission, enableBetWatcher, betwatcherincludedummybets, enablebetbalancer;
    public double minbet, maxbet, op_com_rate, be_com_rate, draw_rate, betwatchermaxamount, betwatcherodds, betbalanceramount;
    public OperatorInfo(String operatorid){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select * from tbloperator where companyid='"+operatorid+"'");
            while(rst.next()){
                this.betwacherid = rst.getString("betwacherid");
                this.testaccountid = rst.getString("testaccountid");
                this.dummy_account_1 = rst.getString("dummy_account_1");
                this.dummy_account_2 = rst.getString("dummy_account_2");

                this.enable_agent_commission = rst.getBoolean("enable_agent_commission");
                
                this.minbet = rst.getDouble("minbet");
                this.maxbet = rst.getDouble("maxbet");

                this.op_com_rate = rst.getDouble("op_com_rate");
                this.be_com_rate = rst.getDouble("be_com_rate");
                this.draw_rate = rst.getDouble("draw_rate");

                this.enableBetWatcher = rst.getBoolean("enablebetwatcher");
                this.betwatchermaxamount = rst.getDouble("betwatchermaxamount");
                this.betwatcherodds = rst.getDouble("betwatcherodds");
                this.betwatcherincludedummybets = rst.getBoolean("betwatcherincludedummybets");

                this.enablebetbalancer = rst.getBoolean("enablebetbalancer");
                this.betbalanceramount = rst.getDouble("betbalanceramount");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-operator-info",e.toString());
        }
    }
}%>


<%!public class FinalBets{
    public double totalMeron, totalWala, oddMeron, oddWala;

    public FinalBets(String operatorid, String fightkey){
        try{
            ResultSet rst = null; 
            double totalAllBets = 0; double ratioMeron = 0; double ratioWala = 0;

            rst =  SelectQuery("select sum(if(bet_choice='M', bet_amount, 0)) as total_meron, " 
                                + " sum(if(bet_choice='W', bet_amount, 0)) as total_wala"
                                + " from tblfightbets where fightkey='"+fightkey+"' and operatorid='"+operatorid+"'");
            while(rst.next()){
                this.totalMeron = rst.getDouble("total_meron");
                this.totalWala = rst.getDouble("total_wala");

                totalAllBets = totalMeron + totalWala;
                ratioMeron =  totalAllBets / totalMeron;
                ratioWala =  totalAllBets / totalWala;

                oddMeron = ratioMeron-(ratioMeron * GlobalFightCommission);
                oddWala = ratioWala-(ratioWala * GlobalFightCommission);
            }
        }catch(SQLException e){
            logError("class-final-bets",e.toString());
        }
    }
}%>

<%!public class AccountInfo{
    public String fullname, username, mobilenumber, sessionid, masteragentid, referralcode;
    public String blockedreason, imageurl, ipaddress, date_registered, date_now, time_now,;
    public double creditbal; 
    public boolean isadmin, blocked, isnewaccount;
    
    public int totalonline;
    public AccountInfo(String accountid){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select *, ifnull(photourl,'') as imageurl, " +
                                " date_format(dateregistered, '%M %d, %Y') as date_registered, " +
                                " date_format(current_timestamp, '%Y-%m-%d') as date_now, " +
                                " date_format(current_timestamp, '%r') as time_now " +
                                " from tblsubscriber as a where accountid='"+accountid+"'");
            while(rst.next()){
                this.fullname = rst.getString("fullname");
                this.username = rst.getString("username");
                this.mobilenumber = rst.getString("mobilenumber");
                this.sessionid = rst.getString("sessionid");
                this.ipaddress = rst.getString("ipaddress");
                this.referralcode = rst.getString("referralcode");
                this.blockedreason = rst.getString("blockedreason");
                this.imageurl = rst.getString("imageurl");
                this.date_registered = rst.getString("date_registered");
                this.date_now = rst.getString("date_now");
                this.time_now = rst.getString("time_now");
                this.creditbal = rst.getDouble("creditbal");

                this.isadmin = rst.getBoolean("isadmin");
                this.blocked = rst.getBoolean("blocked");
                this.isnewaccount = rst.getBoolean("isnewaccount");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-account-info",e.toString());
        }
    }
}%>

<%!public class WinStrikeChecker{
    public String cockfight_eventid;
    public int cockfight_fightno;
    public boolean winstrike_available, winstrike_enabled;
    public WinStrikeChecker(String accountid){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select cockfight_fightno, cockfight_eventid, winstrike_available, winstrike_enabled from tblsubscriber where accountid='"+accountid+"'");
            while(rst.next()){
                this.cockfight_fightno = rst.getInt("cockfight_fightno");
                this.cockfight_eventid = rst.getString("cockfight_eventid");
                this.winstrike_available = rst.getBoolean("winstrike_available");
                this.winstrike_enabled = rst.getBoolean("winstrike_enabled");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-win-strike-checker",e.toString());
        }
    }
}%>

<%!public class WinstrikeCounter{
    public int silver, gold, platinum, totalstrike;
    public WinstrikeCounter(String eventid){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select winstrike_silver, winstrike_gold, winstrike_platinum from tblevent where eventid='"+eventid+"'");
            while(rst.next()){
                this.silver = rst.getInt("winstrike_silver");
                this.gold = rst.getInt("winstrike_gold");
                this.platinum = rst.getInt("winstrike_platinum");
                this.totalstrike = silver + gold + platinum;
            }
            rst.close();
        }catch(SQLException e){
            logError("class-winstrike-counter",e.toString());
        }
    }
}%>

<%!public class WinStrikeBonus{ 
    public double bonus_amount, min_bet;
    public WinStrikeBonus(String category){
         
        if(category.equals("silver")){
            this.bonus_amount = 188; 
            this.min_bet = 30;
        }else if(category.equals("gold")){
            this.bonus_amount = 388; 
            this.min_bet = 60;
        }else if(category.equals("platinum")){
            this.bonus_amount = 688;
            this.min_bet = 100;
        }
    }
}%>

<%!public class ReferralInfo{
    public int totalaccount;
    public ReferralInfo(String userid){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select count(*) as totalaccount from tblsubscriber where agentid='"+userid+"'");
            while(rst.next()){
                this.totalaccount =  rst.getInt("totalaccount");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-referral-info",e.toString());
        }
    }
}%>

<%!public class ReferralBonus{
    public double amount;
    public ReferralBonus(String userid, String datefrom, String dateto){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select ifnull(sum(referral_bonus),0) as amount from tblreferral where referredid='"+userid+"' and date_format(datedeposit, '%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"'");
            while(rst.next()){
                this.amount =  rst.getDouble("amount");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-referral-bonus",e.toString());
        }
    }
}%>

<%!public class BankInfo{
    public String remittanceid, accountnumber, accountname;
    public boolean isoperator;
    public BankInfo(String bankid){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select * from tblbankaccounts where id='"+bankid+"'");
            while(rst.next()){
                this.remittanceid =  rst.getString("remittanceid");
                this.accountnumber =  rst.getString("accountnumber");
                this.accountname =  rst.getString("accountname");
                this.isoperator =  rst.getBoolean("isoperator");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-bank-info",e.toString());
        }
    }
}%>

<%!public class OperatorBankInfo{
    public String bankid, accountnumber, accountname;
    public OperatorBankInfo(String bankcode){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select * from tblbankoperator where code='"+bankcode+"'");
            while(rst.next()){
                this.bankid =  rst.getString("bankid");
                this.accountnumber =  rst.getString("accountnumber");
                this.accountname =  rst.getString("accountname"); 
            }
            rst.close();
        }catch(SQLException e){
            logError("class-operator-bank-info",e.toString());
        }
    }
}%>

<%!public class RemitInfo{
    public boolean isbank;
    public RemitInfo(String rid){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select * from tblbanks where id='"+rid+"'");
            while(rst.next()){
                this.isbank =  rst.getBoolean("isbank");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-remittance-info",e.toString());
        }
    }
}%>

<%!public class AccountBalance{
    public double creditbal;
    public AccountBalance(String accountid){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select creditbal from tblsubscriber as a where accountid='"+accountid+"'");
            while(rst.next()){
                this.creditbal = rst.getDouble("creditbal");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-account-balance",e.toString());
        }
    }
}%>

<%!public class FreeCreditMaster{
    public String accountid;
    public FreeCreditMaster(){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("SELECT * FROM `tblsubscriber` where isfreecredit=1 and masteragent=1;");
            while(rst.next()){
                this.accountid = rst.getString("accountid");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-free-credit-master",e.toString());
        }
    }
}%>

<%!public class RandomDummyAccount{
    public String accountno, dummyname;
    public RandomDummyAccount(){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select * from tbldummyname ORDER BY RAND() LIMIT 1");
            while(rst.next()){
                this.accountno = rst.getString("accountno");
                this.dummyname = rst.getString("dummyname");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-random-dummy",e.toString());
        }
    }
}%>

<%!public class RequestNotification{
    public int count_score_request, count_new_account, count_deposit_request, count_withdrawal_request;
    public RequestNotification(String accountid){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select (select count(*) from tblcreditrequest where confirmed=0 and cancelled=0 and agentid=a.accountid) as count_score_request, "
                    + " (select count(*) from tblregistration where approved=0 and deleted=0 and agentid=a.accountid) as count_new_account, "
                    + " (select count(*) from tbldeposits where confirmed=0 and cancelled=0 and agentid=a.accountid) as count_deposit_request, "
                    + " (select count(*) from tblwithdrawal where confirmed=0 and cancelled=0 and agentid=a.accountid) as count_withdrawal_request "
                    + " from tblsubscriber as a where accountid='"+accountid+"'");
            while(rst.next()){
                this.count_score_request = rst.getInt("count_score_request");
                this.count_new_account = rst.getInt("count_new_account");
                this.count_deposit_request = rst.getInt("count_deposit_request");
                this.count_withdrawal_request = rst.getInt("count_withdrawal_request");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-request-notification",e.toString());
        }
    }
}%>

<%!public class AgentReferralInfo{
    public String accountid, operatorid, masteragentid, agentid;
    public AgentReferralInfo(String referralcode){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select * from tblsubscriber as a where referralcode='"+referralcode+"'");
            while(rst.next()){
                this.accountid = rst.getString("accountid");
                this.operatorid = rst.getString("operatorid");
                this.masteragentid = rst.getString("masteragentid");
                this.agentid = rst.getString("agentid");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-agent-referral-info",e.toString());
        }
    }
}%>

<%!public class FightDetails{
    public int countMeron,countDraw,countWala;
    public double totalMeron,totalDraw,totalWala;
    public FightDetails(String fightkey, String operatorid, boolean includeDummy){
        try{
            ResultSet rst = null; 
            rst =  QuerySelect("select count(if(bet_choice='M', 1, NULL)) as count_meron, " 
                                + " count(if(bet_choice='D', 1, NULL)) as count_draw, " 
                                + " count(if(bet_choice='W', 1, NULL)) as count_wala, " 
                                + " sum(if(bet_choice='M', bet_amount, 0)) as total_meron, " 
                                + " sum(if(bet_choice='D', bet_amount, 0)) as total_draw, "
                                + " sum(if(bet_choice='W', bet_amount, 0)) as total_wala"
                                + " from tblfightbets where fightkey='"+fightkey+"' and operatorid='"+operatorid+"' " + (includeDummy ? "" : " and dummy=0 " ));
            while(rst.next()){
                this.countMeron = rst.getInt("count_meron");
                this.countDraw = rst.getInt("count_draw");
                this.countWala = rst.getInt("count_wala");
                this.totalMeron = rst.getDouble("total_meron");
                this.totalDraw = rst.getDouble("total_draw");
                this.totalWala = rst.getDouble("total_wala");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-fight-details",e.toString());
        }
    }
}%>

<%!public class FightSummary{
    public int countMeron,countDraw,countWala;
    public double totalMeron,totalDraw,totalWala;
    public double totalWinAmount,totalLoseAmount,totalPayout;
    public FightSummary(String fightkey, String operatorid){
        try{
            ResultSet rst = null; 
            rst =  QuerySelect("select count(if(bet_choice='M', 1, NULL)) as count_meron, " 
                                + " count(if(bet_choice='D', 1, NULL)) as count_draw, " 
                                + " count(if(bet_choice='W', 1, NULL)) as count_wala, " 
                                + " sum(if(bet_choice='M', bet_amount, 0)) as total_meron, " 
                                + " sum(if(bet_choice='D', bet_amount, 0)) as total_draw, "
                                + " sum(if(bet_choice='W', bet_amount, 0)) as total_wala, "
                                + " ifnull(sum(win_amount),0) as total_win, " 
                                + " ifnull(sum(lose_amount),0) as total_lose, "
                                + " ifnull(sum(payout_amount),0) as total_payout "
                                + " from tblfightbets where fightkey='"+fightkey+"' and operatorid='"+operatorid+"' and dummy=0 and banker=0");
            while(rst.next()){
                this.countMeron = rst.getInt("count_meron");
                this.countDraw = rst.getInt("count_draw");
                this.countWala = rst.getInt("count_wala");
                this.totalMeron = rst.getDouble("total_meron");
                this.totalDraw = rst.getDouble("total_draw");
                this.totalWala = rst.getDouble("total_wala");
                this.totalWinAmount = rst.getDouble("total_win");
                this.totalLoseAmount = rst.getDouble("total_lose");
                this.totalPayout = rst.getDouble("total_payout");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-fight-summary",e.toString());
        }
    }
}%>

<%!public class FightSummaryDetails{
    public String fightnumber, result, dateposted, timeposted;

    public FightSummaryDetails(String fightkey){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select fightnumber, result, date_format(datetrn,'%Y-%m-%d') as 'dateposted', date_format(datetrn,'%r') as 'timeposted' from tblfightsummary where fightkey='"+fightkey+"'");
            while(rst.next()){
                this.fightnumber = rst.getString("fightnumber");
                this.result = rst.getString("result");
                this.dateposted = rst.getString("dateposted");
                this.timeposted = rst.getString("timeposted");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-fight-summary-details",e.toString());
        }
    }
}%>
 

<%!public class TurnoverBonus{
    public String bonusdate;
    public double total, bonus; 
    public TurnoverBonus(String userid){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery(sqlDailyTurnoverQuery(userid));
            while(rst.next()){
                this.total = rst.getDouble("total");
                this.bonus = rst.getDouble("bonus");
                this.bonusdate = rst.getString("current_date");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-turnover-bonus",e.toString());
        }
    }
}%>

<%!public class DepositInfo{
    public String accountid; 
    public double amount; 
    public boolean confirmed;
    public DepositInfo(String refno){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select * from tbldeposits as a where refno='"+refno+"'");
            while(rst.next()){
                this.accountid =  rst.getString("accountid");
                this.amount = rst.getDouble("amount");
                this.confirmed = rst.getBoolean("confirmed");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-deposit-info",e.toString());
        }
    }
}%>

<%!public class WithdrawalInfo{
    public String accountid, accountname, agentid, agentname;
    public double amount, cashout;
    public boolean iscashaccount;
    public WithdrawalInfo(String refno){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select *,ifnull((select fullname from tblsubscriber as x where x.accountid=a.accountid),'') as accountname, "
                        + " ifnull((select fullname from tblsubscriber as x where x.accountid=a.agentid),'') as agentname from tblwithdrawal as a where refno='"+refno+"'");
            while(rst.next()){
                this.accountid = rst.getString("accountid");
                this.accountname = rst.getString("accountname");
                this.agentid = rst.getString("agentid");
                this.agentname = rst.getString("agentname");
                this.amount = rst.getDouble("amount");
                this.cashout = rst.getDouble("cashout");
                this.iscashaccount = rst.getBoolean("iscashaccount");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-withdrawal-info",e.toString());
        }
    }
}%>

<%!public class NewAccountInfo{
    public String fullname, mobilenumber, username, password, operatorid, masteragentid, agentid, reference, photourl, location;
    public NewAccountInfo(String regno){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select * from tblregistration as a where regno='"+regno+"'");
            while(rst.next()){
                this.fullname = rst.getString("fullname");
                this.mobilenumber = rst.getString("mobilenumber");
                this.username = rst.getString("username");
                this.password = rst.getString("password");
                this.operatorid = rst.getString("operatorid");
                this.masteragentid = rst.getString("masteragentid");
                this.agentid = rst.getString("agentid");
                this.reference = rst.getString("reference");
                this.photourl = rst.getString("photourl");
                this.location = rst.getString("location");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-new-account",e.toString());
        }
    }
}%>
 
<%!public class ArenaInfo{
    public String arenaname, main_banner_url;
    public boolean opposite_bet;
    public ArenaInfo(String arenaid){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select arenaname, main_banner_url, opposite_bet from tblarena where arenaid='"+arenaid+"'");
            while(rst.next()){
                this.arenaname = rst.getString("arenaname");
                this.main_banner_url = rst.getString("main_banner_url");
                this.opposite_bet = rst.getBoolean("opposite_bet");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-arena-info",e.toString());
        }
    }
}%>

<%!public class PromoInfo{
    public String title, category, push_message, banner_url;
    public PromoInfo(String id){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select title, CONCAT(UCASE(SUBSTRING(category, 1, 1)), LCASE(SUBSTRING(category, 2))) as category, push_message, banner_url from tblpromo where id='"+id+"'");
            while(rst.next()){
                this.title = rst.getString("title");
                this.category = rst.getString("category");
                this.push_message = rst.getString("push_message");
                this.banner_url = rst.getString("banner_url");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-promo",e.toString());
        }
    }
}%>


<%!public class VideoInfo{
    public String source_name, source_url, player_type, web_url, web_player;
    public boolean isyoutube;
    public VideoInfo(String id){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select * from tblvideosource where id='"+id+"'");
            while(rst.next()){
                this.source_name = rst.getString("source_name");
                this.source_url = rst.getString("source_url");
                this.isyoutube = rst.getBoolean("isyoutube");
                this.player_type = rst.getString("player_type");
                this.web_url = rst.getString("web_url");
                this.web_player = rst.getString("web_player");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-video",e.toString());
        }
    }
}%>

<%!public class MessageTemplate{
    public String template, imageurl;
    public MessageTemplate(String code){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select * from tbltemplate where code='"+code+"'");
            while(rst.next()){
                this.template = rst.getString("template");
                this.imageurl = rst.getString("imageurl");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-message-template",e.toString());
        }
    }
}%>
 
<%!public class ActiveEventVideo{
    public String eventid;
    public ActiveEventVideo(String videoid){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select eventid from tblevent where live_sourceid='"+videoid+"' and event_active=1");
            while(rst.next()){
                this.eventid = rst.getString("eventid");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-active-event-video",e.toString());
        }
    }
}%>

<%!public class ErrorFightOdds{
    public double oddMeron, oddWala;
    public ErrorFightOdds(String fightkey, String operatorid){
        try{
            ResultSet rst = null; 
            rst =  QuerySelect("select odd_meron, odd_wala from tblfightsummary where fightkey='"+fightkey+"' and operatorid='"+operatorid+"'");
            while(rst.next()){
                this.oddMeron = rst.getDouble("odd_meron");
                this.oddWala = rst.getDouble("odd_wala");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-error-fight-odds",e.toString());
        }
    }
}%>


<%!public class ErrorResultInfo{
    public String eventid, arenaid, eventkey, referenceno, result, fightnumber, status, postingdate;
    public ErrorResultInfo(String fightkey){
        try{
            ResultSet rst = SelectQuery("select * from tblfightresult as a where fightkey='"+fightkey+"'");
            while(rst.next()){
                this.eventid = rst.getString("eventid");
                this.arenaid = rst.getString("arenaid");
                this.eventkey = rst.getString("eventkey");
                this.referenceno = rst.getString("referenceno");
                this.fightnumber = rst.getString("fightnumber");
                this.postingdate = rst.getString("postingdate");
                this.result = rst.getString("result");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-error-result-info",e.toString());
        }
    }
}%>


<%!public class DateWeekly{
    public String prev_week_code, current_week_code;
    public String current_date, current_week_from, current_week_to, prev_week_from, prev_week_to;
    public DateWeekly(){
        try{
            DateFormat format = new SimpleDateFormat("yyyy-MM-dd", Locale.getDefault());
            Calendar current = Calendar.getInstance();
            current_date = format.format(current.getTime());

            current.add(Calendar.DATE, -1);
            current.set(Calendar.DAY_OF_WEEK, Calendar.MONDAY);

            current_week_from = format.format(current.getTime());
            current.add(Calendar.DATE, 6);
            current_week_to = format.format(current.getTime());

            Calendar previous = (Calendar) current.clone();
            previous.add(Calendar.DATE, -13);
            prev_week_from = format.format(previous.getTime());

            previous.add(Calendar.DATE, 6);
            prev_week_to = format.format(previous.getTime());

            prev_week_code = prev_week_from.replace("-","") + prev_week_to.replace("-",""); 
            current_week_code = current_week_from.replace("-","") + current_week_to.replace("-",""); 

        }catch(Exception e){
            logError("class-api-date-weekly",e.toString());
        }
    }
}%>

<%!public class DownlineWinlossCockfight{
    public double winloss;
    public DownlineWinlossCockfight(String agentid, String datefrom, String dateto){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select ROUND(sum(win_amount) - sum(lose_amount),2) as winloss from tblfightbets2 as a where agentid='"+agentid+"'  and cancelled=0 and date_format(datetrn, '%Y-%m-%d') between '" + datefrom + "' and '" + dateto + "'");
            while(rst.next()){
                this.winloss = rst.getDouble("winloss");  
            }
            rst.close();
        }catch(SQLException e){
            logError("class-downline-win-loss-cockfight",e.toString());
        }
    }
}%>

<%!public class DownlineWinlossCasino{
    public double winloss;
    public DownlineWinlossCasino(String agentid, String datefrom, String dateto){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select ifnull(sum(winloss),0) as winloss from tblgamesummary as a where agentid='"+agentid+"' and date_format(gamedate, '%Y-%m-%d') between '" + datefrom + "' and '" + dateto + "'");
            while(rst.next()){
                this.winloss = rst.getDouble("winloss");  
            }
            rst.close();
        }catch(SQLException e){
            logError("class-downline-win-loss-casino",e.toString());
        }
    }
}%>

<%!public class PlayerWinlossCockfight{
    public double winloss;
    public PlayerWinlossCockfight(String accountid, String datefrom, String dateto){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select ROUND(sum(win_amount) - sum(lose_amount),2) as winloss from tblfightbets2 as a where accountid='"+accountid+"'  and cancelled=0 and date_format(datetrn, '%Y-%m-%d') between '" + datefrom + "' and '" + dateto + "'");
            while(rst.next()){
                this.winloss = rst.getDouble("winloss");  
            }
            rst.close();
        }catch(SQLException e){
            logError("class-player-win-loss-cockfight",e.toString());
        }
    }
}%>

<%!public class PlayerWinlossCasino{
    public double winloss;
    public PlayerWinlossCasino(String accountid, String datefrom, String dateto){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select ifnull(sum(winloss),0) as winloss from tblgamesummary as a where accountid='"+accountid+"' and date_format(gamedate, '%Y-%m-%d') between '" + datefrom + "' and '" + dateto + "'");
            while(rst.next()){
                this.winloss = rst.getDouble("winloss");  
            }
            rst.close();
        }catch(SQLException e){
            logError("class-player-win-loss-casino",e.toString());
        }
    }
}%>

<%!public class PlayerTotalDeposit{
    public double totaldeposit;
    public PlayerTotalDeposit(String accountid, String datefrom, String dateto){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select ifnull(sum(amount),0) as total from tbldeposits as a where accountid='"+accountid+"' and confirmed=1 and cancelled=0 and date_format(datetrn, '%Y-%m-%d') between '" + datefrom + "' and '" + dateto + "'");
            while(rst.next()){
                this.totaldeposit = rst.getDouble("total");  
            }
            rst.close();
        }catch(SQLException e){
            logError("class-player-total-deposit",e.toString());
        }
    }
}%>


