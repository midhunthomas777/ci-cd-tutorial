({
	handleAnimateEvent: function(component, event, helper) {
		var steps = event.getParam('steps');
		var currentIndex = event.getParam('currentIndex');
		var filledPath = document.getElementById('pathContainer').getElementsByClassName('path-filled')[0];
		filledPath.setAttribute('style', 'stroke-dashoffset:' + helper.coordinates[steps][currentIndex])
	},
})