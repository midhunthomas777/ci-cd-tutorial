({
    doInit : function(component, event, helper) {
        var parsedUrl = new URL(window.location.href);
        var language = parsedUrl.searchParams.get("language");
        var result=language.toLowerCase();
        if(result === 'ko') {
            result = 'ko_kr';
        } else if(result === 'ja') {
            result = 'ja_jp';
        } else if (result === 'es') {
            result = 'es_xl';
        }
        var footerUrl="https://www.motorolasolutions.com/static/navigation/"+result+"/footer.html";
        component.set("v.lang", footerUrl);
    }
})