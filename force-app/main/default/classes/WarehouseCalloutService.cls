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
        List<product2> upserts=new list<Product2>();
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
            integer i,k,j=0;
            set<string> existingSKU=new set<string>(); 
            for(Product2 p2:products){
                string sku=p2.Warehouse_SKU__c;
                if(string.isNotBlank(sku) && externalProductMap.containskey(sku)){
                    System.debug(p2.name+'\t'+'Update');
                    Product2 up2=new product2();
                    string nameString=string.valueof(externalProductMap.get('name'));
                    up2.Name=(string.isNotBlank(string.valueof(externalProductMap.get('name'))))?string.valueof(externalProductMap.get('name')):'Name is blank';
                    up2.ExternalId=string.valueof(externalProductMap.get('name'));
                    double existing=p2.Current_Inventory__c;
                    double consumed=(string.isNotBlank(string.valueof(externalProductMap.get('quantity'))))?double.valueof(string.valueof(externalProductMap.get('quantity'))):0.0;
                    up2.Current_Inventory__c=(existing-consumed <0)?0.0:existing-consumed; 
                    up2.Cost__c=(string.isNotBlank(string.valueof(externalProductMap.get('cost')))?decimal.valueof(string.valueof(externalProductMap.get('cost'))):0.0);
                    up2.Maintenance_Cycle__c=(string.isNotBlank(string.valueof(externalProductMap.get('maintenanceperiod')))?double.valueof(string.valueof(externalProductMap.get('maintenanceperiod'))):0.0);
                    up2.Lifespan_Months__c=(string.isNotBlank(string.valueof(externalProductMap.get('lifespan')))?double.valueof(string.valueof(externalProductMap.get('lifespan'))):0.0);
                    up2.StockKeepingUnit=(string.isNotEmpty(string.valueof(externalProductMap.get('sku')))?string.valueof(externalProductMap.get('sku')):'');
                    up2.Operation__c='Update';
                    up2.Replacement_Part__c=true;
                    upserts.add(up2);
                    System.debug(p2.Name+'\t'+'update size'+'\t'+upserts.size());
                } //string isnt blank and is in map
                else{
                    Product2 ip2=new product2();
                    System.debug(p2.name+'\t'+'insert');
                    string trimedName='';
                    ip2.name=(string.isNotBlank(string.valueof(externalProductMap.get('name'))))?string.valueof(externalProductMap.get('name')):'Name is blank';
                    ip2.Warehouse_SKU__c=(string.isNotBlank(string.valueof(externalProductMap.get('_id'))))?string.valueof(externalProductMap.get('_id')):null;
                    ip2.ExternalId=(string.isNotBlank(string.valueof(externalProductMap.get('_id'))))?string.valueof(externalProductMap.get('_id')):null;
                    ip2.Current_Inventory__c=(string.isNotBlank(string.valueof(externalProductMap.get('quantity'))))?double.valueof(string.valueof(externalProductMap.get('quantity'))):0.0;
                    ip2.Cost__c=(string.isNotBlank(string.valueof(externalProductMap.get('cost')))?decimal.valueof(string.valueof(externalProductMap.get('cost'))):0.0);
                    ip2.Maintenance_Cycle__c=(string.isNotBlank(string.valueof(externalProductMap.get('maintenanceperiod')))?double.valueof(string.valueof(externalProductMap.get('maintenanceperiod'))):0.0);
                    ip2.Lifespan_Months__c=(string.isNotBlank(string.valueof(externalProductMap.get('lifespan')))?double.valueof(string.valueof(externalProductMap.get('lifespan'))):0.0);
                    ip2.StockKeepingUnit=(string.isNotEmpty(string.valueof(externalProductMap.get('sku')))?string.valueof(externalProductMap.get('sku')):'');
                    ip2.Operation__c='Insert';
                    ip2.Replacement_Part__c=true;
                    upserts.add(ip2);
                    System.debug(p2.name+'\t'+'Insert size'+'\t'+upserts.size());
                } //string is either blank or isnt in map
            }
            upsert upserts;
            System.debug('Final upserts size'+upserts.size());
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