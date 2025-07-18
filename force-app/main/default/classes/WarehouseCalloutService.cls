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
                 map<string,object> external_object_Map= (map<string,object>)o;
                 string externalId= (string)external_object_Map.get('_id');
                 double quantity= (double)external_object_Map.get('quantity');
                 string pname= (string)external_object_Map.get('name');
                 integer mntPeriod= (integer)external_object_Map.get('maintenanceperiod');
                 double lifespan= (double)external_object_Map.get('lifespan');
                 double cost= (double)external_object_Map.get('cost');
                 string sku= (string)external_object_Map.get('sku');
                 fieldValues.add(quantity);
                 fieldValues.add(pname);
                 fieldValues.add(mntPeriod);
                 fieldValues.add(lifespan);
                 fieldValues.add(cost);
                 fieldValues.add(sku);
                 skuMap.put(externalId,fieldValues);
         }
            
       }
       method2(skuMap);
    }
    public static void method2(map<string, list<object>>mapPassedFrom1){
        list<product2> sfProducts=new list<product2>([select warehouse_sku__c,name from product2 where
                                                     replacement_Part__c=true]);
        for(product2 loopProd: sfProducts){
            if(string.isNotEmpty(loopProd.Warehouse_SKU__c) && mapPassedFrom1.containsKey(loopProd.Warehouse_SKU__c)){
                System.debug(loopProd.name+'\t'+'was found in the map'+'\t'+loopProd.Warehouse_SKU__c);
                list<object>objectList= (list<object>)mapPassedFrom1.get(loopProd.Warehouse_SKU__c);
                system.debug('ObjectList size'+'\t'+objectList.size());
                system.debug('ObjectList[0]'+'\t'+objectList[0]);
                for(object loopObject: objectList){
                    if(loopObject instanceof Map<string,list<object>>){
                        System.debug(loopObject+'\t'+'instance of Map<string,list<Object>>');
                        Map<string,list<object>> objectMap= (map<string,List<object>>)loopObject;
                    }//fghty nska
                    else System.debug(loopObject+'\t'+'not instance of Map<string,list<object>');
                } //For loop to check if object is instance of Map<string, list<object>>
                //map<string,list<object>> objectMap= (map<string,list<object>>)objectList[0];
            } //product warehouse isnt empty and map contains it
            else {
                //System.debug(loopProd.name+'\t'+'Isnt in map');
            } //product warehouse is empty and isn't contained in the map
        } //loop through salesforce products
    }//method2 closed
}//class closed