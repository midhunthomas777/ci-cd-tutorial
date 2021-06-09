({
	coordinates :{
		2: [1208, 0],
		3: [1208, 610, 0],
		4: [1208, 830, 400, 0],
		5: [1208, 925, 630, 310, 0]
	},
	renderIcon: function(component, helper) {
		//TODO create svg path for 4 steps
		//M0,98c77,0,54,27,95,40s62-14,76-23s39-25,79-17s42,21,73,17s1-62,65-71s51,44,116,45s49,46,88,54s45-30,67-37s26,13,60,8s28-33,80-35s33,21,76,17c25-3,27-39,72-35s32,29,69,41
		var svgns = 'http://www.w3.org/2000/svg';
		var xlinkns = 'http://www.w3.org/1999/xlink';
		var svgPath = 'M0,98c77,0,54,27,95,40s62-14,76-23s39-25,79-17s42,21,73,17s1-62,65-71s51,44,116,54s49,46,88,54s45-30,67-37s26,13,60,8s28-33,80-35s33,21,76,17c25-3,27-39,72-35s32,29,69,29';
		var numOfItems = component.get('v.numOfItems');
		var container = document.getElementById('pathContainer');
		var svgroot = document.createElementNS(svgns, 'svg');
		if(component.get('v.numOfItems') === 4){
			svgPath = 'M0,98c67,-69,70,13,95,40s62-14,76-23s39-25,79-17s42,21,73,17s1-62,65-71s51,44,116,45s49,46,88,54s45-30,77-37s26,13,60,32s28-33,80-35s33,21,76,17c25-3,27-39,72-35s32,32,104,8';
		}

		svgroot.setAttribute('version', '1.1');
		svgroot.setAttribute('xmlns', svgns);
		svgroot.setAttribute('viewBox', '0 0 1016 200');
		svgroot.setAttributeNS(xlinkns, 'xlink', xlinkns);
		this.addPath(component, svgns, svgroot, svgPath, 'path-dotted');
		this.addPath(component, svgns, svgroot, svgPath, 'path-filled');
		container.appendChild(svgroot);
	},
	addPath: function(component, namespace, root, path, classname) {
		var newPath = document.createElementNS(namespace, 'path');
		newPath.setAttributeNS(null, 'd', path);
		newPath.setAttribute('class', classname);
		root.appendChild(newPath);
	},
})