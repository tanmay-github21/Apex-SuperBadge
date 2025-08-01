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
             externalProductMap.put(recid,internalMap); 
        }
        try{
            set<string> existingSKU=new set<string>(); 
            for(Product2 p2:products){
                string sku=p2.Warehouse_SKU__c;
                if(string.isNotBlank(sku) && externalProductMap.containsKey(sku)){
                    SYstem.debug(p2.name+'\t'+'Has value in map as'+'\t'+p2.Warehouse_SKU__c); 
                    map<string,object> singleObjMap= externalProductMap.get(sku); 
                    Product2 tempProd= new Product2(); 
                    tempProd.Warehouse_SKU__c=string.valueof(singleObjMap.get('_id'));
                    tempProd.Replacement_Part__c=true;
                    double existing=(p2.Current_Inventory__c==null)? 0.0:p2.Current_Inventory__c;
                    double consumed=(singleObjMap.get('quantity')==null)?0.0:double.valueof(string.valueof(singleObjMap.get('quantity')));
                    tempProd.Current_Inventory__c=(existing-consumed <0)?0.0:existing-consumed; 
                    SYstem.debug('From Map Quantity'+'\t'+consumed+'\n'+
                                'Record quantity'+'\t'+existing+'\n'+ 'Updated Quantity'+'\t'+tempProd.Current_Inventory__c);
                    
                    
                    tempProd.name= (singleObjMap.get('name')==null)? '':string.valueof(singleObjMap.get('name'));
                    tempProd.Maintenance_Cycle__c=(singleObjMap.get('maintenanceperiod')==null)? 0.0:double.valueof(string.valueof(singleObjMap.get('maintenanceperiod')));
                    tempProd.Lifespan_Months__c=(singleObjMap.get('lifespan')==null)? 0.0:double.valueof(string.valueof(singleObjMap.get('lifespan')));
                    tempProd.Cost__c=decimal.valueof(string.valueof(singleObjMap.get('cost')));
                    updates.add(tempProd);
                    existingSKU.add(string.valueof(singleObjMap.get('_id')));
                    SYstem.debug('External ID Set at the end has value as'+'\t'+existingSKU);
                }//map has the value
                else{
                    for(string extId:externalProductMap.keySet()){
                        if(!existingSKU.contains(extid)){
                            System.debug('Insert Product');
                            map<string,Object>insertMap=externalProductMap.get(extId);
                            Product2 insertP=new product2();
                            insertP.Name=(insertMap.get('name')==null)?p2.name:string.valueof(insertMap.get('name'));
                            insertP.Warehouse_SKU__c=string.valueof(insertMap.get('_id'));
                            insertp.Replacement_Part__c=true;
                            insertp.Current_Inventory__c=(insertMap.get('quantity')==null)? 0.0:double.valueof(string.valueof(insertMap.get('quantity')));
                            insertP.name=string.valueof(insertMap.get('name'));
                            insertP.Maintenance_Cycle__c=(insertMap.get('maintenanceperiod')==null)? 0.0:double.valueof(string.valueof(insertMap.get('maintenanceperiod')));
                            //insertp.Lifespan_Months__c=(insertMap.get('lifespan')==null)? 0.0:double.valueof(string.valueof(insertMap.get('lifespan')));
                            insertp.Cost__c=(insertMap.get('cost')==null)? 0.0:decimal.valueof(string.valueof(insertMap.get('cost')));
                            insertP.Operation__c='Insert';
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
                         'Cause of error'+'\t'+e.getCause()+'\n'+
                         'StackTrace'+'\t'+e.getStackTraceString()+'\n'+
                        'Error Message'+'\t'+e.getMessage()); 
        } // catch exception ends
    } //Method 2 completes 
}