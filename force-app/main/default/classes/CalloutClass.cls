public class CalloutClass {
   
        public static HttpResponse getInfoFromExternalServiceS(String EndPoints,String method) {
        HttpRequest req = new HttpRequest();
       // req.setEndpoint('https://wsgw.motorolasolutions.com:443/SA_call_LDAP_AuthService_V1.0-Prod');
        req.setEndpoint(EndPoints);
        req.setMethod(method);
        Http h = new Http();
        HttpResponse res = h.send(req);
        return res;
    }
}