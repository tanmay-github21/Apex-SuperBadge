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
        method2(payLoadMap);
    }
    public void method2(map<string,list<Object>>payloadMap){
        List<product2> updates=new list<Product2>();
        List<product2> products= new list<product2>([select name, 
                                                     warehouse_Sku__c,
                                                     current_Inventory__c,
                                                     cost__c,
                                                     lifespan_Months__c,
                                                     maintenance_Cycle__c, externalId from product2 where replacement_Part__c=true]);
        list<object> externalList=payLoadMap.get('externalList');
        Map<string, map<string,object>> externalProductMap= new map<String,map<string,object>>();
        for(Object o: externalList){
             map<string,object> internalMap= (map<string,object>)o; 
             string recid=string.valueof(internalMap.get('_id'));
             System.debug('External Record Id'+'\t'+recid); 
             externalProductMap.put(recid,internalMap); 
        }
        try{
            set<string> existingSKU=new set<string>(); 
            for(Product2 p2:products){
                string sku=p2.Warehouse_SKU__c;
                if(string.isNotBlank(sku) && externalProductMap.containsKey(sku)){
                    System.debug(p2.name+'\t'+sku+'\t'+'is in the map');
                    map<string,object> singleObjMap= externalProductMap.get(sku); 
                    Product2 tempProd= new Product2(); 
                    tempProd.Cost__c= decimal.valueof(string.valueof(singleObjMap.get('cost'))); 
                    tempProd.ExternalId=string.valueof(singleObjMap.get('_id'));
                    double existing= (p2.Current_Inventory__c==null)? 0.0:p2.Current_Inventory__c;
                    System.debug(p2.Name+'\t'+'is in map'+'\t'+existing); 
                    double consumed=double.valueof(string.valueof(singleObjMap.get('quantity')));
                    double updatedQ= (existing-consumed <0)? 0.0: existing-consumed; 
                    tempProd.Current_Inventory__c=updatedQ; 
                    tempProd.Maintenance_Cycle__c=double.valueof(string.valueof(singleObjMap.get('maintenanceperiod')));
                    tempProd.Lifespan_Months__c=double.valueof(string.valueof('lifespan')); 
                    tempProd.Replacement_Part__c=true;
                    tempProd.operation__c='Updated';
                    updates.add(tempProd);
                    existingSKU.add(tempProd.Warehouse_SKU__c);
                    SYstem.debug(existingSKU);
                }//map has the value
                else{
                    for(string extId:externalProductMap.keySet()){
                        if(!existingSKU.contains(extid)){
                            System.debug('Insert Product');
                            map<string,Object>insertMap=externalProductMap.get(extId);
                            Product2 insertP=new product2();
                            insertP.Warehouse_SKU__c=string.valueof(insertMap.get('_id'));
                            insertp.Replacement_Part__c=true;
                            insertp.Current_Inventory__c=double.valueof(string.valueof(insertMap.get('quantity')));
                            insertP.name=string.valueof(insertMap.get('name'));
                            insertP.Maintenance_Cycle__c=double.valueof(string.valueof(insertMap.get('maintenanceperiod')));
                            insertp.Lifespan_Months__c=double.valueof(string.valueof(insertMap.get('lifespan')));
                            insertp.Cost__c=decimal.valueof(string.valueof(insertMap.get('cost')));
                            insertp.operation__c='Insert';
                            updates.add(insertP);
                        }
                    }
                }//map doesn't have the value
                upsert updates;
                SYstem.debug('Sizeof operation'+'\t'+updates.size());
            }
        }//try block ends
        
        catch(exception e){
            SYstem.debug('Erorr Occured with following details'+'\n'+
                         'Error name'+'\t'+e.getTypeName()+'\n'+
                         'Error line'+'\t'+e.getLineNumber()+'\n'+
                         'Cause of error'+'\t'+e.getCause()); 
        } // catch exception ends
    } //Method 2 completes 
}