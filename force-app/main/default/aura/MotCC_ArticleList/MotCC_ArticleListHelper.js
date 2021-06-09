/**
 * Created by tricia.igoe on 4/9/20.
 */

({
   getTheArticleList: function(component, event, helper) {
        var action = component.get("c.grabArticleList");
        action.setParams({
            topicId : component.get("v.topicId")
        });
        action.setCallback(this, function(response) {
            console.log(response.getState());
            if (response.getState() == "SUCCESS" ) {
                let data = response.getReturnValue();
                console.log(data);
                if(data.results) {
                    for(let i = 0; i < data.results.length; i++) {
                        //data.results[i].titleUrl = '/css/s/article/' + data.results[i].UrlName;
                        data.results[i].UrlName = '/css/s/article/' + data.results[i].UrlName;
                        console.log(data.results[i]);
                    }
                }
                console.log(data.results);
                component.set("v.data", data.results);
                component.set("v.allData", data.results);
            }
            else {
                console.log(response);
            }
        });
        $A.enqueueAction(action);
    },
    getTopicId: function (component, event, helper) {
        var urlString = window.location.href;
        console.log(urlString);
        let urlStrings = urlString.split('/');
        let topicName = urlStrings.pop();
        let topicId = urlStrings.pop();
        component.set("v.topicId", topicId);
        console.log(component.get("v.topicId", topicId));
    },
    setTheColumns: function (component, event, helper) {
       let columns = [
           {label: 'Article Title', fieldName: 'UrlName', type: 'url', sortable: true,
               typeAttributes: {
                   label: {fieldName: 'Title'}
           }},
           {label: 'Article Summary', fieldName: 'Summary', type: 'text', sortable: true, wrapText: true},
           {label: 'Date Published', fieldName: 'LastPublishedDate', sortable: true, type: 'date'},
           {label: 'Version', fieldName: 'VersionNumber', type: 'number', sortable: true, cellAttributes: { alignment: 'left' }}

       ];
       console.log(columns);
       component.set("v.columns", columns);

    },
    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.data");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse));
        component.set("v.data", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ? function(x) {return primer(x[field])} : function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    searchList: function (component, event, helper) {
        let queryTerm = component.find('enter-search').get('v.value');
        console.log('Searched for "' + queryTerm + '"!');
        let allData = component.get("v.allData");
        let newData = [];
        if(queryTerm === '' || queryTerm === ' ') {
            newData = allData;
        } else {
            for(let i = 0; i < allData.length; i++) {
                console.log(allData[i]);
                let title = allData[i].Title.toLowerCase();
                if(queryTerm) {
                    queryTerm = queryTerm.toLowerCase();
                }
                if(title.indexOf(queryTerm)>-1){
                    newData.push(allData[i]);
                    console.log('added', newData);
                } else if(allData[i].Summary) {
                    let summary = allData[i].Summary.toLowerCase();
                    if(summary.indexOf(queryTerm)>-1) {
                        newData.push(allData[i]);
                        console.log('added', newData);
                    }
                }
                console.log(newData);
            }
        }
        console.log(newData);
        component.set("v.data", newData);
   }
});