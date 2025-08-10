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
                    /*System.debug('Original string name and length'+'--'+loopvar+'--'+loopVar.length()+'\n'+
                                'Trimmed string name and length'+'\t'+nk+'--'+nk.length());*/
                }
            }
            method2(mp);
        }
    }
    public void method2(map<string,list<object>> passedMap){
        try{
             map<string,object> singleObjMap= new map<string,object>(); 
             map<string,product2> upsertMap= new map<string,product2>();
             set<string> warehouseIds= new set<string>(); 
             //creating singleobjmap
             if(passedMap.containskey('id')){
                 list<object> skulist=passedMap.get('id');
                 System.debug('Object list size'+'\t'+skulist.size());
                 integer rcount=skuList.size();
                 for(integer i=0; i<rcount;i++){
                     object skuObj= skuList[i];
                     string warehouseId=string.valueof(skuObj).trim(); 
                     warehouseIds.add(warehouseId); 
                     map<string,object> rowMap=new map<string,object>();
                     for(string colName:passedMap.keySet()){
                         List<object>colValues=passedMap.get(colName);
                         if(i <colValues.size())
                             rowMap.put(colname,colValues[i]);
                     }
                     singleObjMap.put(warehouseId,rowMap);
                     for(string col:singleObjMap.keyset()) System.debug('singleObjectMap keyset'+'\t'+col);
                     System.debug('singleObjectMap values'+'\t'+singleObjMap.values());//
                 } 
             }
             list<product2> sfrecords= new list<product2>([select name,warehouse_Sku__c,
                                      externalId,lifespan_Months__c,cost__c,
                                      maintenance_Cycle__c,replacement_Part__c,
                                      stockKeepingUnit, current_Inventory__c from Product2]);
             for(product2 loopProd:sfrecords){
                 string warehouseId=(string.isBlank(loopProd.Warehouse_SKU__c)?'empty':loopProd.Warehouse_SKU__c);
                 if(warehouseId !='empty' && string.valueof(singleObjMap.get('id'))==warehouseId){
                     SYstem.debug('Update');
                     
                 }
             }
            //upsert command
        }//try end
        catch(exception e){
            System.debug('Exception occured at line number'+'\t'+e.getLineNumber()+'\n'+
                        'Exception type'+'\t'+e.getTypeName()+'\n'+
                        'Error message'+'\t'+e.getMessage()+'\n'+
                        'Cause of error'+'\t'+e.getCause()+'\n'+
                        'Stack Trace'+'\t'+e.getStackTraceString());
        }
    }//method2 end  
}