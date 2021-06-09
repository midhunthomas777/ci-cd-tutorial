@istest
Private class EMEAOpptyGridSearchTest {

    Public static testMethod void GridSearchTest()
    {                                        
        PageReference pageRef = Page.EMEAOpptyGridSearch;
        Test.setCurrentPageReference(pageRef);
        ApexPages.currentPage().getParameters().put('searchText', 'test');
        EMEAOpptyGridSearchController Grid= new EMEAOpptyGridSearchController();
        Grid.runsearch();
        Grid.reset();
        Grid.GetAccounts();
        Grid.save();               
    }
}