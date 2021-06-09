public with sharing class OmniChannelSoundsCtrl {
    
    @AuraEnabled
    public static string getSound(){
        Omni_Channel_Sound__c sound = 
            Omni_Channel_Sound__c.getInstance(UserInfo.getUserId());
        return sound.Sound__c;
    }

    @AuraEnabled
    public static List<String> getSounds(){
        List<String> soundsNames = new List<String>();
        for (StaticResource resource : [ 
            SELECT Name 
            FROM StaticResource 
            WHERE Description 
            LIKE '%OmniChannelSound%' 
            ORDER BY Createddate ASC]) {
                soundsNames.add(resource.Name);
            }
        soundsNames.add('OFF');
        return soundsNames;
    }

    @AuraEnabled
    public static void setSelectedSound(String sound){
        Omni_Channel_Sound__c omniChannelSound =
        Omni_Channel_Sound__c.getInstance(UserInfo.getUserId());
        if (sound == 'OFF') {
            omniChannelSound.Sound__c = null;
        } else {
            omniChannelSound.Sound__c = sound;
        }
        omniChannelSound.SetupOwnerId = UserInfo.getUserId();
        upsert omniChannelSound;
    }
}