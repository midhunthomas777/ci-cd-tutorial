/**
 * Created by QGBC67 on 21.09.2020.
 */

public with sharing class DTSFPART_RunOnce {
    private static Set<String> alreadyRun = new Set<String>();

    public static boolean hasAlreadyfired(String actionName) {
        return alreadyRun.contains(actionName);
    }

    public static void setAlreadyfired(String actionName) {
        alreadyRun.add(actionName);
    }

}