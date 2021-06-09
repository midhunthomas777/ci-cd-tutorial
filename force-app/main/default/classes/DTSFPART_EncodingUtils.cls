/**
 * @author Jan Sledziewski
 * @date 30.10.2020
 * @updated 23.11.2020
 * @description Utility class returning encoded FormData body
 */
public class DTSFPART_EncodingUtils {
	/**
	 * Aligned boundary with base64 encoding - doesn't produce padding characters.
	 */
	private final static String BOUNDARY = '1ff13445ed8120c7a32fc3eg451aa76d';

	/**
	 * @param params map of String form data body parameters, expected form: ('key1' => 'String value', 'key2' => 'va2')
	 * @param jsonParams map of JSON BodyParameters, expected form: ('key' => '{"id1":"val1", "id2": "val2"})
	 * @param files list of files to be write to from data body, expecting list of DTSFPART_FileWrapper
	 *
	 * @return Blob object, contains encoded data, can be written to HttpRequest using setBodyAsBlob() method
	 */
	public static Blob encodeForm(Map<String, String> params, Map<String, String> jsonParams, List<DTSFPART_FileWrapper> files){
		return encodeForm(params, jsonParams, files, false);
	}
	/**
	 * @param params map of String form data body parameters, expected form: ('key1' => 'String value', 'key2' => 'va2')
	 * @param jsonParams map of JSON BodyParameters, expected form: ('key' => '{"id1":"val1", "id2": "val2"})
	 * @param files list of files to be write to from data body, expecting list of DTSFPART_FileWrapper
	 * @param stringFiles determines if files should be encoded in form of string (encoded in base64) or
 *                        written in binary form
	 *
	 * @return Blob object, contains encoded data, can be written to HttpRequest using setBodyAsBlob() method
	 */
	public static Blob encodeForm(Map<String, String> params, Map<String, String> jsonParams, List<DTSFPART_FileWrapper> files, Boolean stringFiles){
		String content = '';
		if(params != null && !params.isEmpty()){
			content += writeBodyParams(params);
		}

		if(jsonParams != null && !jsonParams.isEmpty()){
			content += writeJsonParams(jsonParams);
		}

		if (files != null) {
			content = stringFiles? writeStringFiles(content, files): writeBinaryFiles(content, files);
		} else {
			content += getFooter('');
			System.debug('FORM:\n' + EncodingUtil.base64Encode(Blob.valueOf(content)));
			return Blob.valueOf(content);
		}

		System.debug('FORM:\n' + EncodingUtil.base64Encode(Blob.valueOf(content)));
		return stringFiles? Blob.valueOf(content): EncodingUtil.base64Decode(content);
	}

	private static String writeStringFiles(String content, List<DTSFPART_FileWrapper> files){
		for (DTSFPART_FileWrapper file : files) {
			content += getBodyParam(file);
		}

		content += getFooter('');
		return content;
	}

	private static String writeBinaryFiles(String content, List<DTSFPART_FileWrapper> files){
		if(!files.isEmpty()){
			DTSFPART_FileWrapper firstFile = files.remove(0);
			FileEncodingResult encodedFile = getEncodedFile(firstFile);

			content = getEncodedFileHeader(content, firstFile) + encodedFile.content;
			for (DTSFPART_FileWrapper file : files) {
				encodedFile = getEncodedFile(file);
				content += getEncodedFileHeader(encodedFile.ending, file) + encodedFile.content;
			}

			content += getEncodedFooter(encodedFile.ending);
		}

		return content;
	}

	/**
	 * @return Request's content type for multipart/form-data requests.
	 */
	public static String getContentType() {
		return 'multipart/form-data; boundary=' + BOUNDARY;
	}

	private static String getBodyParam(String key, String value){
		return getBodyParam(key, value, '', '');
	}

	private static String getBodyParam(String key, String value, String contentType, String contentEncoding){
		String content = '--' + BOUNDARY + '\r\n';
		content += 'Content-Disposition: form-data; name="' + key + '"\r\n';

		if(String.isNotBlank(contentType)){
			content += 'Content-Type: ' + contentType +'; charset=UTF-8' + '\r\n';
		}

		if(String.isNotBlank(contentEncoding)){
			content += 'Content-Transfer-Encoding: ' + contentEncoding + '\r\n';
		}

		content += '\r\n';
		content += value + '\r\n';

		return content;
	}

	private static String getBodyParam(DTSFPART_FileWrapper file){
		String content = getFileHeader(file);

		content += '\r\nContent-Transfer-Encoding: base64\r\n\r\n';
		content += file.data + '\r\n';

		return content;
	}

	private static String writeBodyParams(Map<String, String> params){
		String content = '';

		for(String key: params.keySet()){
			content += getBodyParam(key, params.get(key));
		}

		return content;
	}

	private static String writeJsonParams(Map<String, String> params){
		String content = '';

		for(String key: params.keySet()){
			content += getBodyParam(key, params.get(key), 'application/json', '8bit');
		}

		return content;
	}

	private static String getFileHeader(DTSFPART_FileWrapper file){
		return '--' + BOUNDARY + '\r\n' +
			   'Content-Disposition: form-data; name="' + file.key + '"; filename="' + file.name +'";\r\n' +
			   'Content-Type: ' + file.mime;
	}

	private static String getEncodedFileHeader(String prefix, DTSFPART_FileWrapper file){
		String header = prefix + getFileHeader(file);
		String encodedFileHeader = EncodingUtil.base64Encode(Blob.valueOf(header + '\r\n\r\n'));
		while (encodedFileHeader.endsWith('=')) {
			header += ' ';
			encodedFileHeader = EncodingUtil.base64Encode(Blob.valueOf(header + '\r\n\r\n'));
		}

		return encodedFileHeader;
	}

	private static String getFooter(String prefix){
		return prefix + '--' + BOUNDARY + '--\r\n';
	}

	private static String getEncodedFooter(String prefix){
		return EncodingUtil.base64Encode(Blob.valueOf(getFooter(prefix)));
	}

	/**
	 * @param file base64 encoded file using DTSFPART_FileWrapper class
	 * @description Encodes binary file, ending is determined because utf8 cannot be directly changed to base64 format
	 *              (base64 is subset of 3 characters), when string in base64 is not subset of 3 characters padding is used,
	 *              '=' is a padding character, to properly encode form data padding needs to be removed from inside of the encoded
	 *              string and moved to the end, so the last 4 bytes of each file is changed to contain OK (\r\n) or N (\r) characters,
	 *              depending on this ending next encoded line will contain proper ending
	 * @return result of encoding binary file, and ending of next element
	 */
	private static FileEncodingResult getEncodedFile(DTSFPART_FileWrapper file){
		FileEncodingResult wrapper = new FileEncodingResult(file.data, '');

		String last4Bytes = wrapper.content.substring(wrapper.content.length() - 4, wrapper.content.length());
		if (last4Bytes.endsWith('==')) {
			last4Bytes = last4Bytes.substring(0, 2) + '0K';
			wrapper.content = wrapper.content.substring(0, wrapper.content.length() - 4) + last4Bytes;
			wrapper.ending = '';
		} else if (last4Bytes.endsWith('=')) {
			last4Bytes = last4Bytes.substring(0, 3) + 'N';
			wrapper.content = wrapper.content.substring(0, wrapper.content.length() - 4) + last4Bytes;
			wrapper.ending = '\n';
		} else {
			wrapper.ending = '\r\n';
		}

		return wrapper;
	}

	private class FileEncodingResult {
		public String content;
		public String ending;

		public FileEncodingResult(String content, String ending){
			this.content = content;
			this.ending = ending;
		}
	}
}