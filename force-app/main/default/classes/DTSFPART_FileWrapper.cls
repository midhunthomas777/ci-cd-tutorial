/**
 * @author: WGVR43 
 * @date: 08.10.2020
 * @group: DTSFPART
 * @description: 
 */

public with sharing class DTSFPART_FileWrapper {

	public String name { get; private set; }
	public String mime { get; private set; }
	public String key  { get; private set; }
	public String data { get; private set; }

	public DTSFPART_FileWrapper(String name, String mime, String key, String data){
		this.name = name;
		this.mime = mime;
		this.key = key;
		this.data = data;
	}
}