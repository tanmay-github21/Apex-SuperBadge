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
        HttpResponse response=http.send(request);
        map<string,list<object>> skuMap= new map <string,list<object>>();
        list<object> fieldValues=new list<object>(); 
        if(response.getStatusCode()==200){
            list<object> external_nonJSONList= (list<object>)json.deserializeUntyped(response.getBody());
            list<object> internalList= new list<object>(); 
            for(object o: external_nonJSONList){
                map<string,Object> externalMap= (map<string,object>)o; 
                string identifier= string.valueof(externalMap.get('_id'));
                double quantity= double.valueof(string.valueof(externalMap.get('quantity'))); 
                string name= string.valueof(externalMap.get('name'));
                double maintenancePeriod= double.valueof(string.valueof(externalMap.get('maintenanceperiod')));
                double lifespan=double.valueof(string.valueof(externalMap.get('lifespan')));
                decimal cost= decimal.valueof(string.valueof(externalMap.get('cost')));
                string sku= string.valueof(externalMap.get('sku')); 
                internalList.add(quantity);
                internalList.add(name);
                internalList.add(maintenancePeriod);
                internalList.add(lifespan);
                internalList.add(cost);
                internalList.add(sku);
                skuMap.put(identifier,internalList);
            } //loop through objects
        }//status code is 200
        method2(skuMap);     
    }
    public void method2(map<string,list<object>>mapExecuteMethod){
        List<product2> products=new list<product2>();
	    products=[select name, warehouse_Sku__c from product2 where replacement_Part__c=true];
        for(Product2 p2: products){
            if(string.isNotEmpty(p2.Warehouse_SKU__c) && mapExecuteMethod.containsKey(p2.Warehouse_SKU__c)){
                for(String value: mapExecuteMethod.keySet()){
                        
                }
            } // map conntains the key
            else {
                
            } //map doesn't contains key
        }
    } //method2
        
}