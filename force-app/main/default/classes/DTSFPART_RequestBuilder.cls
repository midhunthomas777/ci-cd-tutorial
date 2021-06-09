/**
 * @author: WGVR43 
 * @date: 24.11.2020
 * @group: DTSFPART
 * @description: 
 */

public class DTSFPART_RequestBuilder {
	private String credentials = 'Mulesoft_OAuth';
	private Mulesoft__mdt metadata;
	private String method = '';
	private Map<String, String> headers = new Map<String, String>();
	private Map<String, String> queryParams = new Map<String, String>();
	private Map<String, String> customParams = new Map<String, String>();
	private Object body = null;
	private String endpoint = '';
	private Boolean federationId = false;
	private Boolean oamSession = false;
	private String customUser = UserInfo.getUserName();
	private Integer timeout;

	public DTSFPART_RequestBuilder(String metadata){
		this.metadata = DTSFPART_Utils.getMulesoftMetadata(metadata);
	}

	public DTSFPART_RequestBuilder customMethod(String method){
		this.method = method;

		return this;
	}

	public DTSFPART_RequestBuilder customCredentials(String credentials){
		this.credentials = credentials;

		return this;
	}

	public DTSFPART_RequestBuilder withHeaders(Map<String, String> headers){
		this.headers = headers;

		return this;
	}

	public DTSFPART_RequestBuilder withQueryParams(Map<String, String> queryParams){
		this.queryParams = queryParams;

		return this;
	}

	public DTSFPART_RequestBuilder withCustomParams(Map<String, String> customParams){
		this.customParams = customParams;

		return this;
	}

	public DTSFPART_RequestBuilder withBody(Object body){
		this.body = body;

		return this;
	}

	public DTSFPART_RequestBuilder withEndpoint(String endpoint){
		this.endpoint = 'endpoint=' + endpoint;

		return this;
	}

	public DTSFPART_RequestBuilder withFederationId(){
		this.federationId = true;

		return this;
	}

	public DTSFPART_RequestBuilder withOamSession(){
		this.oamSession = true;

		return this;
	}

	public DTSFPART_RequestBuilder withCustomUser(String customUser){
		this.customUser = customUser;

		return this;
	}

	public DTSFPART_RequestBuilder withTimeout(Integer timeout){
		this.timeout = timeout;

		return this;
	}

	public HttpRequest build(){
		HttpRequest request = new HttpRequest();

		if(metadata.UseFederationId__c != null && metadata.UseFederationId__c) {
			this.federationId = true;
		}

		request.setEndpoint(buildUri());

		if(String.isNotBlank(method)){
			request.setMethod(method);
		} else {
			request.setMethod(metadata.Method_Type__c);
		}

		if(String.isNotBlank(metadata.Content_Type__c)){
			request.setHeader('Content-Type', metadata.Content_Type__c);
		}

		for(String key: headers.keySet()){
			request.setHeader(key, headers.get(key));
		}

		if(!customParams.isEmpty()){
			String endpoint = request.getEndpoint();
			for(String key: customParams.keySet()){
				endpoint = endpoint.replace(key, customParams.get(key));
			}
			request.setEndpoint(endpoint);
		}

		if(body != null && ( body instanceof Blob || !((String) body).equals('null'))) {
			if(body instanceof Blob){
				request.setBodyAsBlob((Blob) body);
			} else {
				request.setBody((String) body);
			}
		}

		if(timeout != null && timeout > 1 && timeout <= 120000){
			request.setTimeout(timeout);
		}

		return request;
	}

	private String buildUri(){
		String queryString = 'callout:' + credentials;

		if(String.isNotBlank(metadata.Endpoint__c)){
			queryString += '/' + metadata.Endpoint__c;
		}

		if(String.isNotBlank(endpoint) || oamSession || !queryParams.isEmpty()){
			queryString += '?';

			if(oamSession){
				queryString += DTSFPART_Utils.getUserOAMSessionParam(customUser, federationId);
			}


			if(String.isNotBlank(endpoint)){
				queryString += oamSession? '&' + endpoint: endpoint;
			}

			String prefix = String.isNotBlank(endpoint) || oamSession? '&': '';
			for(String key: queryParams.keySet()){
				queryString += prefix + key + '=' + queryParams.get(key);
				prefix = '&';
			}
		}

		return queryString;
	}
}