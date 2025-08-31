<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xGameModule.jsp" %>

<%
   JSONObject mainObj =new JSONObject();
   JSONObject apiObj = new JSONObject();
try{

    String x = Decrypt(request.getParameter("x"));
    String deviceid = request.getParameter("deviceid");
    String sessionid = request.getParameter("sessionid");

    if(x.isEmpty() || deviceid.isEmpty() || sessionid.isEmpty()){
        out.print(Error(mainObj, globalInvalidRequest, "404"));
        return;

    }else if(isControllerRemoved(deviceid)){
        out.print(Status(mainObj, "BLOCKED", "Your controller was removed by administrator!", "403"));
        return;

    }else if(isControllerBlocked(deviceid)){
        out.print(Status(mainObj, "BLOCKED", "Your controller was removed by administrator!", "403"));
        return;
    }
 
    if(x.equals("change_fight_status")){ 
        String eventid = request.getParameter("eventid");
        String status = request.getParameter("status");
        EventInfo event = new EventInfo(eventid, true);

        String arenaid = event.arenaid;
        String eventkey = event.eventkey;
        String fightkey = event.fightkey;
        String postingdate = event.postingdate;
        String fightnumber = event.fightnumber;
        
        if(event.status.equals("closed") || event.status.equals("result")){
            if(!status.equals("cancelled")){
                mainObj.put("fightkey", fightkey);
                mainObj = getEventInfo(mainObj, eventid);
                mainObj = getBetSummary(mainObj, fightkey);
                out.print(Success(mainObj, "request returned valid"));
                return;
            }
        }

        boolean betWatcherExecuted = false;
        if(status.equals("cancelled")){
            ExecuteCancelledFight(sessionid, deviceid, arenaid, eventid, eventkey, fightkey, postingdate, fightnumber, "");
            apiObj = api_result_info(apiObj, eventid);
            
            String new_plasada = GenerateNewPlasada();
            ExecuteResult("UPDATE tblgeneralsettings set plasada_rate='"+new_plasada+"'"); 
        }else{
            ExecuteResult("update tblevent set current_status='"+status+"' where eventid='"+eventid+"'");
        }

        if(status.equals("closed")){ /*trigger bet watcher*/
            GeneralSettings gs = new GeneralSettings();
            FightDetails fd = new FightDetails(fightkey);
            double totalBetMeron = fd.totalMeron;
            double totalBetWala = fd.totalWala;

            double totalAllBets = 0; double ratioMeron = 0; double ratioWala = 0;
            double oddMeron = 0; double oddWala = 0;

            if(totalBetMeron != 0 || totalBetWala != 0){
                totalAllBets = totalBetMeron + totalBetWala;
                ratioMeron =  totalAllBets / totalBetMeron;
                ratioWala =  totalAllBets / totalBetWala;
                
                oddMeron = ratioMeron-(ratioMeron * GlobalPlasadaRate);
                oddWala = ratioWala-(ratioWala * GlobalPlasadaRate);

                if(gs.enableBetWatcher && isBetWatcherAvailable(gs.betwacherid)){
                    if(oddWala <= gs.betwatcherodds){ /*execute bet watcher for meron*/
                        double randomBet = Double.parseDouble(RandomBetPercentage()) / 100;
                        double betDifference = (totalBetWala - totalBetMeron);
                        double betToAdd = betDifference * randomBet;

                        if(betToAdd <= gs.betwatchermaxamount){
                            RandomDummyAccount dummy = new RandomDummyAccount();
                            ExecuteRecordAutoBet(eventid, fightkey, fightnumber, totalBetMeron, totalBetWala, betDifference, "M", randomBet, betToAdd);
                            ExecutePostBet(eventid, sessionid, sessionid, "", gs.betwacherid, dummy.dummyname, gs.betwacherid, "M",Val(betToAdd), true, false);
                            betWatcherExecuted = true;
                        }
                    }

                    if(oddMeron <= gs.betwatcherodds){ /*execute bet watcher for wala*/
                        double randomBet = Double.parseDouble(RandomBetPercentage()) / 100;
                        double betDifference = (totalBetMeron - totalBetWala);
                        double betToAdd = betDifference * randomBet;

                        if(betToAdd <= gs.betwatchermaxamount){
                            RandomDummyAccount dummy = new RandomDummyAccount();
                            ExecuteRecordAutoBet(eventid, fightkey, fightnumber, totalBetMeron, totalBetWala, betDifference, "W", randomBet, betToAdd);
                            ExecutePostBet(eventid, sessionid, sessionid, "", gs.betwacherid, dummy.dummyname, gs.betwacherid, "W", Val(betToAdd), true, false);
                            betWatcherExecuted = true;
                        }
                    }
                }

                if(gs.enablebetbalancer){ /*execute bet balancer*/
                    boolean isMeronFound = isLargeBetExists(fightkey, "M" ,gs.betbalanceramount);
                    boolean isWalaFound = isLargeBetExists(fightkey, "W", gs.betbalanceramount);

                    if(isMeronFound && isWalaFound){
                    }else{
                        Random rand = new Random();
                        int method1 =  rand.nextInt(10 - 1) + 1;
                        int method2 =  rand.nextInt(10 - 1) + 1;

                        if(method1 % 2 == 0){
                            ExecuteBetBalancer(eventid, fightkey, sessionid, isMeronFound, isWalaFound, gs.dummy_account_1, gs.dummy_account_2);
                        }else{
                            if(method2 % 2 == 0){
                                ExecuteBetBalancer(eventid, fightkey, sessionid, isMeronFound, isWalaFound, gs.dummy_account_1, gs.dummy_account_2);
                            }
                        }
                    }
                }
            }
        }
        
        UpdateFightNumber(fightkey, fightnumber);
        mainObj.put("fightkey", fightkey);
        mainObj = getEventInfo(mainObj, eventid);
        mainObj = getBetSummary(mainObj, fightkey);
        out.print(Success(mainObj, "request returned valid"));
        

        apiObj.put("plasada", GlobalPlasadaRate);
        apiObj = api_fight_summary(apiObj, fightkey);
        apiObj = api_event_info(apiObj, eventid);
        PusherPost(eventid, apiObj);

        RefundErrorBets(arenaid,fightkey);

    }else if(x.equals("post_win")){ 
        String eventid = request.getParameter("eventid");
        String fightkey = request.getParameter("fightkey");
        String result = request.getParameter("result");

        EventInfo event = new EventInfo(eventid, true);
        if(event.status.equals("closed")){
            ExecuteResult("update tblevent set current_status='result', fight_result='"+result+"' where eventid='"+eventid+"'");
        }

        mainObj = getEventInfo(mainObj, eventid);
        out.print(Success(mainObj, "request returned valid"));

        apiObj = api_event_info(apiObj, eventid);
        PusherPost(eventid, apiObj);

    }else if(x.equals("post_cancel")){ 
        String eventid = request.getParameter("eventid");
    
        EventInfo event = new EventInfo(eventid, true);
        if(event.status.equals("result")){
            ExecuteResult("update tblevent set current_status='closed', fight_result='' where eventid='"+eventid+"'");
        }
       
        mainObj = getEventInfo(mainObj, eventid);
        out.print(Success(mainObj, "request returned valid"));

        apiObj = api_event_info(apiObj, eventid);
        PusherPost(eventid, apiObj);

    }else if(x.equals("post_result")){ 
        try{
        String eventid = request.getParameter("eventid");
        String appreference = request.getParameter("appreference");
        
        String newFightkey = "";

        EventInfo event = new EventInfo(eventid, true);
        String result = event.result;
        String arenaid = event.arenaid;
        String eventkey = event.eventkey;
        String fightkey = event.fightkey;
        String postingdate = event.postingdate;
        String fightnumber = event.fightnumber;

        if(event.status.equals("result")){
            boolean isMeron = (result.equals("M") ? true : false);
            boolean isDraw = (result.equals("D") ? true : false);
            boolean isWala = (result.equals("W") ? true : false);

            boolean isCancelled = false;
            String cancelledReason = "";

            int totaltrn = CountQry("tblfightbets", "fightkey='"+fightkey+"' and dummy=0 and banker=0");
            ExecuteResult("update tblfightbets set win=0 where fightkey='"+fightkey+"'");
            
            String referenceno = getSystemSeriesID("series_result", 7);
            LogFightResult(referenceno, arenaid, eventid, eventkey, fightkey, fightnumber, postingdate, result);

            FightDetails fd = new FightDetails(fightkey);
            int bettorMeron = fd.countMeron;
            int bettorDraw = fd.countDraw;
            int bettorWala = fd.countWala;
            double totalBetMeron = fd.totalMeron;
            double totalBetDraw = fd.totalDraw;
            double totalBetWala = fd.totalWala;

            double totalAllBets = 0; double ratioMeron = 0; double ratioWala = 0;
            double oddMeron = 0; double oddWala = 0;
            
            if(isDraw){
                ExecuteResult("update tblfightbets set win=1 where fightkey='"+fightkey+"' and bet_choice='D'");
            }

            if(totalBetMeron > 0 && totalBetWala > 0){
                totalAllBets = totalBetMeron + totalBetWala;
                ratioMeron =  totalAllBets / totalBetMeron;
                ratioWala =  totalAllBets / totalBetWala;
                
                oddMeron = ratioMeron-(ratioMeron * GlobalPlasadaRate);
                oddWala = ratioWala-(ratioWala * GlobalPlasadaRate);

                if(oddMeron < 1.3 || oddWala < 1.3){  
                    isCancelled = true;
                    cancelledReason = (oddMeron < 1.3 ? "Meron" : "Wala") + " odds is 0.2%";
                }else{
                    isCancelled = false;
                    ExecuteResult("update tblfightbets set win=1 where fightkey='"+fightkey+"' and bet_choice='"+result+"'");
                }
            }else{
                isCancelled = true;
                cancelledReason = "No bets from other side";
            }
        
            ExecuteComputeBets(fightkey, result, isDraw, isCancelled, cancelledReason,  oddMeron-1, oddWala-1);
            if(isDraw){
                ExecuteReturnBetsDraw(fightkey, sessionid, referenceno);
            }else if(isCancelled){
                ExecuteReturnBetsCancelled(fightkey, sessionid, referenceno, false, cancelledReason);
            }

            FightSummary fs = new FightSummary(fightkey);
            double totalPlayerBets = fs.totalMeron + fs.totalDraw + fs.totalWala;
            double totalProfit = (totalPlayerBets - fs.totalPayout) / 2;
            double netProfit = totalProfit;

            double bonus_rate = 0;
            double total_bonus = 0;
            double total_ac_bonus = 0;
            double total_pb_bonus = 0;

            if(!isDraw){
                if(GlobalPlasadaRate > GlobalPlasadaBase){
                    if(totalProfit > 0){
                        Random rand = new Random();
                        int method =  rand.nextInt(10 - 1) + 1;

                        if(method % 2 == 0){
                            bonus_rate = Double.parseDouble(RandomBonusPercentage()) / 100;
                            total_bonus = (totalProfit * bonus_rate);
                            total_ac_bonus = total_bonus / 2;
                            total_pb_bonus = total_bonus / 2;
                            netProfit = totalProfit - total_bonus;
                        }
                    }
                }
            }

            ExecuteResult("DELETE from tblfightsummary where fightkey='"+fightkey+"'");
            ExecuteResult("INSERT into tblfightsummary set " 
                        + " arenaid='"+arenaid+"',"
                        + " eventid='"+eventid+"', "
                        + " eventkey='"+eventkey+"', "
                        + " fightkey='"+fightkey+"', "
                        + " fightnumber='"+fightnumber+"', "
                        + " plasada="+GlobalPlasadaRate+", " 
                        + " postingdate='"+postingdate+"', "
                        + " bettors_meron='"+fs.countMeron+"', "
                        + " bettors_draw='"+fs.countDraw+"', "
                        + " bettors_wala='"+fs.countWala+"', "
                        + " total_meron='"+fs.totalMeron+"', "
                        + " total_draw='"+fs.totalDraw+"', "
                        + " total_wala='"+fs.totalWala+"', "
                        + " total_bets='"+ totalPlayerBets +"', "
                        + " odd_meron=ROUND("+(oddMeron-1)+",2), "
                        + " odd_wala=ROUND("+(oddWala-1)+",2), "
                        + " result='"+result+"', "
                        + " win_amount="+fs.totalWinAmount+", " 
                        + " lose_amount="+fs.totalLoseAmount+", " 
                        + " payout_amount="+fs.totalPayout+", " 
                        + " total_profit="+ totalProfit +", " 
                        + " bonus_rate="+ bonus_rate +", " 
                        + " total_bonus="+ total_bonus +", " 
                        + " total_ac_bonus="+ total_ac_bonus +", " 
                        + " total_pb_bonus="+ total_pb_bonus +", " 
                        + " net_profit="+ netProfit +", " 
                        + " datetrn=current_timestamp, "
                        + " trnby='"+deviceid+"'");

            //ExecuteACBonus(eventid, total_ac_bonus);
            ExecutePBBonus(fightkey, totalPlayerBets, total_pb_bonus);
            ExecuteUpdateWinloss(fightkey);
            
            //finalizing entries and transfer log entries
            BackupBetsTable(fightkey);
            int done_bets = CountQry("tblfightbets2", "fightkey='"+fightkey+"'");
        
            if(totaltrn != done_bets){
                mainObj.put("status", "ERROR");
                mainObj.put("message","An error encounter while executing result confirmation. record bets backup did not successfull! Please contact your system admin");
                mainObj.put("errorcode", "100");
                out.print(mainObj);
                return;
            }
            
            NotifyPlayersResult(fightkey, eventid, fightnumber, sessionid, referenceno);
            
            //start new fight
            newFightkey = UUID.randomUUID().toString();
            String newFightNumber = String.valueOf(Integer.parseInt(fightnumber) + 1);
            ExecuteResult("DELETE from tblfightbets where fightkey='"+fightkey+"'"); 
            ExecuteResult("UPDATE tblevent set current_status='standby',fightkey='"+eventid+"-"+newFightNumber+"-"+newFightkey+"',fightnumber='"+newFightNumber+"' where eventid='"+eventid+"'"); 

            ExecuteReleaseBonus(eventid, sessionid, appreference);
        }
        
        String new_plasada = GenerateNewPlasada();
        ExecuteResult("UPDATE tblgeneralsettings set plasada_rate='"+new_plasada+"'"); 

        mainObj = getEventInfo(mainObj, eventid);
        out.print(Success(mainObj, "request returned valid"));

        apiObj = api_event_info(apiObj, eventid);
        apiObj = api_result_info(apiObj, eventid);
        PusherPost(eventid, apiObj);
        
        RefundErrorBets(arenaid, newFightkey);

        }catch (Exception e){
            logError("controller-x-game",e.getMessage());
        }

    }else if(x.equals("get_player_bets")){ 
        String fightkey = request.getParameter("fightkey");

        mainObj.put("status", "OK");
        mainObj = getPlayerBets(mainObj, fightkey);
        mainObj.put("message","request returned valid");
        out.print(mainObj);

    }else{
        out.print(Error(mainObj, globalInvalidRequest, "404"));
        
    }
}catch (Exception e){
      out.print(Error(mainObj, e.toString(), "400"));
      logError("controller-x-game",e.toString());
}
%>

 <%!public boolean isBetWatcherAvailable(String betwacherid) {
    return CountQry("tbldummyaccount", "accountid='"+betwacherid+"'") > 0;
  }
 %>

<%!public void ExecuteCancelledFight(String sessionid, String deviceid, String arenaid, String eventid, String eventkey, String fightkey, String postingdate, String fightnumber, String reason){
    ExecuteResult("update tblevent set current_status='cancelled' where eventid='"+eventid+"'");

    int totaltrn = CountQry("tblfightbets", "fightkey='"+fightkey+"'");
            
    String referenceno = getSystemSeriesID("series_result", 7);
    LogFightResult(referenceno, arenaid, eventid, eventkey, fightkey, fightnumber, postingdate, "C");

    LogCancelledFight(arenaid, eventid, eventkey, fightkey, fightnumber, postingdate, deviceid);
    ExecuteReturnBetsCancelled(fightkey,sessionid,referenceno, true, reason);
    
    if(totaltrn > 0){
        ExecuteResult("update tblfightbets set cancelled=1, cancelledreason='Cancelled fight" + (reason.length() > 0 ? " (" + reason + ")" : "") + "', win_amount=0, lose_amount=0 where fightkey='"+fightkey+"'");
        BackupBetsTable(fightkey);
        ExecuteResult("DELETE from tblfightbets where fightkey='"+fightkey+"'"); 
    }

    int newFightNumber = Integer.parseInt(fightnumber) + 1;
    String newFightkey = UUID.randomUUID().toString();
    ExecuteResult("update tblevent set current_status='standby',fightkey='"+eventid+"-"+newFightNumber+"-"+newFightkey+"',fightnumber='"+newFightNumber+"' where eventid='"+eventid+"'");
}%>

<%!public void BackupBetsTable(String fightkey) {
    if(CountQry("tblfightbets", "fightkey='"+fightkey+"'") > 0){
        ExecuteResult("DELETE from tblfightbets2 where fightkey='"+fightkey+"'");
        ExecuteResult("DELETE from tblfightbetsdummy where fightkey='"+fightkey+"'");

        ExecuteResult("INSERT INTO tblfightbets2 (operatorid,accountid,accountname,banker,dummy,sessionid,appreference,arenaid,eventid,eventkey,fightkey,fightnumber,postingdate,transactionno,bet_choice,bet_amount,result,win,odd,win_amount,lose_amount,payout_amount,plasada,payback_rate,payback_total,winloss,datetrn,cancelled,cancelledreason) " 
            + " SELECT operatorid,accountid,accountname,banker,dummy,sessionid,appreference,arenaid,eventid,eventkey,fightkey,fightnumber,postingdate,transactionno,bet_choice,bet_amount,result,win,odd,win_amount,lose_amount,payout_amount,plasada,payback_rate,payback_total,winloss,datetrn,cancelled,cancelledreason FROM tblfightbets where fightkey='"+fightkey+"' and dummy=0 and banker=0");

        ExecuteResult("INSERT INTO tblfightbetsdummy (operatorid,accountid,accountname,banker,dummy,sessionid,appreference,arenaid,eventid,eventkey,fightkey,fightnumber,postingdate,transactionno,bet_choice,bet_amount,result,win,odd,win_amount,lose_amount,payout_amount,plasada,payback_rate,payback_total,winloss,datetrn,cancelled,cancelledreason) " 
            + " SELECT operatorid,accountid,accountname,banker,dummy,sessionid,appreference,arenaid,eventid,eventkey,fightkey,fightnumber,postingdate,transactionno,bet_choice,bet_amount,result,win,odd,win_amount,lose_amount,payout_amount,plasada,payback_rate,payback_total,winloss,datetrn,cancelled,cancelledreason FROM tblfightbets where fightkey='"+fightkey+"' and (dummy=1 or banker=1)");
    }
}
%>

<%!public void UpdateFightNumber(String fightkey, String fightnumber){
    ExecuteResult("UPDATE tblfightbets set fightnumber='"+fightnumber+"' where fightkey='"+fightkey+"'"); 
}%>

<%!public void ExecuteRecordAutoBet(String eventid, String fightkey, String fightnumber, double totalBetMeron, double totalBetWala, double betDifference, String choice, double autoBet, double betToAdd){
    ExecuteResult("insert into tblbetwatcher set eventid='"+eventid+"',  fightkey='"+fightkey+"',fightnumber='"+fightnumber+"',total_meron='"+totalBetMeron+"',total_wala='"+totalBetWala+"',total_difference='"+betDifference+"',auto_bet_choice='"+choice+"',auto_bet_percent='"+autoBet+"',auto_bet_amount='"+betToAdd+"', datetrn=current_timestamp");
}%>

<%!public void ExecuteBetBalancer(String eventid, String fightkey, String sessionid, boolean isMeronFound, boolean isWalaFound, String dummy_account_1, String dummy_account_2){
    RandomDummyAccount dummy = new RandomDummyAccount();
    FinalBets finalBets = new FinalBets(fightkey);
    
    if(isMeronFound){
        if(finalBets.oddMeron > 1.7){
            double random = Double.parseDouble(RandomBetBalancer()) / 100;
            double balancer = finalBets.totalMeron * random;
            ExecutePostBet(eventid, sessionid, sessionid, "", dummy_account_1, dummy.dummyname, dummy_account_1, "M", Val(balancer), false, true);
        }
    }

    if(isWalaFound){
        if(finalBets.oddWala > 1.7){
            double random = Double.parseDouble(RandomBetBalancer()) / 100;
            double balancer = finalBets.totalWala * random;
            ExecutePostBet(eventid, sessionid, sessionid, "", dummy_account_2, dummy.dummyname, dummy_account_2,  "W", Val(balancer), false, true);
        }
    }
   
}%>

<%!public boolean isLargeBetExists(String fightkey, String bet_choice, double amount) {
    boolean found = false;
    try{
        ResultSet rst = SelectQuery("select sum(bet_amount) as total_bets from tblfightbets where fightkey='"+fightkey+"' and bet_choice='"+bet_choice+"' and dummy=0 and banker=0 group by accountid");
        while(rst.next()){
            double totalbets = rst.getDouble("total_bets");
            if(totalbets >= amount){
                found = true;
            }
        }
        rst.close();
    }catch(SQLException e){
        logError("module-islarge_bet_exists",e.toString());
    }
    return found;
  }
 %>


 