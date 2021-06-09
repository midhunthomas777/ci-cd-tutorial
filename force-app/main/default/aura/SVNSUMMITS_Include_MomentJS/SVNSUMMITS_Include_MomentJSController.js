/*
 * Copyright (c) 2019. 7Summits Inc.
 */
({
	afterScriptsLoaded: function () {
		const currentLocale = moment.locale();
		console.debug('Current locale ' + currentLocale);
		const browserLocale = navigator.languages && navigator.languages.length
			? navigator.languages[0]
			: navigator.language;
		console.debug('Browser locale ' + browserLocale);
		// moment.locale(browserLocale);
	}
});