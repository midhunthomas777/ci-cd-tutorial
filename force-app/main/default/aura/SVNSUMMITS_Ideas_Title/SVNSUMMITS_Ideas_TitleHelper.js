/*
 * Copyright (c) 2019. 7Summits Inc.
 */
({
    deleteIdea: function (component) {
        let self = this;
        let idea = component.get("v.idea");

        if (!confirm(component.get("v.deleteRecordMessage"))) {
            return;
        }

        let deleteTitle = component.get('v.labelDelete');

        this.doCallout(component, "c.deleteIdea",
            {
                'ideaId': idea.Id
            }, false, 'Delete Idea', false)
            .then(() => {
                self.debug(component, "Deleted idea " + idea.Title);

                let deleteToast = component.get('v.deleteRecordToast').replace('{0}', idea.Title);
                self.showMessage('success', deleteTitle, deleteToast);

                self.gotoUrl(component, component.get("v.ideasListURL"));
            }, (errors) => {
                self.debug(component, "Delete Idea failed: " + idea.Title);

                let deleteFailed = component.get('v.deleteRecordFailed')
                    .replace('{0}', idea.Title)
                    .replace('{1}', errors[0]);

                self.showMessage('error', deleteTitle, deleteFailed);

            });
    },
    
    editIdea: function (component) {
        let body = component.find('editView');
        body.set("v.body", []);
        
        try {
            $A.createComponent('c:SVNSUMMITS_Ideas_New', {
                'zoneName'          : component.get("v.zoneName"),
                'zoneId'            : component.get("v.zoneId"),
                'sObjectId'         : component.get("v.recordId"),
                'ideaDetailURL'     : component.get("v.ideaDetailURL"),
                'currIdea'          : component.get("v.idea"),
                'allowImages'       : component.get("v.allowImages"),
                'allowThemes'       : component.get("v.allowThemes"),
                'allowCategories'   : component.get("v.allowCategories"),
                'useTopics'         : true,
                'isEditing'         : true,
                'categoriesAllowed' :component.get("v.categoriesAllowed"),
                'statusAllowed'     :component.get("v.statusAllowed")
            },
            function (editView) {
               let placeHolder = component.find("editView");
               body = placeHolder.get('v.body');

               body.push(editView);
               placeHolder.set("v.body", body);

               component.set("v.isEditing", true);
            });
        } catch (e) {
            this.debug(component, "initialize Idea for Edit exception:", e);
        }
    }
});