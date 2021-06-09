({
	doInit : function(component, event, helper) {
		helper.reputationEnabled(component);
        helper.doGetData(component);
        helper.getSitePrefix(component);
	},
    
    sortPosts : function(component, event, helper){
        helper.doSort("posts", "person.chatterActivity.postCount", component);
    },
 
 	sortComments : function(component, event, helper){
        helper.doSort("comments", "person.chatterActivity.commentCount", component);
    },

//	sortLikes : function(component, event, helper){
//        helper.doSort("likes", component);
//    },
    
    sortRank : function(component, event, helper){
        helper.doSort("rank", "person.reputation.reputationPoints", component);
    },
    
    sortPoints : function(component, event, helper){
        helper.doSort("points", "person.reputation.reputationPoints", component);
    }
})