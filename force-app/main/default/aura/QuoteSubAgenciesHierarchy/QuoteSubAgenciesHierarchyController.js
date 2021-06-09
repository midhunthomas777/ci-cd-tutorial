({
    doInit: function (cmp, event, helper) {
        cmp.set('v.gridColumns', [
            {label: 'Opp Name', fieldName: 'Oppname', type: 'text',initialWidth: 130},
            {label: 'Quote Name', fieldName: 'nameUrl', type: 'url', typeAttributes: {label: { fieldName: 'name' }, target: '_blank'},initialWidth: 130}, 
            {label: 'Host Name', fieldName: 'hostAccName', type: 'text',initialWidth: 150},
            {label: 'Secondary Account', fieldName: 'secondaryAccURL', type: 'url', typeAttributes: {label: { fieldName: 'secondaryAccName'}, target: '_blank'},initialWidth: 180},
            {label: 'Channel Partner Name', fieldName: 'channelPartnerURL',type: 'url', typeAttributes: {label: { fieldName: 'channelPartnerName' }, target: '_blank'},initialWidth:190},
            {label: 'Site Name', fieldName: 'siteURL',type: 'url', typeAttributes: {label: { fieldName: 'siteName' }, target: '_blank'},initialWidth:120},
            {label: 'Site ID', fieldName: 'siteId', type: 'text',initialWidth:110},
            {label: 'Employees for Spillman Quotes', fieldName: 'fteCount', type: 'number',initialWidth:250}, 
            {label: 'Total Quote Pkg Amt', fieldName: 'totalAmount', type: 'currency',initialWidth:180},
            {label: 'Total SubQuote Pkg Amt', fieldName: 'subTotal', type: 'currency',initialWidth:200},
            {label: 'Individual Quote Amount', fieldName: 'amount', type: 'currency',initialWidth:210},
            {label: 'Billing Entity', fieldName: 'billingAgency', type: 'text',initialWidth:125},
        ]);
            helper.getData(cmp);
            },
            })