({
    getAccounts : function(component, helper){
        component.set("v.loadSpinner", true);    
        var MNC = component.get("v.motorolaCustomerList"); 
        component.set("v.AccountData", MNC);
        var pageSize = component.get("v.pageSize");
        component.set("v.totalRecords", component.get("v.AccountData").length);
        component.set("v.startPage",0);
        component.set("v.endPage",pageSize-1);
        var PaginationList = [];
        for(var i=0; i< pageSize; i++){
            if(component.get("v.AccountData").length> i){
                PaginationList.push(component.get("v.AccountData")[i]);
            }
        }
        component.set('v.PaginationList', PaginationList);
        component.set("v.loadSpinner", false);
    },
    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.AccountData");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        var pageSize = component.get("v.pageSize");
        component.set("v.totalRecords", data.length);
        component.set("v.startPage",0);
        component.set("v.endPage",pageSize-1);
        var PaginationList = [];
        for(var i=0; i< pageSize; i++){
            if(data.length> i){
                PaginationList.push(data[i]);
            }
        }
        component.set('v.PaginationList', PaginationList);
       // component.set("v.PaginationList", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x.hasOwnProperty(field) ? (typeof x[field] === 'string' ? x[field].toLowerCase() : x[field]) : 'aaa')} :
        function(x) {return x.hasOwnProperty(field) ? (typeof x[field] === 'string' ? x[field].toLowerCase() : x[field]) : 'aaa'};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {            
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    next : function(component, event){
        /*var current = component.get("v.currentPage");    
        var dTable = component.find("accountTable");
        current = current + 1;
        component.set("v.currentPage",current);*/
         var sObjectList = component.get("v.AccountData");
         var end = component.get("v.endPage");
         var start = component.get("v.startPage");
         var pageSize = component.get("v.pageSize");
         var Paginationlist = [];
         var counter = 0;
         for(var i=end+1; i<end+pageSize+1; i++){
             if(sObjectList.length > i){
                 Paginationlist.push(sObjectList[i]);
             }
             counter ++ ;
         }
         start = start + counter;
         end = end + counter;
         component.set("v.startPage",start);
         component.set("v.endPage",end);
         component.set('v.PaginationList', Paginationlist);
     },
    previous : function(component, event){   
        /*var current = component.get("v.currentPage");
        var dTable = component.find("accountTable");
        current = current - 1; 
        component.set("v.currentPage",current);*/
        var sObjectList = component.get("v.AccountData");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                Paginationlist.push(sObjectList[i]);
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    }
})