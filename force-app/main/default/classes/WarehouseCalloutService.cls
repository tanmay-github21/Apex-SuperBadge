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
            payLoadMap.put('externalList',deserializedObjects); 
        }
        System.debug(payLoadMap);
        method2(payLoadMap);
    }
    public void method2(map<string,list<Object>>payloadMap){
        List<product2> upserts=new list<Product2>();
        List<product2> products= new list<product2>([select name, 
                                                     warehouse_Sku__c,
                                                     current_Inventory__c,
                                                     cost__c,
                                                     lifespan_Months__c,
                                                     maintenance_Cycle__c, externalId from product2 where replacement_Part__c=true]);
        set<string>sfrecords=new set<string>();// contains sf records where warehouse isnt blank
        set<string>externalrecords= new set<string>();//contains all records in external system
        list<object> externalList=payLoadMap.get('externalList');
        Map<string, map<string,object>>trimmedExternalMap= new map<String,map<string,object>>();
        for(object obj:externalList){
              map<string,object> rawMap= (map<string,object>)obj;
              map<string,object> cleanedMap= new map<string,object>();
             for(string key:rawMap.keySet()){
                 cleanedMap.put(key.trim(),rawMap.get(key));
             }
            string sku=string.valueof(cleanedMap.get('_id')).trim();
            system.debug('SKU Value'+'\t'+sku);
            trimmedExternalMap.put(sku,cleanedMap);
            map<string,object>externalData= trimmedExternalMap.get(sku);
            integer i=0,j=0,k=0;
            try{
                for(product2 p2:products){
                    if(string.isnotblank(p2.Warehouse_SKU__c)){
                        sfrecords.add(p2.Warehouse_SKU__c);
                        system.debug(p2.name+'\t'+'warehouse isnt blank'+'\t'+sfrecords.size());
                    }
                }
                for(string s:trimmedExternalMap.keySet()){
                    map<string,object> singleMap= trimmedExternalMap.get(s);
                    Product2 up2= new Product2();
                    if(sfrecords.contains(s)){
                        System.debug('Salesforce warehouse id matches with external data');
                    }
                }
            }
            catch(exception r){
                System.debug('Error Occured on line'+'\t'+r.getLineNumber()+'\n'+
                            'Type of error'+'\t'+r.getTypeName()+'\n'+
                            'Reason for error'+'\t'+r.getCause()+'\n'+
                            'Error Message'+'\t'+r.getMessage()+'\n'+
                            'Stack trace string'+'\t'+r.getStackTraceString());
            }
        } //loop though object list
        
    } //Method 2 completes 
}