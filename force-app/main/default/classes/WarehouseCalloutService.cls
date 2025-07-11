public class WarehouseCalloutService implements Queueable, database.AllowsCallouts{

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    public void execute(QueueableContext context){
        List<object> external_nonJSON_list;
        list<product2> products;
        System.debug('Hello from the Queueable class');
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
                 map<string,object> external_object_Map= (map<string,object>)o;
                 object o1=external_object_Map.get('quantity');
                 string uniqueId= (string)external_object_Map.get('_id');
                     fieldValues.add(external_object_Map.get('quantity'));
                     fieldValues.add(external_object_Map.get('name'));
                     fieldValues.add(external_object_Map.get('maintenanceperiod'));
                     fieldValues.add(external_object_Map.get('lifespan'));
                     fieldValues.add(external_object_Map.get('cost'));
                	 fieldValues.add(external_object_Map.get('sku')); 	
                     skuMap.put(uniqueId,fieldValues);
                 }
            
            for(object o1:fieldValues){
                if(o1 instanceof Double) System.debug('o1 instance of double'+'\t'+o1); 
                else if (o1 instanceof string)  System.debug('o1 instance of string'+'\t'+o1);
                else if (o1 instanceof Integer) System.debug('o1 instance of integer'+'\t'+o1);
                else if (o1 instanceof Boolean) System.debug('o1 instance of Boolean'+'\t'+o1);
                else System.debug('instance of cant be determined'+'\t'+o1);
            }
            	 
       }
        method2(skuMap);
    }
    public static void method2(map<string, list<object>>mapPassedFrom1){
        list<product2> sfProducts=new list<product2>([select warehouse_sku__c,name from product2 where
                                                     replacement_Part__c=true]);
        for(product2 loopProd: sfProducts){
            if(string.isEmpty(loopProd.Warehouse_SKU__c) && mapPassedFrom1.containsKey(loopProd.Warehouse_SKU__c)){
                System.debug(loopProd.name+'\t'+'was found in the map'+'\t'+loopProd.Warehouse_SKU__c);
                list<object>objectList= (list<object>)mapPassedFrom1.get(loopProd.Warehouse_SKU__c);
                system.debug('ObjectList size'+'\t'+objectList.size());
                
            } //product warehouse isnt empty and map contains it
            else {
                System.debug(loopProd.name+'\t'+'Isnt in map');
            } //product warehouse is empty and isn't contained in the map
        } //loop through salesforce products
    }//method2 closed
}//class closed