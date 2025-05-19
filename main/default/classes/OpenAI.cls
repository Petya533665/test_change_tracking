public with sharing class OpenAI {

	public static Boolean validateToken(String token) {
		Map<String, String> headers = new Map<String, String>{
				'Content-Type' => 'application/json',
				'Authorization' => 'Bearer ' + token
		};
		try {
			String response = HttpUtils.get(
					ConfigUtil.OPEN_AI_USAGE_ENDPOINT,
					headers,
					401
			);
			return !response.contains('Incorrect API key');
		} catch (HttpUtils.HttpUtilsException e) {
			return true;
		}
	}

}