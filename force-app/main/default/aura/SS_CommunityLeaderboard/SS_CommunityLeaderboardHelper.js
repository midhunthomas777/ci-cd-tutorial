({
	doSort : function(type, filter, component) {
        let element = component.find(type);
        let people = component.get('v.people');
        
        function multiIndex(obj,is){
            return is.length ? multiIndex(obj[is[0]],is.slice(1)) : obj
        }
        
        function pathIndex(obj,is){
            return multiIndex(obj,is.split('.'))
        }

        if($A.util.hasClass(element, "asc")){
            people.sort(function (a, b) {
                return pathIndex(b, filter) - pathIndex(a, filter);
            });

            $A.util.addClass(element, 'desc');
        	$A.util.removeClass(element, 'asc');
        }else{
            people.sort(function (a, b) {
                return pathIndex(a, filter) - pathIndex(b, filter);
            });

            $A.util.removeClass(element, 'desc');
        	$A.util.addClass(element, 'asc');
        }

		component.set('v.people', people);
	},

    doGetData : function(component){
        let action = component.get('c.getData');
        let hideInternal = component.get("v.hideInternal");
        let recordNum = component.get("v.numberOfRecords");

        action.setParams({
            'hideInternal': hideInternal,
            'recordNum': recordNum
        });

        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS"){
                let data = JSON.parse(response.getReturnValue());
                let rankedData;
                let rank = 1;
                let nextrank = rank;
                let previouspoints;
                for (let i = 0, len = data.length; i < len; i++) {
  					console.log(data[i]);
                    if(rankedData === undefined)
                    {
                        
                        rankedData = [{rank:rank, person:data[i]}];
                        console.log("broken");
                        nextrank++;
                        previouspoints = data[i].reputation.reputationPoints;
                    }
                    else 
                    {
                        if(data[i].reputation.reputationPoints !== previouspoints) rank = nextrank;
                        rankedData.push({rank:rank, person:data[i]});
                        nextrank++;
                        previouspoints = data[i].reputation.reputationPoints;
                    }
				}
                component.set('v.people', rankedData);
            }
        });
        $A.enqueueAction(action);
    },

	reputationEnabled : function (component) {
		let action = component.get('c.isReputationEnabled');

		action.setCallback(this, function(response){
			let state = response.getState();
			if (state === 'SUCCESS') {
				component.set('v.reputationEnabled', response.getReturnValue());
			}
		});

		$A.enqueueAction(action);
	},

   	getSitePrefix: function(component) {
    	let action = component.get("c.getSitePrefix");
        action.setCallback(this, function(actionResult) {
            let sitePath = actionResult.getReturnValue();
            //console.log("featured user sitePath",sitePath);
            component.set("v.sitePath", sitePath);
            // component.set("v.sitePrefix", sitePath.replace("/s",""));
		});
        $A.enqueueAction(action);
    }
});