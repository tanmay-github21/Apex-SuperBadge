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
        System.debug('Hello from updateRecords Method');
        list<product2> salesforce_Products_List=new list<product2>([select 
                                                           Replacement_Part__c, 
                                                           Current_Inventory__c,
                                                           name,
                                                           Maintenance_Cycle__c,
                                                           Lifespan_Months__c,
                                                           cost__c,
                                                           Warehouse_SKU__c from product2 where replacement_part__c=true]); 
        System.debug('Products Retreived From Salesforce'+'\t'+salesforce_Products_List.size());
        list<product2> newProducts= new list<product2>(); 
        for(product2 loopVar: salesforce_Products_List){
            string ext_Warehouse_SKU= loopVar.Warehouse_SKU__c;
            if(mapPassedFromMethod1.containsKey(ext_Warehouse_SKU)){
                System.debug('External System has the warehouse id and it is'+'\t'+ext_Warehouse_SKU);
                system.debug('External system _id field value'+'\t'+ext_Warehouse_SKU); 
                //list<object>objectList=mapPassedFromMethod1.get('sku');
                //map <string,object> existingRecords= (map<string,object>)objectList[0];
                //system.debug('Quantity record'+'\t'+existingRecords.get('quantity'));
                //system.debug('SKU value'+'\t'+existingRecords.get('sku'));
            }
            //else {
              //  System.debug('External system doesnt have the id');
            //}
            
        }
        
    } //end of updateRecords or method2
   
}