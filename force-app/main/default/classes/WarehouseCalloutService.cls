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
        set<string> externalIds=mapExecuteMethod.keySet();
        map<string,product2>existingProductmap= new map<string,product2>(); 
        for(product2 loopp: [select name,warehouse_Sku__c,current_Inventory__c from Product2 where replacement_part__c=true and 
                            warehouse_Sku__c!='' and warehouse_Sku__c!=null])  existingProductMap.put(loopp.warehouse_Sku__c,loopp);
        system.debug(existingProductMap.keySet().size());
        list<product2> products2bUpserted= new list<product2>(); 
        for(string exId : mapExecuteMethod.keySet()){
            list<object> externalObject=mapExecuteMethod.get(exId); 
            for(object o1:externalObject){
                map<string,object> externalData=(map<string,object>)o1; 
                double extqnty= double.valueof(string.valueof(externalData.get('quantity')));
                System.debug('Hello');
                SYstem.debug((externalData.get('quantity') instanceof Double)? 'Double':'Not Double');
                /*if(existingProductmap.containsKey(exId)){
                    product2 existingProduct=existingProductmap.get(exId); 
                    double quantity= (existingProduct.Current_Inventory__c !=Null) ? existingProduct.Cost__c: 0.0;
                    existingProduct.Current_Inventory__c = (quantity-extqnty <0)?0:quantity-extqnty; 
                    existingProduct.Warehouse_SKU__c=exId;
                    existingProduct.StockKeepingUnit=string.valueof(externalData.get('sku'));
                    existingProduct.ExternalId=exId;
                    existingProduct.Cost__c=decimal.valueof(string.valueof(externalData.get('cost')));
                    existingProduct.Maintenance_Cycle__c=double.valueof(string.valueof(externalData.get('maintenancePeriod'))); 
                    existingProduct.Lifespan_Months__c=double.valueof(string.valueof(externalData.get('lifespan'))); 
                    products2bUpserted.add(existingProduct); 
                }//map has the external id*/
                //for(product2 p:products2bUpserted)System.debug('Products ready to be upserted'+'\t'+p); 
            } //looping through the list of objects
        } //looping through map.keySet()
    }
}