({
    getMyViewUrl: function(component) {
        return component.get('v.myViewEnv') === 'Test' ? 'https://myview-test.motorolasolutions.com' : 'https://myview.motorolasolutions.com';
    }
})