({
    doInit : function(component, event, helper) {

        if(component.get('v.requireSelectionAccountIdeasFilter')) {

             if (component.get('v.myCompaniesIdeas')) {
                  $A.get("e.c:SVNSUMMITS_Ideas_Filters_Event")
                     .setParams(
                         {
                              listId        : component.get('v.listId'),
                              searchMyCompanyIdeas :'Display My Company Ideas Only',
                              searchMyCompanyVotedIdeas : 'empty',
                              searchMyCompanyCommentedIdeas : 'empty',
                              searchMyCompanySubscribedIdeas : 'empty'
                         })
                     .fire();

                  component.set('v.filterValue', $A.get("$Label.c.ss_idea_label_myCompanyIdeas"));

             } else if (component.get('v.myCompaniesVotedIdeas')) {
                 $A.get("e.c:SVNSUMMITS_Ideas_Filters_Event")
                        .setParams(
                            {
                                listId        : component.get('v.listId'),
                                 searchMyCompanyIdeas : 'empty',
                                 searchMyCompanyVotedIdeas : 'Display My Company Voted Ideas Only',
                                 searchMyCompanyCommentedIdeas : 'empty',
                                 searchMyCompanySubscribedIdeas : 'empty'
                            })
                        .fire();

                 component.set('v.filterValue', $A.get("$Label.c.ss_idea_label_myCompanyVotedIdeas"));

             } else if (component.get('v.myCompaniesCommentedIdeas')) {
                 $A.get("e.c:SVNSUMMITS_Ideas_Filters_Event")
                     .setParams(
                         {
                              listId        : component.get('v.listId'),
                              searchMyCompanyIdeas : 'empty',
                              searchMyCompanyVotedIdeas : 'empty',
                              searchMyCompanyCommentedIdeas : 'Display My Company Commented Ideas Only',
                              searchMyCompanySubscribedIdeas : 'empty'
                         })
                     .fire();

                 component.set('v.filterValue', $A.get("$Label.c.ss_idea_label_myCompanyCommentedIdeas"));

             } else if (component.get('v.showMyIdeas')) {
                 $A.get("e.c:myCompaniesSubscribedIdeas")
                     .setParams(
                         {
                                 listId        : component.get('v.listId'),
         			            searchMyCompanyIdeas : 'empty',
                                 searchMyCompanyVotedIdeas : 'empty',
                                 searchMyCompanyCommentedIdeas : 'empty',
                                 searchMyCompanySubscribedIdeas : 'Display My Company Subscribed Ideas Only'
                         })
                     .fire();

                 component.set('v.filterValue', $A.get("$Label.c.ss_idea_label_myCompanySubscribedIdeas"));
             } else {
                   $A.get("e.c:SVNSUMMITS_Ideas_Filters_Event")
                       .setParams(
                           {
                                listId        : component.get('v.listId'),
                                searchMyCompanyIdeas :'Display My Company Ideas Only',
                                searchMyCompanyVotedIdeas : 'empty',
                                searchMyCompanyCommentedIdeas : 'empty',
                                searchMyCompanySubscribedIdeas : 'empty'
                           })
                       .fire();

                    component.set('v.filterValue', $A.get("$Label.c.ss_idea_label_myCompanyIdeas"));

             }

        }

    },

    handleSelectedFilter : function(component, event, helper) {

        helper.debug(component, '---- Account Ideas Multiple On Filter  ----');

        let filter = component.get("v.filterValue");
        helper.debug(component, "    Filter: " + filter);

        if (filter === $A.get("$Label.c.ss_idea_label_myCompanyIdeas")) {
             $A.get("e.c:SVNSUMMITS_Ideas_Filters_Event")
                .setParams(
                    {
                         listId        : component.get('v.listId'),
                         searchMyCompanyIdeas :'Display My Company Ideas Only',
                         searchMyCompanyVotedIdeas : 'empty',
                         searchMyCompanyCommentedIdeas : 'empty',
                         searchMyCompanySubscribedIdeas : 'empty'
                    })
                .fire();
        } else if (filter === $A.get("$Label.c.ss_idea_label_myCompanyVotedIdeas")) {
            $A.get("e.c:SVNSUMMITS_Ideas_Filters_Event")
                   .setParams(
                       {
                           listId        : component.get('v.listId'),
                            searchMyCompanyIdeas : 'empty',
                            searchMyCompanyVotedIdeas : 'Display My Company Voted Ideas Only',
                            searchMyCompanyCommentedIdeas : 'empty',
                            searchMyCompanySubscribedIdeas : 'empty'
                       })
                   .fire();

        } else if (filter === $A.get("$Label.c.ss_idea_label_myCompanyCommentedIdeas")) {
            $A.get("e.c:SVNSUMMITS_Ideas_Filters_Event")
                .setParams(
                    {
                         listId        : component.get('v.listId'),
                         searchMyCompanyIdeas : 'empty',
                         searchMyCompanyVotedIdeas : 'empty',
                         searchMyCompanyCommentedIdeas : 'Display My Company Commented Ideas Only',
                         searchMyCompanySubscribedIdeas : 'empty'
                    })
                .fire();
        } else if (filter === $A.get("$Label.c.ss_idea_label_myCompanySubscribedIdeas")) {
            $A.get("e.c:SVNSUMMITS_Ideas_Filters_Event")
                .setParams(
                    { 
                            listId        : component.get('v.listId'),
    			            searchMyCompanyIdeas : 'empty',
                            searchMyCompanyVotedIdeas : 'empty',
                            searchMyCompanyCommentedIdeas : 'empty',
                            searchMyCompanySubscribedIdeas : 'Display My Company Subscribed Ideas Only'
                    })
                .fire();
        } else {
            $A.get("e.c:SVNSUMMITS_Ideas_Filters_Event")
                .setParams(
                    {
                            listId        : component.get('v.listId'),
    			            searchMyCompanyIdeas : 'no',
                            searchMyCompanyVotedIdeas : 'empty',
                            searchMyCompanyCommentedIdeas : 'empty',
                            searchMyCompanySubscribedIdeas : 'empty'
                    })
                .fire();

        }

    }
})