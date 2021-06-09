/*
*File Name     : CheckFederationID  
* Description   : This class created as a part of #INC0708507 inorder to restric recursion of loop which is occuring in between 
                  triggers masterValidationError (Contact object ) and UpdateFederationIDNew (User object )
* @author       : Sai Sampath 
* Test Class    : CheckFederationIDTest
* Modification Log 
* =======================================================================================
*   Ver     Date         Author          IncidentNo          Modification
*----------------------------------------------------------------------------------------
*   1.0    29-Mar-16    Sai Sampath     INC0708507          Initial Creation
*/
public class CheckFederationID
{
    public static boolean checkFedID = False;
    public CheckFederationID()
    {
     
    }
}