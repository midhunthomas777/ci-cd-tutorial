@isTest
public class OmniChannelSoundsCtrl_Test {  

    @isTest
    static void OmniChannelSoundsCtrl_test(){ 
        Test.starttest();

        OmniChannelSoundsCtrl.getSound();
        OmniChannelSoundsCtrl.getSounds();
        OmniChannelSoundsCtrl.setSelectedSound('test');
		OmniChannelSoundsCtrl.setSelectedSound('OFF');
        
        Test.stoptest();
    }

}