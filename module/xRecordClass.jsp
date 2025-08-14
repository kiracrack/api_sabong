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

<%!public class GeneralSettings{
    public String betwacherid, dummy_account_1, dummy_account_2;
    public boolean enable_agent_commission, enableBetWatcher, betwatcherincludedummybets, enablebetbalancer;
    public double minbet, maxbet, op_com_rate, be_com_rate, draw_rate, betwatchermaxamount, betwatcherodds, betbalanceramount;
    public GeneralSettings(){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select * from tblgeneralsettings");
            while(rst.next()){
                this.betwacherid = rst.getString("betwacherid");
                this.dummy_account_1 = rst.getString("dummy_account_1");
                this.dummy_account_2 = rst.getString("dummy_account_2");

                this.minbet = rst.getDouble("minbet");
                this.maxbet = rst.getDouble("maxbet");
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

    public FinalBets(String fightkey){
        try{
            ResultSet rst = null; 
            double totalAllBets = 0; double ratioMeron = 0; double ratioWala = 0;

            rst =  SelectQuery("select sum(if(bet_choice='M', bet_amount, 0)) as total_meron, " 
                                + " sum(if(bet_choice='W', bet_amount, 0)) as total_wala"
                                + " from tblfightbets where fightkey='"+fightkey+"'");
            while(rst.next()){
                this.totalMeron = rst.getDouble("total_meron");
                this.totalWala = rst.getDouble("total_wala");

                totalAllBets = totalMeron + totalWala;
                ratioMeron =  totalAllBets / totalMeron;
                ratioWala =  totalAllBets / totalWala;

                oddMeron = ratioMeron-(ratioMeron * GlobalPlasada);
                oddWala = ratioWala-(ratioWala * GlobalPlasada);
            }
        }catch(SQLException e){
            logError("class-final-bets",e.toString());
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
 
<%!public class FightDetails{
    public int countMeron,countDraw,countWala;
    public double totalMeron,totalDraw,totalWala;
    public FightDetails(String fightkey){
        try{
            ResultSet rst = null; 
            rst =  QuerySelect("select count(if(bet_choice='M', 1, NULL)) as count_meron, " 
                                + " count(if(bet_choice='D', 1, NULL)) as count_draw, " 
                                + " count(if(bet_choice='W', 1, NULL)) as count_wala, " 
                                + " sum(if(bet_choice='M', bet_amount, 0)) as total_meron, " 
                                + " sum(if(bet_choice='D', bet_amount, 0)) as total_draw, "
                                + " sum(if(bet_choice='W', bet_amount, 0)) as total_wala"
                                + " from tblfightbets where fightkey='"+fightkey+"'");
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
 
