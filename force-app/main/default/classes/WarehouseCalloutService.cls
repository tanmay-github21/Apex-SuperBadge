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
            string externalSku=string.valueof(singleObjMap.get('id'));
            SYstem.debug('External id key'+'\t'+externalSku);
            integer e=0;
            for(Product2 loopProd:sfrecords){
                
                string name=loopProd.name,warehouse= (string.isBlank(loopProd.Warehouse_SKU__c))?'empty':loopProd.Warehouse_SKU__c;
                decimal cost=(loopProd.Cost__c ==null)?0:loopProd.Cost__c;
                double lifePeriod=(loopProd.Lifespan_Months__c ==null)?0:loopProd.Lifespan_Months__c;
                double repairtime=(loopProd.Maintenance_Cycle__c ==null)?0:loopProd.Maintenance_Cycle__c;
                double count=(loopProd.Current_Inventory__c==null)?0:loopProd.Current_Inventory__c; 
                System.debug('Tempvar name'+'\t'+name+'\n'+
                            'Tempvar warehouse'+'\t'+warehouse+'\n'+
                            'Tempvar cost'+'\t'+cost+'\n'+
                            'Tempvar lifeperiod'+'\t'+lifePeriod+'\n'+
                            'Tempvar quantity'+'\t'+count+'\n'+
                            'Tempvar repairtime'+'\t'+repairtime);
                e++;
                if(e==4)break;
                if(warehouse !='empty' && externalSku ==warehouse){
                    System.debug(name+'\t'+warehouse+'\t'+'present in external system');
                }
                else {
                    System.debug(name+'\t'+warehouse+'\t'+'not in external system');
                }
                
            }
            //upsert upsertMap.values(); 
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