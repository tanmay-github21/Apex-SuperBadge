public class WarehouseCalloutService implements Queueable, database.AllowsCallouts{

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    public void execute(QueueableContext context){
        List<object> external_nonJSON_list;
        list<object>objects2=new list<object>(); 
        list<product2> products;
        System.debug('QueueClass execute method');
        http http=new http();
        HttpRequest request=new HttpRequest(); 
        request.setEndPoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response=http.send(request);
        map<string,list<object>> skuMap= new map <string,list<object>>();
        list<object> fieldValues=new list<object>(); 
        if(response.getStatusCode()==200){
            string jsonResponse=response.getBody();
            external_nonJSON_list=(list<object>)JSON.deserializeUntyped(jsonResponse);
            for(object o: external_nonJSON_list){
                String typeOf= (o instanceof map<string,List<object>>)? 'Its instance of map<string,list<object>':
                o instanceof list<object> ?'Its list<object>':'Type is unknown';
                System.debug('Instance of response received is'+'\t'+typeOf); 
                 map<string,object> external_object_Map= (map<string,object>)o;
                 map<string,object> fieldMap= new map<string,object>();//this will be added to the list
                fieldMap.put('quantity',Double.valueof(string.valueof(external_Object_Map.get('quantity'))));
                fieldMap.put('name',string.valueof(external_Object_Map.get('name')));
                fieldMap.put('maintenanceperiod',double.valueof(string.valueof(external_Object_Map.get('maintenanceperiod'))));
                fieldMap.put('lifespan',double.valueof(string.valueof(external_Object_Map.get('lifespan'))));
                fieldMap.put('cost',decimal.valueof(string.valueof(external_Object_Map.get('cost'))));
                fieldMap.put('sku',string.valueof(external_Object_Map.get('sku')));
                string externalId=string.valueof(external_Object_Map.get('_id'));
                if(!skuMap.containsKey(externalId)){
                    skuMap.put(externalId, new list<map<string,object>>());
                }
                skuMap.get(externalId).add(fieldMap);
           }
            for(string s:skuMap.keySet()){
                System.debug('KeySet'+'\t'+s); 
            }
            for(object o: skuMap.values()) System.debug('Values'+'\t'+o);
            
       }
       method2(skuMap);
    }
    public static void method2(map<string, list<object>>mapPassedFrom1){
        integer q1=0, q2=0; 
        list<product2> eprd=new list<product2>();
        eprd=[select name, warehouse_Sku__c, current_Inventory__c,replacement_Part__c from product2]; 
        for(product2 p:eprd){
            if(string.isNotEmpty(p.Warehouse_SKU__c) && mapPassedFrom1.containsKey(p.Warehouse_SKU__c)){
                list<object>objects=(list<object>)mapPassedFrom1.get('externalId');
                for(object o1:objects){
                    if(o1 instanceof map<string,list<object>>){System.debug('instance of objects');}
                }
            }
            else{}
        } //loop through Products
    }//end of method2
}//end of class