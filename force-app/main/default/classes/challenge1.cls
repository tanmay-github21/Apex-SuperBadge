public with sharing class challenge1 {
    public static void method1(list<case> newList, map<id,Case> oldMap){
        list<case>updatedCases=new list<case>();
        list<case>followupCases=new list<case>();
        map<string, integer> minimumDateMap= method2(newList);
        set<ID> updatedCaseIds= new map <Id,case>(newList).keySet();
        System.debug('From Apex Class'+'\t'+'updatedCaseIds size'+'\t'+updatedCaseIds.size());
        updatedCases=[Select vehicle__c, (select equipment__c from Equipment_Maintenance_Items__r) from case WHERE ID IN:updatedCaseIds];
        For(case temp:updatedCases)
            System.debug('From Apex Class Equipment Size'+'\t'+temp.Equipment_Maintenance_Items__r.size());
    }
    public static map<string,integer> method2(list<case> miniumDateCaseList){
        
        return null;
    }
}