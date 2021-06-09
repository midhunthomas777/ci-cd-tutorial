({
    renderIcon: function(component) {
		let iconColor = component.get('v.color');
        if( iconColor == null || iconColor == 'null' || iconColor == ''){
            component.set('v.color','grey');
        }

        var prefix = "slds-";
        var svgns = "http://www.w3.org/2000/svg";
        var xlinkns = "http://www.w3.org/1999/xlink";
        var size = component.get("v.size");
        var name = component.get("v.name");
        var classname = component.get("v.class");
        var containerclass = component.get("v.containerClass");
        var category = component.get("v.category");
        
        var containerClassName = [
            prefix+"icon_container",
            prefix+"icon-"+category+"-"+name,
            containerclass
        ].join(' ');
        component.set("v.containerClass", containerClassName);
        let color = component.get('v.color');
        var svgroot = document.createElementNS(svgns, "svg");
        var iconClassName = prefix+"icon "+prefix+"icon--" + size+" "+classname;
        svgroot.setAttribute("aria-hidden", "true");
        svgroot.setAttribute("class", iconClassName);
        svgroot.setAttribute("name", name);
        svgroot.setAttribute("style", 'fill:'+color);
        
        console.log('Path: '+component.get("v.svgPath"));
        // Add an "href" attribute (using the "xlink" namespace)
        var shape = document.createElementNS(svgns, "use");
        shape.setAttributeNS(xlinkns, "href", component.get("v.svgPath"));
        svgroot.appendChild(shape);
        
        var container = component.find("container").getElement();
        container.insertBefore(svgroot, container.firstChild);
    }
})