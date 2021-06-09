/*
 * Copyright (c) 2019. 7Summits Inc.
 */
({
    truncateHTMLString: function(htmlString, maxLength, appendEllipsis) {
        maxLength = typeof maxLength !== 'undefined' ? maxLength : 200;
        appendEllipsis = typeof appendEllipsis !== 'undefined' ? appendEllipsis : true;
        let trimmedString = '';

        // https://stackoverflow.com/questions/822452/strip-html-from-text-javascript
        let textString = htmlString.replace(/<(?:.|\n)*?>/gm, '');
        if(textString.length > maxLength) {
            // https://stackoverflow.com/questions/5454235/shorten-string-without-cutting-words-in-javascript
            trimmedString = textString.substr(0, maxLength);
            trimmedString = trimmedString.substr(0, Math.min(trimmedString.length, trimmedString.lastIndexOf(" ")));

            trimmedString = appendEllipsis ? trimmedString + '...' : trimmedString;
        }

        return trimmedString;
    }
})