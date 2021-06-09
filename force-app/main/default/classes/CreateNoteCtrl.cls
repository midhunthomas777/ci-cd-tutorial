/*
 * Name : CreateNoteCtrl
* Description: This is used to create Note from BRR
* Author : Adilraza Shaikh, Afzal Wasi
* Date : 6/1/2020
*/
public with sharing class CreateNoteCtrl {
    @AuraEnabled
    public static void createContentNote (ContentNote note, Id parentId){
        try{
            if(note != null){
                insert note;
                ContentDocumentLink cdl=new ContentDocumentLink();
                cdl.ContentDocumentId=note.id;
                cdl.LinkedEntityId=parentId;
                cdl.ShareType='V';
                cdl.Visibility='AllUsers';
                insert cdl;
            }
        } catch (Exception ex){

        }
    }    
}