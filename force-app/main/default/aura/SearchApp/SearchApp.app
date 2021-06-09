<!--
2019-12-18 Created by Lorenzo Alali
IT control on INC2252716
Reason: Searching bu URL is possible in Lightning, not in Classic
Idea submitted on https://success.salesforce.com/ideaView?id=0873A0000015BJJQA2 
In the meantime, Lightning App "SearchApp.app" and "SearchAppController.js" were created as a workaround
If the Idea gets implemented by Salesforce, ok to retire this App

2020-08-06 Update
This is now also used in Tableau. The ID18 is not avaialble in tex_data_sf_automation_bkp and Jonathan Hall wanted a way to create a URL action in the Tableau forecasting dashboard so users can navigate to Salesforce.
I gave him this possibility https://motorolasolutions.lightning.force.com/c/SearchApp.app?search=XXXXX to search via Transaction Number
-->

<aura:application>
    <aura:attribute name="search" type="String" />
    <aura:handler name="init" value="{!this}" action="{!c.doInit}"/>
    Redirecting to search results for {!v.search}
</aura:application>