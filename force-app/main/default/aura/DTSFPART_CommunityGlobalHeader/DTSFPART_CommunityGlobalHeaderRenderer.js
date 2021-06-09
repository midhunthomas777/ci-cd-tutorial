({
    afterRender: function (component, helper) {
        this.superAfterRender();
        
        let search = component.get('v.search');
        if (!search[0]) {
            return;
        }
        try {
            let inputComp = search[0].get('v.body')[0].get('v.body')[0].find('searchInputDesktop');
            let inputHelper = inputComp.getDef().getHelper();
            let auraInput = inputHelper.getAutocompleteCmp(inputComp);
            let currentClass = auraInput.get('v.inputClass');
            auraInput.set('v.inputClass', `${currentClass} header-search-input`);
            let input = inputHelper.getInputEl(inputComp);
            input.dataset.uetLinkLabel = "search field";
        } catch(e) {
            console.error(e);
        }
    }    
})