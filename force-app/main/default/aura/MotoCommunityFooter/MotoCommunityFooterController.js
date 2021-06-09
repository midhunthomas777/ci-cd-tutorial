({
    openPanelOne: function(component) {
        var displayMode = document.getElementById("panel-one").style.display;
        if (displayMode === "none") {
            document.getElementById("panel-one").style.display = "block";
        } else {
            document.getElementById("panel-one").style.display = "none";
        }
    }
})
s