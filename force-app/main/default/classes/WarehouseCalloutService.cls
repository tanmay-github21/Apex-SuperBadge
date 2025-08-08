public class WarehouseCalloutService implements Queueable, database.AllowsCallouts{
	// deserialized response is a list<object> and each object is of type <string,Object>
    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    public void execute(QueueableContext context){
        list<object>objects2=new list<object>(); 
        list<product2> products;
        http http=new http();
        HttpRequest request=new HttpRequest(); 
        request.setEndPoint(WAREHOUSE_URL);
        request.setMethod('GET');
        string result=(Math.mod(2,2)==0)?'True':'False';
        map<string,List<Object>> payLoadMap= new map<string,list<object>>();
        HttpResponse response=http.send(request);
        if(response.getstatusCode() ==200){
            list<object> deserializedObjects=(list<object>)JSON.deserializeUntyped(response.getBody());
            boolean typeof= (json.deserializeUntyped(response.getBody())) instanceof map<string,list<object>>?true:false;
            system.debug('Instance type'+'\t'+typeof);
            for(Object o:deserializedObjects){
                map<string,object>xrecord= (map<string,object>)o; 
                for(string loops:xrecord.keySet()){
                    string k='PUT_YOUR_KEY_HERE';
                    System.debug('orig="' + k + '" len=' + k.length());
                    for(integer i=0; i<k.length();i++){
                        integer c= (integer)k.charAt(i);
                        System.debug(i + ' → code:' + c + ' char:"' + k.substring(i,i+1) + '"');
                    }
                }
            }
        }
    }
    public void method2(){
       
        
    } 
}