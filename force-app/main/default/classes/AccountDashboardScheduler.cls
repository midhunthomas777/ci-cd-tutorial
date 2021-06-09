global class AccountDashboardScheduler implements schedulable
{
    global void execute(SchedulableContext SC)
    {
        FeedItem post = new FeedItem();
        String PostTo= label.Dashboard_Chatter_Group;
        //post.ParentId = '00G1b000000SEAW';        // Specify the ID with whom/which the Post has to be shared
        post.ParentId = PostTo;     // Specify the ID with whom/which the Post has to be shared
        Post.Body='Dashboard to view trend in Account and Google Drive Creation';
        post.LinkUrl = URL.getSalesforceBaseUrl().toExternalForm() +'/apex/AccountDashboard';
        if(!Test.isRunningTest())
        insert Post;
//        System.assert(false,post);
    }
}