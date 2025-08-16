<%!public void PusherPost(String event, JSONObject apiObj){          
    try {
        if(!GlobalPusherAppID.isEmpty()){
            Thread pusherTread = new Thread(new PusherTask(event, apiObj));
            pusherTread.start();
        }
        
    } catch (Exception e) {
        e.printStackTrace();
    }
}
%>

<%!public class PusherTask implements Runnable {
    private String event;
    private JSONObject apiObj;

    public PusherTask(String event, JSONObject apiObj) {
        this.event = event;
        this.apiObj = apiObj;
    }
    public void run() {
        PusherTrigger(event, apiObj);
    }
 }
 %>

<%!public void PusherTrigger(String event, JSONObject apiObj){          
    try {
        pusher.trigger(GlobalPusherAppChannel, Encrypt(event), apiObj);
    } catch (Exception e) {
        e.printStackTrace();
    }
}
%>
 