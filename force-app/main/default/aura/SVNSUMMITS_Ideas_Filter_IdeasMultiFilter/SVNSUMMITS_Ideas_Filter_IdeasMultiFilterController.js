({
    doInit : function(component, event, helper) {
        //INIT COMMENTED
		debugger;
        try {

            if(component.get('v.superUser')) {
                component.set('v.filterValue', $A.get("$Label.c.ss_idea_label_myCompanyIdeas"));
            } else {
                component.set('v.filterValue', $A.get("$Label.c.ss_idea_label_myIdeas"));   
            }
            

        if(component.get('v.requireSelectionIdeasFilter')) {

             if (component.get('v.showMyIdeas')) {
                 helper.showMyIdeas(component,event,helper);

                 component.set('v.filterValue', $A.get("$Label.c.ss_idea_label_myIdeas"));

             } else if (component.get('v.showVoteByMeFilter')) {

                 helper.showVoteByMeFilter(component,event,helper);

                 component.set('v.filterValue', $A.get("$Label.c.ss_idea_label_ideasVotedOn"));

             } else if (component.get('v.showIdeasCommentedByMeFilter')) {

                 helper.showIdeasCommentedByMeFilter(component,event,helper);

                 component.set('v.filterValue', $A.get("$Label.c.ss_idea_label_ideasCommentedOn"));

             } else if (component.get('v.showIdeasSubscribedByMeFilter')) {

                 helper.showIdeasSubscribedByMeFilter(component,event,helper);

                 component.set('v.filterValue', $A.get("$Label.c.ss_idea_label_ideasSubscribedOn"));

             } else if (component.get('v.myCompaniesIdeas')) {

                 helper.myCompaniesIdeas(component,event,helper);

                 component.set('v.filterValue', $A.get("$Label.c.ss_idea_label_myCompanyIdeas"));

            } else if (component.get('v.myCompaniesVotedIdeas')) {

                helper.myCompaniesVotedIdeas(component,event,helper);

                component.set('v.filterValue', $A.get("$Label.c.ss_idea_label_myCompanyVotedIdeas"));

            } else if (component.get('v.myCompaniesCommentedIdeas')) {

                helper.myCompaniesCommentedIdeas(component,event,helper);

                component.set('v.filterValue', $A.get("$Label.c.ss_idea_label_myCompanyCommentedIdeas"));

            } else if (component.get('v.myCompaniesSubscribedIdeas')) {

                helper.myCompaniesSubscribedIdeas(component,event,helper);

                component.set('v.filterValue', $A.get("$Label.c.ss_idea_label_myCompanySubscribedIdeas"));
            } else {

                helper.showMyIdeas(component,event,helper);

                component.set('v.filterValue', $A.get("$Label.c.ss_idea_label_myIdeas"));
             }
        }

        } catch(ex) {}

    },

    handleSelectedFilter : function(component, event, helper) {
		
        helper.debug(component, '---- Ideas Multiple On Filter  ----');

        let filter = component.get("v.filterValue");
        helper.debug(component, "    Filter: " + filter);

        if (filter === $A.get("$Label.c.ss_idea_label_myIdeas")) {
            helper.showMyIdeas(component,event,helper);

        } else if (filter === $A.get("$Label.c.ss_idea_label_ideasVotedOn")) {
            helper.showVoteByMeFilter(component,event,helper);

        } else if (filter === $A.get("$Label.c.ss_idea_label_ideasCommentedOn")) {
            helper.showIdeasCommentedByMeFilter(component,event,helper);

        } else if (filter === $A.get("$Label.c.ss_idea_label_ideasSubscribedOn")) {
            helper.showIdeasSubscribedByMeFilter(component,event,helper);

        } else if (filter === $A.get("$Label.c.ss_idea_label_myCompanyIdeas")) {
           helper.myCompaniesIdeas(component,event,helper);

        } else if (filter === $A.get("$Label.c.ss_idea_label_myCompanyVotedIdeas")) {
            helper.myCompaniesVotedIdeas(component,event,helper);

        } else if (filter === $A.get("$Label.c.ss_idea_label_myCompanyCommentedIdeas")) {
            helper.myCompaniesCommentedIdeas(component,event,helper);

        } else if (filter === $A.get("$Label.c.ss_idea_label_myCompanySubscribedIdeas")) {
            helper.myCompaniesSubscribedIdeas(component,event,helper);

        } else {
            helper.emptyFilter(component,event,helper);

        }

    }
})