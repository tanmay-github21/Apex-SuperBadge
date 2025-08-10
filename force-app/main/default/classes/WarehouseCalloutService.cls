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
            map<string,list<object>> mp=new map<string,list<object>>(); 
            string typeof= (JSON.deserializeUntyped(response.getBody()) instanceof map<string,list<object>>)?'map<string,list<object>>':
            (JSON.deserializeUntyped(response.getBody()) instanceof map<string,object>)? 'map<string,object>':'type unknown';
            system.debug('Instance type'+'\t'+typeof);
            for(Object o:deserializedObjects){
                map<string,object>xrecord= (map<string,object>)o; 
                for(string loopvar:xrecord.keySet()){
                    string nk=loopvar.replaceAll('[_^]','');
                    if(!mp.containsKey(nk)) mp.put(nk, new list<object>());
                    mp.get(nk).add(xrecord.get(loopvar));
                    System.debug('Original string name and length'+'--'+loopvar+'--'+loopVar.length()+'\n'+
                                'Trimmed string name and length'+'\t'+nk+'--'+nk.length());
                }
            }
            method2(mp);
        }
    }
    public void method2(map<string,list<object>> passedMap){
        try{
             map<string,object> singleObjMap= new map<string,object>(); 
             for(string s:passedMap.keySet()){
                 list<object> objectList= passedMap.get(s);
                 if(!objectList.isEmpty())
                     singleObjMap.put(s,objectList[0]);
             }
            list<product2> sfrecords= new list<product2>([select name,warehouse_Sku__c,
                                      externalId,lifespan_Months__c,cost__c,
                                      maintenance_Cycle__c,replacement_Part__c,
                                      stockKeepingUnit, current_Inventory__c from Product2]);
            map<string,Product2> sfProductMap=new map<string,product2>();
            for(product2 loopProd:sfrecords)
                if(string.isNotBlank(loopProd.warehouse_Sku__c) && !sfProductMap.containsKey(loopProd.warehouse_SKu__c)){
                    sfProductMap.put(loopProd.Warehouse_SKU__c,loopProd);
                    System.debug(loopProd.name+'->'+'isnt blank and added to productmap');
                }
            string externalSku=string.valueof(singleObjMap.get('id'));
            SYstem.debug('External id key'+'\t'+externalSku);
            for(Product2 loopProd:sfrecords){
                if(string.isNotblank(loopProd.Warehouse_SKU__c) && (externalSku ==loopProd.Warehouse_SKU__c)){
                    System.debug('Update null check'+'\t'+loopProd.name);
                    Product2 up2=new Product2(); 
                    up2.Name=loopProd.name;
                    up2.ExternalId=externalSku;
                    up2.Operation__c='Update';
                    up2.Replacement_Part__c=true;
                    up2.StockKeepingUnit=string.valueof(singleObjMap.get('sku'));
                    double current= (loopProd.Current_Inventory__c <=0)?0:loopProd.Current_Inventory__c;
                    double consumed= double.valueof(string.valueof(singleObjMap.get('quantity'))); 
                    up2.Current_Inventory__c=(current-consumed ==0)?0:current-consumed; 
                    up2.Lifespan_Months__c=double.valueof(string.valueof(singleObjMap.get('lifespan')));
                    up2.Maintenance_Cycle__c=double.valueof(string.valueof(singleObjMap.get('maintenanceperiod'))); 
                    up2.Cost__c=decimal.valueof(string.valueof(singleObjMap.get('cost')));
                }
                else{
                    System.debug(singleObjMap.get('id')+'->->->-<-><->'+'Insert');
                }
            }
        }//try end
        catch(exception e){}
    }//method2 end  
}