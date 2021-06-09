/**
 * @author Jan Sledziewski
 * @date 30.10.2020
 * @updated 23.11.2020
 * @description Test for DTSFPART_EncodingUtils class, each test contains properly encoded FormData body,
 *  to check contents of "expecting" String use base64 decode
 */
@IsTest
private class DTSFPART_EncodingUtilsTest {

	/**
	 * Encoded simple TXT file to save on encoded string length
	 */
	private static final DTSFPART_FileWrapper testFile = new DTSFPART_FileWrapper(
			'base64.txt',
			'text/plain',
			'attachment',
			'aXRzIGp1c3QgYSB0ZXN0'
	);

	private static final Map<String, String> testBodyParams = new Map<String, String>{
			'testParam1' => 'value1',
			'testParam2' => 'val23',
			'testParam3' => '[]'
	};

	private static final Map<String, String> testJsonParams = new Map<String, String>{
		'values' => '{"Id": "007", "Name": "JSON", "LastName": "Test"}'
	};

	@IsTest
	private static void testOnlyBodyParamsEncoding() {
		String expecting = 'LS0xZmYxMzQ0NWVkODEyMGM3YTMyZmMzZWc0NTFhYTc2ZA0KQ29udGVudC1EaXNwb3NpdGlvbjogZm9ybS1kYXRhOyBuYW1lPSJ0ZXN0UGFyYW0xIg0KDQp2YWx1ZTENCi0tMWZmMTM0NDVlZDgxMjBjN2EzMmZjM2VnNDUxYWE3NmQNCkNvbnRlbnQtRGlzcG9zaXRpb246IGZvcm0tZGF0YTsgbmFtZT0idGVzdFBhcmFtMiINCg0KdmFsMjMNCi0tMWZmMTM0NDVlZDgxMjBjN2EzMmZjM2VnNDUxYWE3NmQNCkNvbnRlbnQtRGlzcG9zaXRpb246IGZvcm0tZGF0YTsgbmFtZT0idGVzdFBhcmFtMyINCg0KW10NCi0tMWZmMTM0NDVlZDgxMjBjN2EzMmZjM2VnNDUxYWE3NmQtLQ0K';
		Blob expected = EncodingUtil.base64Decode(expecting);
		Blob actual = DTSFPART_EncodingUtils.encodeForm(testBodyParams, null, null);

		System.assertEquals(expected, actual);
	}

	@IsTest
	private static void testOnlyFileEncoding() {
		String expecting = 'LS0xZmYxMzQ0NWVkODEyMGM3YTMyZmMzZWc0NTFhYTc2ZA0KQ29udGVudC1EaXNwb3NpdGlvbjogZm9ybS1kYXRhOyBuYW1lPSJhdHRhY2htZW50IjsgZmlsZW5hbWU9ImJhc2U2NC50eHQiOw0KQ29udGVudC1UeXBlOiB0ZXh0L3BsYWluICANCg0KaXRzIGp1c3QgYSB0ZXN0DQotLTFmZjEzNDQ1ZWQ4MTIwYzdhMzJmYzNlZzQ1MWFhNzZkLS0NCg==';
		Blob expected = EncodingUtil.base64Decode(expecting);
		Blob actual = DTSFPART_EncodingUtils.encodeForm(null, null, new List<DTSFPART_FileWrapper>{testFile});

		System.assertEquals(expected, actual);
	}

	@IsTest
	private static void testMultiFileEncoding() {
		String expecting = 'LS0xZmYxMzQ0NWVkODEyMGM3YTMyZmMzZWc0NTFhYTc2ZA0KQ29udGVudC1EaXNwb3NpdGlvbjogZm9ybS1kYXRhOyBuYW1lPSJhdHRhY2htZW50IjsgZmlsZW5hbWU9ImJhc2U2NC50eHQiOw0KQ29udGVudC1UeXBlOiB0ZXh0L3BsYWluICANCg0KaXRzIGp1c3QgYSB0ZXN0DQotLTFmZjEzNDQ1ZWQ4MTIwYzdhMzJmYzNlZzQ1MWFhNzZkDQpDb250ZW50LURpc3Bvc2l0aW9uOiBmb3JtLWRhdGE7IG5hbWU9ImF0dGFjaG1lbnQiOyBmaWxlbmFtZT0iYmFzZTY0LnR4dCI7DQpDb250ZW50LVR5cGU6IHRleHQvcGxhaW4NCg0KaXRzIGp1c3QgYSB0ZXN0DQotLTFmZjEzNDQ1ZWQ4MTIwYzdhMzJmYzNlZzQ1MWFhNzZkDQpDb250ZW50LURpc3Bvc2l0aW9uOiBmb3JtLWRhdGE7IG5hbWU9ImF0dGFjaG1lbnQiOyBmaWxlbmFtZT0iYmFzZTY0LnR4dCI7DQpDb250ZW50LVR5cGU6IHRleHQvcGxhaW4NCg0KaXRzIGp1c3QgYSB0ZXN0DQotLTFmZjEzNDQ1ZWQ4MTIwYzdhMzJmYzNlZzQ1MWFhNzZkLS0NCg==';
		Blob expected = EncodingUtil.base64Decode(expecting);
		Blob actual = DTSFPART_EncodingUtils.encodeForm(null, null, new List<DTSFPART_FileWrapper>{testFile, testFile, testFile});

		System.assertEquals(expected, actual);
	}

	@IsTest
	private static void testOnlyStringFileEncoding() {
		String expecting = 'LS0xZmYxMzQ0NWVkODEyMGM3YTMyZmMzZWc0NTFhYTc2ZA0KQ29udGVudC1EaXNwb3NpdGlvbjogZm9ybS1kYXRhOyBuYW1lPSJhdHRhY2htZW50IjsgZmlsZW5hbWU9ImJhc2U2NC50eHQiOw0KQ29udGVudC1UeXBlOiB0ZXh0L3BsYWluDQpDb250ZW50LVRyYW5zZmVyLUVuY29kaW5nOiBiYXNlNjQNCg0KYVhSeklHcDFjM1FnWVNCMFpYTjANCi0tMWZmMTM0NDVlZDgxMjBjN2EzMmZjM2VnNDUxYWE3NmQtLQ0K';
		Blob expected = EncodingUtil.base64Decode(expecting);
		Blob actual = DTSFPART_EncodingUtils.encodeForm(null, null, new List<DTSFPART_FileWrapper>{testFile}, true);

		System.assertEquals(expected, actual);
	}

	@IsTest
	private static void testMultiStringFileEncoding() {
		String expecting = 'LS0xZmYxMzQ0NWVkODEyMGM3YTMyZmMzZWc0NTFhYTc2ZA0KQ29udGVudC1EaXNwb3NpdGlvbjogZm9ybS1kYXRhOyBuYW1lPSJhdHRhY2htZW50IjsgZmlsZW5hbWU9ImJhc2U2NC50eHQiOw0KQ29udGVudC1UeXBlOiB0ZXh0L3BsYWluDQpDb250ZW50LVRyYW5zZmVyLUVuY29kaW5nOiBiYXNlNjQNCg0KYVhSeklHcDFjM1FnWVNCMFpYTjANCi0tMWZmMTM0NDVlZDgxMjBjN2EzMmZjM2VnNDUxYWE3NmQNCkNvbnRlbnQtRGlzcG9zaXRpb246IGZvcm0tZGF0YTsgbmFtZT0iYXR0YWNobWVudCI7IGZpbGVuYW1lPSJiYXNlNjQudHh0IjsNCkNvbnRlbnQtVHlwZTogdGV4dC9wbGFpbg0KQ29udGVudC1UcmFuc2Zlci1FbmNvZGluZzogYmFzZTY0DQoNCmFYUnpJR3AxYzNRZ1lTQjBaWE4wDQotLTFmZjEzNDQ1ZWQ4MTIwYzdhMzJmYzNlZzQ1MWFhNzZkDQpDb250ZW50LURpc3Bvc2l0aW9uOiBmb3JtLWRhdGE7IG5hbWU9ImF0dGFjaG1lbnQiOyBmaWxlbmFtZT0iYmFzZTY0LnR4dCI7DQpDb250ZW50LVR5cGU6IHRleHQvcGxhaW4NCkNvbnRlbnQtVHJhbnNmZXItRW5jb2Rpbmc6IGJhc2U2NA0KDQphWFJ6SUdwMWMzUWdZU0IwWlhOMA0KLS0xZmYxMzQ0NWVkODEyMGM3YTMyZmMzZWc0NTFhYTc2ZC0tDQo=';
		Blob expected = EncodingUtil.base64Decode(expecting);
		Blob actual = DTSFPART_EncodingUtils.encodeForm(null, null, new List<DTSFPART_FileWrapper>{testFile, testFile, testFile}, true);

		System.assertEquals(expected, actual);
	}

	@IsTest
	private static void testOnlyJsonParamsEncoding() {
		String expecting = 'LS0xZmYxMzQ0NWVkODEyMGM3YTMyZmMzZWc0NTFhYTc2ZA0KQ29udGVudC1EaXNwb3NpdGlvbjogZm9ybS1kYXRhOyBuYW1lPSJ2YWx1ZXMiDQpDb250ZW50LVR5cGU6IGFwcGxpY2F0aW9uL2pzb247IGNoYXJzZXQ9VVRGLTgNCkNvbnRlbnQtVHJhbnNmZXItRW5jb2Rpbmc6IDhiaXQNCg0KeyJJZCI6ICIwMDciLCAiTmFtZSI6ICJKU09OIiwgIkxhc3ROYW1lIjogIlRlc3QifQ0KLS0xZmYxMzQ0NWVkODEyMGM3YTMyZmMzZWc0NTFhYTc2ZC0tDQo=';
		Blob expected = EncodingUtil.base64Decode(expecting);
		Blob actual = DTSFPART_EncodingUtils.encodeForm(null, testJsonParams, null);

		System.assertEquals(expected, actual);
	}

	@IsTest
	private static void testParamsWithFileEncoding() {
		String expecting = 'LS0xZmYxMzQ0NWVkODEyMGM3YTMyZmMzZWc0NTFhYTc2ZA0KQ29udGVudC1EaXNwb3NpdGlvbjogZm9ybS1kYXRhOyBuYW1lPSJ0ZXN0UGFyYW0xIg0KDQp2YWx1ZTENCi0tMWZmMTM0NDVlZDgxMjBjN2EzMmZjM2VnNDUxYWE3NmQNCkNvbnRlbnQtRGlzcG9zaXRpb246IGZvcm0tZGF0YTsgbmFtZT0idGVzdFBhcmFtMiINCg0KdmFsMjMNCi0tMWZmMTM0NDVlZDgxMjBjN2EzMmZjM2VnNDUxYWE3NmQNCkNvbnRlbnQtRGlzcG9zaXRpb246IGZvcm0tZGF0YTsgbmFtZT0idGVzdFBhcmFtMyINCg0KW10NCi0tMWZmMTM0NDVlZDgxMjBjN2EzMmZjM2VnNDUxYWE3NmQNCkNvbnRlbnQtRGlzcG9zaXRpb246IGZvcm0tZGF0YTsgbmFtZT0iYXR0YWNobWVudCI7IGZpbGVuYW1lPSJiYXNlNjQudHh0IjsNCkNvbnRlbnQtVHlwZTogdGV4dC9wbGFpbiANCg0KaXRzIGp1c3QgYSB0ZXN0DQotLTFmZjEzNDQ1ZWQ4MTIwYzdhMzJmYzNlZzQ1MWFhNzZkLS0NCg==';
		Blob expected = EncodingUtil.base64Decode(expecting);
		Blob actual = DTSFPART_EncodingUtils.encodeForm(testBodyParams, null, new List<DTSFPART_FileWrapper>{testFile});

		System.assertEquals(expected, actual);
	}

	@IsTest
	private static void testParamsWithJsonAndFileEncoding() {
		String expecting = 'LS0xZmYxMzQ0NWVkODEyMGM3YTMyZmMzZWc0NTFhYTc2ZA0KQ29udGVudC1EaXNwb3NpdGlvbjogZm9ybS1kYXRhOyBuYW1lPSJ0ZXN0UGFyYW0xIg0KDQp2YWx1ZTENCi0tMWZmMTM0NDVlZDgxMjBjN2EzMmZjM2VnNDUxYWE3NmQNCkNvbnRlbnQtRGlzcG9zaXRpb246IGZvcm0tZGF0YTsgbmFtZT0idGVzdFBhcmFtMiINCg0KdmFsMjMNCi0tMWZmMTM0NDVlZDgxMjBjN2EzMmZjM2VnNDUxYWE3NmQNCkNvbnRlbnQtRGlzcG9zaXRpb246IGZvcm0tZGF0YTsgbmFtZT0idGVzdFBhcmFtMyINCg0KW10NCi0tMWZmMTM0NDVlZDgxMjBjN2EzMmZjM2VnNDUxYWE3NmQNCkNvbnRlbnQtRGlzcG9zaXRpb246IGZvcm0tZGF0YTsgbmFtZT0idmFsdWVzIg0KQ29udGVudC1UeXBlOiBhcHBsaWNhdGlvbi9qc29uOyBjaGFyc2V0PVVURi04DQpDb250ZW50LVRyYW5zZmVyLUVuY29kaW5nOiA4Yml0DQoNCnsiSWQiOiAiMDA3IiwgIk5hbWUiOiAiSlNPTiIsICJMYXN0TmFtZSI6ICJUZXN0In0NCi0tMWZmMTM0NDVlZDgxMjBjN2EzMmZjM2VnNDUxYWE3NmQNCkNvbnRlbnQtRGlzcG9zaXRpb246IGZvcm0tZGF0YTsgbmFtZT0iYXR0YWNobWVudCI7IGZpbGVuYW1lPSJiYXNlNjQudHh0IjsNCkNvbnRlbnQtVHlwZTogdGV4dC9wbGFpbiANCg0KaXRzIGp1c3QgYSB0ZXN0DQotLTFmZjEzNDQ1ZWQ4MTIwYzdhMzJmYzNlZzQ1MWFhNzZkLS0NCg==';
		Blob expected = EncodingUtil.base64Decode(expecting);
		Blob actual = DTSFPART_EncodingUtils.encodeForm(testBodyParams, testJsonParams, new List<DTSFPART_FileWrapper>{testFile});

		System.assertEquals(expected, actual);
	}

	@IsTest
	private static void testParamsWithJsonAndStringFileEncoding() {
		String expecting = 'LS0xZmYxMzQ0NWVkODEyMGM3YTMyZmMzZWc0NTFhYTc2ZA0KQ29udGVudC1EaXNwb3NpdGlvbjogZm9ybS1kYXRhOyBuYW1lPSJ0ZXN0UGFyYW0xIg0KDQp2YWx1ZTENCi0tMWZmMTM0NDVlZDgxMjBjN2EzMmZjM2VnNDUxYWE3NmQNCkNvbnRlbnQtRGlzcG9zaXRpb246IGZvcm0tZGF0YTsgbmFtZT0idGVzdFBhcmFtMiINCg0KdmFsMjMNCi0tMWZmMTM0NDVlZDgxMjBjN2EzMmZjM2VnNDUxYWE3NmQNCkNvbnRlbnQtRGlzcG9zaXRpb246IGZvcm0tZGF0YTsgbmFtZT0idGVzdFBhcmFtMyINCg0KW10NCi0tMWZmMTM0NDVlZDgxMjBjN2EzMmZjM2VnNDUxYWE3NmQNCkNvbnRlbnQtRGlzcG9zaXRpb246IGZvcm0tZGF0YTsgbmFtZT0idmFsdWVzIg0KQ29udGVudC1UeXBlOiBhcHBsaWNhdGlvbi9qc29uOyBjaGFyc2V0PVVURi04DQpDb250ZW50LVRyYW5zZmVyLUVuY29kaW5nOiA4Yml0DQoNCnsiSWQiOiAiMDA3IiwgIk5hbWUiOiAiSlNPTiIsICJMYXN0TmFtZSI6ICJUZXN0In0NCi0tMWZmMTM0NDVlZDgxMjBjN2EzMmZjM2VnNDUxYWE3NmQNCkNvbnRlbnQtRGlzcG9zaXRpb246IGZvcm0tZGF0YTsgbmFtZT0iYXR0YWNobWVudCI7IGZpbGVuYW1lPSJiYXNlNjQudHh0IjsNCkNvbnRlbnQtVHlwZTogdGV4dC9wbGFpbg0KQ29udGVudC1UcmFuc2Zlci1FbmNvZGluZzogYmFzZTY0DQoNCmFYUnpJR3AxYzNRZ1lTQjBaWE4wDQotLTFmZjEzNDQ1ZWQ4MTIwYzdhMzJmYzNlZzQ1MWFhNzZkLS0NCg==';
		Blob expected = EncodingUtil.base64Decode(expecting);
		Blob actual = DTSFPART_EncodingUtils.encodeForm(testBodyParams, testJsonParams, new List<DTSFPART_FileWrapper>{testFile}, true);

		System.assertEquals(expected, actual);
	}

	/**
	 * Only footer is encoded marking end of the FormData body
	 */
	@IsTest
	private static void testEmpty() {
		String expecting = 'LS0xZmYxMzQ0NWVkODEyMGM3YTMyZmMzZWc0NTFhYTc2ZC0tDQo=';
		Blob expected = EncodingUtil.base64Decode(expecting);
		Blob actual = DTSFPART_EncodingUtils.encodeForm(null, null, null);

		System.assertEquals(expected, actual);
	}

	@IsTest
	private static void testBoundaryHeader(){
		System.assertEquals('multipart/form-data; boundary=1ff13445ed8120c7a32fc3eg451aa76d', DTSFPART_EncodingUtils.getContentType());
	}
}