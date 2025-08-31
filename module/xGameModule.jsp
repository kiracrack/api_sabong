
<%!public String GenerateNewPlasada(){ 
    Random rand = new Random();
     int method =  rand.nextInt(10 - 1) + 1;
     if(method % 2 == 0){
		return String.valueOf(GlobalPlasadaBase);
	 }else{
		return RandomPlasadaRate();
	 }
}
%>

<%!public String RandomPlasadaRate(){ 
    final String[] plasada = {"0.050", "0.055", "0.060", "0.065", "0.070", "0.075", "0.080", "0.085", "0.090", "0.095", "0.100"};
    Random random = new Random();
    int index = random.nextInt(plasada.length);
    return plasada[index];
}
%>

<%!public void ExecutePostBet(String eventid, String sessionid, String appreference, String operatorid, String accountid, String accountname, String identifier, String bet_choice, double bet_amount, boolean banker, boolean dummy) {
    EventInfo event = new EventInfo(eventid, false);

    String transactionno = getSystemSeriesID("series_bets");
    String Command = " set operatorid='"+operatorid+"', "
                            + " accountid='"+accountid+"', "
                            + " accountname='"+ rchar(accountname) +"',"
                            + " identifier='"+ identifier +"',"
                            + " banker="+ banker +","
                            + " dummy="+ dummy +","
                            + " sessionid='"+sessionid+"', "
                            + " appreference='"+appreference+"', "
                            + " arenaid='"+event.arenaid+"', " 
                            + " eventid='"+eventid+"', "
                            + " eventkey='"+eventid+"-"+event.eventkey+"', "
                            + " fightkey='"+event.fightkey+"', "
                            + " fightnumber='"+event.fightnumber+"', "
                            + " postingdate='"+event.postingdate+"', "
                            + " transactionno='"+transactionno+"', "
                            + " bet_choice='"+bet_choice+"', "
                            + " bet_amount='"+bet_amount+"', "
                            + " lose_amount='"+bet_amount+"', "
                            + " datetrn=current_timestamp";
    if(dummy){
        if(banker){
            //LogLedgerDirect(accountid, sessionid, appreference, transactionno, (banker ? "banker" : "choose") +" bet "+ (bet_choice.equals("M") ? "meron" : (bet_choice.equals("W") ? "wala" : "draw")) +"  (fight#"+event.fightnumber+"@"+event.arena+")",bet_amount,0, accountid);    
        }
        //LogLedgerDirect(accountid, sessionid, appreference, transactionno, (banker ? "banker" : "choose") +" bet "+ (bet_choice.equals("M") ? "meron" : (bet_choice.equals("W") ? "wala" : "draw")) +"  (fight#"+event.fightnumber+")",bet_amount,0, accountid);    
        ExecuteDummy("insert into tblfightbets " + Command);
        
    }else{
        //execute api LogLedger(accountid, sessionid, appreference, transactionno, (banker ? "banker" : "choose") +" bet "+ (bet_choice.equals("M") ? "meron" : (bet_choice.equals("W") ? "wala" : "draw")) +"  (fight#"+event.fightnumber+"@"+event.arena+")",bet_amount,0, accountid);    
        ExecuteBet("insert into tblfightbets " + Command);
        //ExecuteBet("insert into tblfightbetslogs " + Command);
    }
  }
 %>

<%!public void ExecuteComputeBets(String fightkey, String result, boolean isDraw, boolean isCancelled, String cancelledReason,  double oddMeron, double oddWala){
    GeneralSettings gs = new GeneralSettings();

    ExecuteResult("update tblfightbets set " 
                        + " result='"+result+"', "
                        + " odd=if(win,if(bet_choice='M',ROUND("+oddMeron+",2),ROUND("+oddWala+",2)), if(bet_choice='M',ROUND("+oddMeron+",2),ROUND("+oddWala+",2))),"
                        + " win_amount="+(isDraw || isCancelled ? "0" : "if(win,ROUND((bet_amount*if(bet_choice='M',ROUND("+oddMeron+",2),ROUND("+oddWala+",2))),2),0)")+", " 
                        + " lose_amount="+(isDraw || isCancelled ? "0" : "if(win,0,bet_amount)")+", " 
                        + " payout_amount=if(win,(bet_amount*if(bet_choice='M',ROUND("+oddMeron+",2),ROUND("+oddWala+",2)))+bet_amount,0), " 
                        + " plasada="+gs.plasada_rate+", " 
                        + " cancelled=" + isCancelled + ", "  
                        + " cancelledreason='" + (isDraw ? "Draw fight" : cancelledReason) + "' "  
                        + " where fightkey='"+fightkey+"' and (bet_choice='M' or bet_choice='W')");

    ExecuteResult("update tblfightbets set " 
                        + " result='"+result+"', "
                        + " odd="+gs.draw_rate+","
                        + " win_amount=if(win,(bet_amount*"+gs.draw_rate+")-bet_amount,0), " 
                        + " lose_amount=if(win,0,bet_amount), " 
                        + " payout_amount=if(win,(bet_amount*"+gs.draw_rate+"),0), " 
                        + " plasada="+gs.plasada_rate+" " 
                        + " where fightkey='"+fightkey+"' and bet_choice='D'");
}%>

<%!public void ExecuteReturnBetsDraw(String fightkey, String session, String referenceno){
    try{
        ResultSet rst = null; 
        rst = SelectQuery("select dummy,arenaid,(select arenaname from tblarena where arenaid=a.arenaid) as arena,eventid,accountid,appreference,fightnumber,sum(bet_amount) totalbet from tblfightbets as a where fightkey='"+fightkey+"' and (bet_choice='M' or bet_choice='W') group by accountid");
        while(rst.next()){
            String uid = rst.getString("accountid");
            String arena = rst.getString("arena");
            String arenaid = rst.getString("arenaid");
            String eventid = rst.getString("eventid");
            String fightnumber = rst.getString("fightnumber");
            String sessionid = rst.getString("appreference");
            double totalbet = rst.getDouble("totalbet");
            boolean dummy = rst.getBoolean("dummy");

            String ledger = "return score (draw fight#"+fightnumber+"@"+arena+")";

            if(!isLogFightFound(uid,sessionid,arenaid,eventid,fightkey,ledger,totalbet)){
                LogFightNotification(uid,sessionid,arenaid,eventid,fightkey,ledger,totalbet);
                //if(!dummy) LogLedgerDirect(uid, sessionid, fightkey, referenceno, ledger, 0, totalbet, "CONTROLLER");
            }
            
        }
        rst.close();
    }catch(SQLException e){
        logError("ExecuteReturnBetsDraw",e.toString());
    }
}%>

<%!public void ExecuteReturnBetsCancelled(String fightkey, String session, String referenceno, boolean notify, String reason){
    try{
        ResultSet rst = null; 
        rst = SelectQuery("select dummy,accountid,arenaid,(select arenaname from tblarena where arenaid=a.arenaid) as arena,eventid,appreference,fightnumber,sum(bet_amount) totalbet from tblfightbets as a where fightkey='"+fightkey+"' group by accountid");
        while(rst.next()){
            String uid = rst.getString("accountid");
            String arena = rst.getString("arena");
            String arenaid = rst.getString("arenaid");
            String eventid = rst.getString("eventid");
            String sessionid = rst.getString("appreference");
            String fightnumber = rst.getString("fightnumber");
            double totalbet = rst.getDouble("totalbet");
            boolean dummy = rst.getBoolean("dummy");

            String ledger = "return score (cancelled fight#"+fightnumber+"@"+ arena + (reason.length() > 0 ? " - " + reason : "") + ")";

            if(!isLogFightFound(uid,sessionid,arenaid,eventid,fightkey,ledger,totalbet)){
                LogFightNotification(uid,sessionid,arenaid,eventid,fightkey,ledger,totalbet);
                //if(!dummy) LogLedgerDirect(uid, sessionid, fightkey, referenceno, ledger, 0, totalbet, "CONTROLLER");
            }

            if(notify){
                String event_desc = "Arena " +  rst.getString("arena") + " - Fight #" + rst.getString("fightnumber");
                //SendResultNotification(platform, "Return Bets", rst.getString("accountid"), "C", arena, fightnumber, "", event_desc, rst.getDouble("totalbet"), 0, 0, true, "fight is cancelled! " + reason);
            }
        }
        rst.close();

    }catch(SQLException e){
        logError("ExecuteReturnBetsCancelled",e.toString());
    }
}%>

<%-- AC bonus --%>
 <%!public ArrayList getActivePlayer() {
    ArrayList<String> list = new ArrayList<String>();
    try{
        ResultSet rst = null; 
        //NOTE: (need modify) select from gamebets2 
        rst =  SelectQuery("select accountid from tblsubscriber where date_format(lastbetlogdate, '%Y-%m-%d')=current_date and TIMESTAMPDIFF(MINUTE,lastbetlogdate,current_timestamp) < 10 and totalcurrentbet > 30 and blocked=0 order by rand() limit 10");
        while(rst.next()){
            list.add(rst.getString("accountid"));
        }
        rst.close();
    }catch(SQLException e){
        logError("getActivePlayer",e.toString());
    }
    return list;}
 %>

<%!public void ExecuteReleaseBonus(String eventid, String sessionid, String appreference){
    JSONObject apiObj = new JSONObject();
    if(isBonusAvailableRelease()){
        ArrayList player = new ArrayList();
        player = getActivePlayer();
         

        if(player.size() > 0){
            ActiveBonusInfo info = new ActiveBonusInfo();
            double amountbonus = (info.totalbonus / 10);
            double amountreleased = amountbonus * player.size();
            double amountremaining = (player.size() >= 10 ? 0 : info.totalbonus - amountreleased);
        
            for (int i=0; i < player.size(); i++){
                String accountid = player.get(i).toString();

                if(!isBonusLogsFound(eventid, sessionid, appreference, info.id, accountid, amountbonus)){
                    String referenceno = getSystemSeriesID("series_bonus", 7);
                    ExecuteResult("insert into tblbonuslogs set eventid='"+eventid+"',sessionid='"+sessionid+"', appreference='"+appreference+"', referenceno='"+referenceno+"', bonusid='"+info.id+"', accountid='"+accountid+"', amount=ROUND("+amountbonus+",2),datetrn=current_timestamp");
                    //apiObj = api_jackpot_bonus(apiObj, accountid);
                    //PusherPost(accountid, apiObj);
                }
            }
            /* create new bonus */
            ExecuteResult("UPDATE tblbonusinfo set closed=1,amountreleased=ROUND("+amountreleased+",2), players="+player.size()+", amountremaining=ROUND("+amountremaining+",2),dateclosed=current_timestamp where closed=0");
            BonusSettings bonus = new BonusSettings();
            ExecuteResult("insert into tblbonusinfo set startdate=current_timestamp,randamount=(FLOOR(RAND() * 9000) + 1000), totalbonus=ROUND("+(bonus.bonusinitialamount + amountremaining)+",2), schedule=(SELECT timestamp(CONCAT(DATE_ADD(current_date, INTERVAL FLOOR((RAND() * ("+bonus.bonusrandomdays+"-1+1))+1) DAY),' 23:00:00')) - INTERVAL FLOOR( RAND( ) * 14) HOUR), displayminamount='"+bonus.bonusdisplayminamount+"'");
            
            //apiObj = api_total_bonus(apiObj);
            //PusherPost(eventid, apiObj);
        }
    }
}%>


<%!public void ExecuteACBonus(String eventid, double total_bonus){
    JSONObject apiObj = new JSONObject();
    if(total_bonus > 0){
        if(isActiveBonusAvailable()){
           ExecuteResult("UPDATE tblbonusinfo set totalbonus=ROUND((totalbonus+"+total_bonus+"),2) where closed=0");
        }else{
            BonusSettings bonus = new BonusSettings();
            ExecuteResult("insert into tblbonusinfo set startdate=current_timestamp,randamount=(FLOOR(RAND() * 9000) + 1000), totalbonus=ROUND("+(bonus.bonusinitialamount + total_bonus)+",2), schedule=(SELECT timestamp(CONCAT(DATE_ADD(current_date, INTERVAL FLOOR((RAND() * ("+bonus.bonusrandomdays+"-1+1))+1) DAY),' 23:00:00')) - INTERVAL FLOOR( RAND( ) * 14) HOUR), displayminamount='"+bonus.bonusdisplayminamount+"'");
        }
        
        //apiObj = api_total_bonus(apiObj);
        //PusherPost(eventid, apiObj);
    }
}%>

<%!public boolean isActiveBonusAvailable(){
    return CountQry("tblbonusinfo", "closed=0") > 0;
}%>

<%!public boolean isBonusLogsFound(String eventid, String sessionid, String appreference, String bonusid, String accountid, double amount){
    return CountQry("tblbonuslogs", "eventid='"+eventid+"' and sessionid='"+sessionid+"' and appreference='"+appreference+"' and bonusid='"+bonusid+"' and accountid='"+accountid+"' and amount="+amount+"") > 0;
}%>

<%!public boolean isBonusAvailableRelease(){
    return CountQry("tblbonusinfo", "closed=0 and current_timestamp >= schedule") > 0;
}%>

<%-- PB Bnus --%>
<%!public void ExecutePBBonus(String fightkey,  double total_bets, double total_bonus){
    if(total_bonus > 0) ExecuteResult("update tblfightbets set payback_rate=ROUND(bet_amount/"+total_bets+",2),payback_total=ROUND("+total_bonus+"*(bet_amount/"+total_bets+"),2) where fightkey='"+fightkey+"' and banker=0 and cancelled=0");
}%>

<%!public void ExecuteUpdateWinloss(String fightkey){
    ExecuteResult("update tblfightbets set winloss=ROUND(if(cancelled,0,if(win,win_amount + payback_total, if(result='D', 0, -(lose_amount-payback_total)))),2) where fightkey='"+fightkey+"' and cancelled=0");
}%>

<%-- end bonus --%>
<%!public void NotifyPlayersResult(String fightkey, String eventid, String fightnumber, String sessionid, String referenceno){
    try{
        ResultSet rst = null; 
        rst = SelectQuery("select accountid,appreference,transactionno,arenaid,dummy,banker, MAX(if(win,odd,0)) as win_odd,if(!win,odd,0) as loss_odd, result, " 
                                + " (select arenaname from tblarena where arenaid=a.arenaid) as arena, " 
                                + " sum(bet_amount) totalbet, " 
                                + " sum(if(win,bet_amount,0)) totalwinbet, " 
                                + " sum(if(cancelled,bet_amount,0)) as totalcancelled, " 
                                + " ROUND(sum(if(win,win_amount,0)),2) as totalwin, "
                                + " ROUND(sum(lose_amount),2) as totallose, "
                                + " ROUND(sum(if(win,payout_amount,0)),2) as totalpayout, "
                                + " ROUND(sum(payback_total),2) as payback_total, "
                                + " ROUND(sum(winloss),2) as winloss, "
                                + " group_concat(concat('{\"choice:\"',bet_choice,'\",\"bet\":\"',bet_amount,'\",\"odd\":\"',odd,'\",\"win\":\"',win,'\",\"pb\":\"',payback_total,'\",\"wl\":\"',winloss,'\"}')) as betinfo, " 
                                + " cancelledreason " 
                                + " from tblfightbets as a where fightkey='"+fightkey+"' group by accountid");
        while(rst.next()){
            boolean execute_notify = false;
            String description = "";
            String uid = rst.getString("accountid");
            String arena = rst.getString("arena");
            String arenaid = rst.getString("arenaid");
            String appreference = rst.getString("appreference");
            String transactionno = rst.getString("transactionno");
            String win_odd = rst.getString("win_odd");
            String loss_odd = rst.getString("loss_odd");
            String result = rst.getString("result");
            String cancelledreason = rst.getString("cancelledreason");
            double totalbet = rst.getDouble("totalbet");
            double totalwinbet = rst.getDouble("totalwinbet");
            double totalwin = rst.getDouble("totalwin");
            double totallose = rst.getDouble("totallose");
            double totalpayout = rst.getDouble("totalpayout");
            double payback_total = rst.getDouble("payback_total");
            double winloss = rst.getDouble("winloss");
            double totalcancelled = rst.getDouble("totalcancelled");
            String betinfo = rst.getString("betinfo");
            double amount = totalwin - totallose;
            boolean dummy = rst.getBoolean("dummy");
            boolean banker = rst.getBoolean("banker");
        
            if(totalpayout > 0){
                String ledger = (result.equals("M") ? "meron win" : (result.equals("W") ? "wala win" : "result draw")) + " ("+win_odd+"% fight#"+fightnumber+"@"+arena+")";
                if(!isLogFightFound(uid,sessionid,arenaid,eventid,fightkey,ledger,totalpayout)){
                    LogFightNotification(uid,sessionid,arenaid,eventid,fightkey,ledger,totalpayout);
                    //if(!dummy) LogLedgerDirect(uid, sessionid, fightkey, appreference, ledger ,0, totalpayout + payback_total, "CONTROLLER");
                    execute_notify = true;
                }
            }else{
                if(payback_total > 0){
                    String ledger ="payback bonus (fight#"+fightnumber+"@"+arena+")";
                    //LogLedgerDirect(uid, sessionid, fightkey, appreference, ledger ,0, payback_total, "CONTROLLER");
                }
            }

            //if(winloss != 0 && !dummy && !banker) ExecuteLogTransaction(uid, sessionid, appreference, referenceno, "BET Fight #"+fightnumber+" - " + arena, betinfo,  totalbet, winloss);
 
            if(totalwin==0 && totallose==0){
                //SendResultNotification("Return Bets", uid, result, arena, fightnumber, "", arena, (totalcancelled > 0 ? totalcancelled : totalbet), 0, payback_total, true, "Cancelled Fight! " + (!result.equals("D") ? cancelledreason : ""));

            }else if(totalwin==0 && totallose > 0){
                String loss_desc = "loss fight #"+fightnumber+"@"+arena;
                if(!isLogFightFound(uid,sessionid,arenaid,eventid,fightkey,loss_desc,amount)){
                    LogFightNotification(uid,sessionid,arenaid,eventid,fightkey,loss_desc,amount);
                    //SendResultNotification("Loss Amount", uid, result, arena, fightnumber, loss_odd, arena, amount + payback_total, 0, payback_total, false, loss_desc);
                }

            }else{
                //bet both fights
                //Your bet 100.00 win (67.00 @ 1.67%) and lose 50 from other bets
                if(execute_notify){
                    //SendResultNotification((amount >= 0 ? "Total Winning Amount" : "Total Loss Amount"), uid, result, arena, fightnumber, (amount >= 0 ? win_odd : loss_odd), arena, amount + payback_total, (totalpayout > 0 ? totalpayout : 0), payback_total, false, description);
                }
            }
        }
        rst.close();
    }catch(SQLException e){
        logError("NotifyPlayersResult",e.toString());
    }
}%>


<%!public boolean isLogFightFound(String accountid, String sessionid, String arenaid, String eventid, String fightkey, String description, double amount){
    return CountQry("tblfightlogs", "accountid='"+accountid+"' and sessionid='"+sessionid+"' and arenaid='"+arenaid+"' and eventid='"+eventid+"' and fightkey='"+fightkey+"' and description='"+description+"' and amount='"+amount+"'") > 0;
}%>

<%!public void LogFightNotification(String accountid, String sessionid,  String arenaid, String eventid, String fightkey, String description, double amount){
    ExecuteResult("INSERT into tblfightlogs set accountid='"+accountid+"', sessionid='"+sessionid+"', arenaid='"+arenaid+"', eventid='"+eventid+"', fightkey='"+fightkey+"', description='"+description+"', amount='"+amount+"'");
}%>

<%!public void LogCancelledFight(String arenaid, String eventid, String eventkey, String fightkey, String fightnumber, String postingdate, String deviceid){
    ExecuteResult("DELETE from tblfightsummary where fightkey='"+fightkey+"'");
    ExecuteResult("INSERT into tblfightsummary set " 
                + " arenaid='"+arenaid+"', "
                + " eventid='"+eventid+"', "
                + " eventkey='"+eventkey+"', "
                + " fightkey='"+fightkey+"', "
                + " fightnumber='"+fightnumber+"', "
                + " postingdate='"+postingdate+"', "
                + " result='C', "
                + " plasada="+GlobalPlasadaRate+", " 
                + " datetrn=current_timestamp, "
                + " trnby='"+deviceid+"'");
}%>

<%!public void LogFightResult(String referenceno, String arenaid, String eventid, String eventkey, String fightkey, String fightnumber, String postingdate, String result){
    ExecuteResult("DELETE from tblfightresult where fightkey='"+fightkey+"'");
    ExecuteResult("INSERT into tblfightresult set " 
                + " referenceno='"+referenceno+"', "
                + " arenaid='"+arenaid+"', "
                + " eventid='"+eventid+"', "
                + " eventkey='"+eventkey+"', "
                + " fightkey='"+fightkey+"', "
                + " fightnumber='"+fightnumber+"', "
                + " postingdate='"+postingdate+"', "
                + " result='"+result+"'");

    if(result.equals("M")){
        ExecuteResult("UPDATE tblevent set total_win_meron=total_win_meron + 1 where eventid='"+eventid+"'");
    }else if(result.equals("W")){
        ExecuteResult("UPDATE tblevent set total_win_wala=total_win_wala + 1 where eventid='"+eventid+"'");
    }else if(result.equals("D")){
        ExecuteResult("UPDATE tblevent set total_draw=total_draw + 1 where eventid='"+eventid+"'");
    }else if(result.equals("C")){
        ExecuteResult("UPDATE tblevent set total_cancelled=total_cancelled + 1 where eventid='"+eventid+"'");
    }
}%>


<%!public void RefundErrorBets( String arenaid, String currentkey){
    try{
        if(CountQry("tblfightbets", "arenaid='"+arenaid+"' and fightkey <> '"+currentkey+"'") > 0){
            ResultSet rst = null;
            rst = SelectQuery("SELECT eventid, operatorid, arenaid, (select arenaname from tblarena where arenaid=a.arenaid) as arena, accountid, sessionid, fightnumber, fightkey, accountname, sum(bet_amount) as totalbets FROM `tblfightbets` as a where arenaid='"+arenaid+"' and fightkey <> '"+currentkey+"' and dummy=0 group by fightkey,accountid");
            while(rst.next()){
                double amount = rst.getDouble("totalbets");
                String arena = rst.getString("arena");
                String eventid = rst.getString("eventid");
                String operatorid = rst.getString("operatorid");
                String accountid = rst.getString("accountid");
                String fullname = rst.getString("accountname");
                String sessionid = rst.getString("sessionid");
                String fightnumber = rst.getString("fightnumber");
                String fightkey = rst.getString("fightkey");
                
                //refund bets ExecuteSetScore(operatorid, sessionid, fightkey, accountid, fullname, "ADD", amount, "refund error bets (fight#"+fightnumber+"@"+arena+")", "SYSTEM");
                
                String event_desc = "Arena " +  arena + " - Fight #" + fightnumber;
                //SendResultNotification("Return Bets", accountid, "C", arena, fightnumber, "", event_desc, amount, 0, 0, true, "Your score is refunded due to error bet posting");

                if(CountQry("tblfightbets", "fightkey='"+fightkey+"' and accountid='"+accountid+"'") > 0){
                    ExecuteQuery("DELETE FROM tblfightbetserror where fightkey='"+fightkey+"' and accountid='"+accountid+"';");
                    ExecuteQuery("INSERT INTO tblfightbetserror (operatorid,accountid,accountname,banker,dummy,sessionid,appreference,arenaid,eventid,eventkey,fightkey,fightnumber,postingdate,transactionno,bet_choice,bet_amount,result,win,odd,win_amount,lose_amount,payout_amount,plasada,payback_rate,payback_total,winloss,datetrn,cancelled,cancelledreason) " 
                                + " SELECT operatorid,accountid,accountname,banker,dummy,sessionid,appreference,arenaid,eventid,eventkey,fightkey,fightnumber,postingdate,transactionno,bet_choice,bet_amount,result,win,odd,win_amount,lose_amount,payout_amount,plasada,payback_rate,payback_total,winloss,datetrn,cancelled,cancelledreason FROM tblfightbets where arenaid='"+arenaid+"' and fightkey='"+fightkey+"' and accountid='"+accountid+"'");
                    
                    ExecuteQuery("DELETE FROM tblfightbets where arenaid='"+arenaid+"' and fightkey='"+fightkey+"' and accountid='"+accountid+"';");
                }
            }
            rst.close();

            ExecuteQuery("DELETE FROM tblfightbets where arenaid='"+arenaid+"' and fightkey <> '"+currentkey+"' and dummy=1;");
        }
    }catch(SQLException e){
        logError("RefundErrorBets",e.toString());
    }
}%>

<%!public JSONObject FetchDummyBet(JSONObject mainObj, String accountid, String fightkey) {
    mainObj = DBtoJson(mainObj, "SELECT eventid,fightnumber,transactionno,bet_choice,bet_amount FROM tblfightbets where accountid='"+accountid+"' and fightkey='"+fightkey+"';");
    return mainObj;
 }
 %>

