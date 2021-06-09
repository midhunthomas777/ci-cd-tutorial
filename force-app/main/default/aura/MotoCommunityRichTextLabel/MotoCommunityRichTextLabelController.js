({
    doInit: function(cmp) {
        var labelName = cmp.get("v.labelName");
        var labelReference = $A.getReference("$Label.c." + labelName);
        cmp.set("v.text", labelReference);
    }
})