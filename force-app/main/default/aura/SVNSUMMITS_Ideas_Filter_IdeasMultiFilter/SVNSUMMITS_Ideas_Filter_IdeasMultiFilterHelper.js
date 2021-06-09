({
    showMyIdeas : function(component, event, helper) {
        $A.get("e.c:SVNSUMMITS_Ideas_Filters_Event")
         .setParams(
             {
                 listId        : component.get('v.listId'),
                 searchMyIdeas : "Display My Ideas Only",
                 searchMyCommentedIdeas : 'empty',
                 searchMySubscribedIdeas : 'empty',
                 searchMyCompanyIdeas :'empty',
                 searchMyCompanyVotedIdeas : 'empty',
                 searchMyCompanyCommentedIdeas : 'empty',
                 searchMyCompanySubscribedIdeas : 'empty'
             })
         .fire();
    },

    showVoteByMeFilter : function(component, event, helper) {
        $A.get("e.c:SVNSUMMITS_Ideas_Filters_Event")
          .setParams(
              {
                  listId        : component.get('v.listId'),
                  searchMyIdeas : "Display My Voted Ideas Only",
                  searchMyCommentedIdeas : 'empty',
                  searchMySubscribedIdeas : 'empty',
                  searchMyCompanyIdeas :'empty',
                  searchMyCompanyVotedIdeas : 'empty',
                  searchMyCompanyCommentedIdeas : 'empty',
                  searchMyCompanySubscribedIdeas : 'empty'
              })
          .fire();
    },

    showIdeasCommentedByMeFilter : function(component, event, helper) {
        $A.get("e.c:SVNSUMMITS_Ideas_Filters_Event")
             .setParams(
             {
                 listId        : component.get('v.listId'),
                 searchMyCommentedIdeas : 'Display My Commented Ideas Only',
                 searchMyIdeas : 'empty',
                 searchMySubscribedIdeas : 'empty',
                 searchMyCompanyIdeas :'empty',
                 searchMyCompanyVotedIdeas : 'empty',
                 searchMyCompanyCommentedIdeas : 'empty',
                 searchMyCompanySubscribedIdeas : 'empty'
             })
         .fire();
    },

    showIdeasSubscribedByMeFilter : function(component, event, helper) {
        $A.get("e.c:SVNSUMMITS_Ideas_Filters_Event")
             .setParams(
                 {
                     listId        : component.get('v.listId'),
                     searchMySubscribedIdeas : 'Display My Subscribed Ideas Only',
                     searchMyCommentedIdeas : 'empty',
                     searchMyIdeas : 'empty',
                     searchMyCompanyIdeas :'empty',
                     searchMyCompanyVotedIdeas : 'empty',
                     searchMyCompanyCommentedIdeas : 'empty',
                     searchMyCompanySubscribedIdeas : 'empty'
                 })
             .fire();
    },

    myCompaniesIdeas : function(component, event, helper) {
        $A.get("e.c:SVNSUMMITS_Ideas_Filters_Event")
            .setParams(
                {
                     listId        : component.get('v.listId'),
                     searchMyCompanyIdeas :'Display My Company Ideas Only',
                     searchMyCompanyVotedIdeas : 'empty',
                     searchMyCompanyCommentedIdeas : 'empty',
                     searchMyCompanySubscribedIdeas : 'empty',
                     searchMySubscribedIdeas : 'empty',
                     searchMyCommentedIdeas : 'empty',
                     searchMyIdeas : 'empty'
                })
            .fire();
    },

    myCompaniesVotedIdeas : function(component, event, helper) {
        $A.get("e.c:SVNSUMMITS_Ideas_Filters_Event")
           .setParams(
               {
                   listId        : component.get('v.listId'),
                    searchMyCompanyIdeas : 'empty',
                    searchMyCompanyVotedIdeas : 'Display My Company Voted Ideas Only',
                    searchMyCompanyCommentedIdeas : 'empty',
                    searchMyCompanySubscribedIdeas : 'empty',
                    searchMySubscribedIdeas : 'empty',
                    searchMyCommentedIdeas : 'empty',
                    searchMyIdeas : 'empty'
               })
           .fire();
    },

    myCompaniesCommentedIdeas : function(component, event, helper) {
        $A.get("e.c:SVNSUMMITS_Ideas_Filters_Event")
            .setParams(
                {
                     listId        : component.get('v.listId'),
                     searchMyCompanyIdeas : 'empty',
                     searchMyCompanyVotedIdeas : 'empty',
                     searchMyCompanyCommentedIdeas : 'Display My Company Commented Ideas Only',
                     searchMyCompanySubscribedIdeas : 'empty',
                     searchMySubscribedIdeas : 'empty',
                     searchMyCommentedIdeas : 'empty',
                     searchMyIdeas : 'empty'
                })
            .fire();
    },

    myCompaniesSubscribedIdeas : function(component, event, helper) {
        $A.get("e.c:SVNSUMMITS_Ideas_Filters_Event")
            .setParams(
                {
                        listId        : component.get('v.listId'),
                        searchMyCompanyIdeas : 'empty',
                        searchMyCompanyVotedIdeas : 'empty',
                        searchMyCompanyCommentedIdeas : 'empty',
                        searchMyCompanySubscribedIdeas : 'Display My Company Subscribed Ideas Only',
                        searchMySubscribedIdeas : 'empty',
                        searchMyCommentedIdeas : 'empty',
                        searchMyIdeas : 'empty'
                })
            .fire();
    },

    emptyFilter : function(component, event, helper) {
        $A.get("e.c:SVNSUMMITS_Ideas_Filters_Event")
            .setParams(
                {
                        listId        : component.get('v.listId'),
                        searchMyCompanyIdeas : 'empty',
                        searchMyCompanyVotedIdeas : 'empty',
                        searchMyCompanyCommentedIdeas : 'empty',
                        searchMyCompanySubscribedIdeas : 'empty',
                        searchMySubscribedIdeas : 'empty',
                        searchMyCommentedIdeas : 'empty',
                        searchMyIdeas : 'No'
                })
            .fire();

    }

})