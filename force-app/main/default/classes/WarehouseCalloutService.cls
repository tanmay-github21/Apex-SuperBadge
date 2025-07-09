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
        if(response.getStatusCode()==200){
            string jsonResponse=response.getBody();
            external_nonJSON_list=(list<object>)JSON.deserializeUntyped(jsonResponse);
            for(object o: external_nonJSON_list){
                 map<string,object> external_object_Map= (map<string,object>)o;
                 Boolean checked= (Boolean)external_object_Map.get('replacement');
                 string uniqueId= (string)external_object_Map.get('_id');
                     list<object> fieldValues= new List<object>();
                	 fieldValues.add(external_object_Map.get('replacement'));
                     fieldValues.add(external_object_Map.get('quantity'));
                     fieldValues.add(external_object_Map.get('name'));
                     fieldValues.add(external_object_Map.get('maintenanceperiod'));
                     fieldValues.add(external_object_Map.get('lifespan'));
                     fieldValues.add(external_object_Map.get('cost'));
                	 fieldValues.add(external_object_Map.get('sku')); 	
                     skuMap.put(uniqueId,fieldValues);
                 }
            	 system.debug('Map size'+'\t'+skuMap.keySet().size());	
            }
        else System.debug('Status Code isnt 200'+'\t'+response.getStatusCode());
        //ID jobId = System.enqueueJob(new WarehouseCalloutService());
        // System.debug('Job ID: ' + jobId);
       // sfdx force:data:soql:query -q "SELECT Id FROM ApexLog ORDER BY StartTime DESC LIMIT 1" -t | tail -n +3 | head -n 1 | xargs -I {} sfdx force:apex:log:get --logid {} --outputdir ./logs && cat ./logs/*.log | grep -E 'USER_DEBUG|VARIABLE_ASSIGNMENT'
       updateRecords(skuMap);
    } //method1 end
    public void updateRecords(map<string,list<object>>mapPassedFromMethod1){
        System.debug('Entered into Method2');
        list<product2>records2bUpdated, records2bInserted;
        list <product2> queriedRecords= new list<product2>([select Name, warehouse_Sku__c, 
                                                            ExternalId,
                                                            Current_Inventory__c,
                                                            Lifespan_Months__c,
                                                            Maintenance_Cycle__c,
                                                            StockKeepingUnit
                                                            from product2 
                                                            where Replacement_Part__c=true]);
        for(product2 ploop: queriedRecords){
            if(string.isNotBlank(ploop.Warehouse_SKU__c)){
                system.debug(ploop.name+'\t'+ploop.Warehouse_SKU__c);
                if(mapPassedFromMethod1.containsKey(ploop.Warehouse_SKU__c)){
                    System.debug('ID matched for external system');
                    //map<string,object> productMap= (map<string,object>)mapPassedFromMethod1.get('_id');
                    list<object>objectList=mapPassedFromMethod1.get(ploop.Warehouse_SKU__c);
                    map<string,object>productMap=(map<string,object>)objectList[0];
                    product2 tempproduct=new product2();
                    tempproduct.Cost__c=(double)productMap.get('cost');
                    tempproduct.ExternalId=(string)productMap.get('_id');
                    System.debug('External ID'+'\t'+tempproduct.ExternalId+'\n'+'Cost'+tempproduct.Cost__c);
                }
            }
            else if(string.isBlank(ploop.Warehouse_SKU__c)){
                System.debug(ploop.Name+'\t'+'has either a null or empty sku'); 
            }
        } 
    }
} //class ends 
        
        
    
        //System.debug('Products Retreived From Salesforce'+'\t'+salesforce_Products_List.size());
        //list<product2> newProducts= new list<product2>(); 
        //for(product2 loopVar: salesforce_Products_List){}