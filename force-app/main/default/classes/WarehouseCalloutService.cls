public class WarehouseCalloutService implements Queueable, database.AllowsCallouts{

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    public void execute(QueueableContext context){
        List<object> productRecords;
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
            productRecords=(list<object>)JSON.deserializeUntyped(jsonResponse);
            for(object o: productRecords){
                 map<string,object> records= (map<string,object>)o;
                 Boolean checked= (Boolean)records.get('replacement');
                 string sku= (string)records.get('sku');
                     list<object> fieldValues= new List<object>();
                	 fieldValues.add(records.get('_id'));
                     fieldValues.add(records.get('replacement'));
                     fieldValues.add(records.get('quantity'));
                     fieldValues.add(records.get('name'));
                     fieldValues.add(records.get('maintenanceperiod'));
                     fieldValues.add(records.get('lifespan'));
                     fieldValues.add(records.get('cost'));
                     skuMap.put(sku,fieldValues);
                 }
            }
        else System.debug('Status Code isnt 200'+'\t'+response.getStatusCode());
        //ID jobId = System.enqueueJob(new WarehouseCalloutService());
        // System.debug('Job ID: ' + jobId);
       // sfdx force:data:soql:query -q "SELECT Id FROM ApexLog ORDER BY StartTime DESC LIMIT 1" -t | tail -n +3 | head -n 1 | xargs -I {} sfdx force:apex:log:get --logid {} --outputdir ./logs && cat ./logs/*.log | grep -E 'USER_DEBUG|VARIABLE_ASSIGNMENT'
       updateRecords(skuMap);
    } //method1 end
    public void updateRecords(map<string,list<object>>processedMap){
        System.debug('Hello from updateRecords Method');
        list<product2> existingProducts=new list<product2>([select 
                                                           Replacement_Part__c, 
                                                           Current_Inventory__c,
                                                           name,
                                                           Maintenance_Cycle__c,
                                                           Lifespan_Months__c,
                                                           cost__c,
                                                           Warehouse_SKU__c from product2 where warehouse_SKU__c!='']); 
        list<product2> newProducts= new list<product2>(); 
        for(product2 op2: existingProducts){
            string existingSKU= op2.warehouse_SKU__c; 
            if(processedMap.containsKey(existingSKU)){}
        }
        
    } //end of updateRecords or method2
   
}