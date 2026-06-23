class GeminiApiService
  API_URL = 'https://generativelanguage.googleapis.com'.freeze
  MODEL = 'gemini-2.5-flash'.freeze
  TIMEOUT = 15

  PROMPT_TEMPLATE = <<~PROMPT.freeze
    あなたは俳句の季語に関する専門家です。
    以下の語について、季語としての情報をJSON形式で回答してください。
    句の内容には一切触れず、季語の解説のみを行ってください。

    重要な注意:
    - 確信が持てない場合は推測せず、season を "none" としてください。
    - 入力された語が子季語の場合、必ず親季語を記載してください。
    - season は以下の細分類から最も適切なものを1つ選んでください:
      春: 三春/初春/仲春/晩春
      夏: 三夏/初夏/仲夏/晩夏
      秋: 三秋/初秋/仲秋/晩秋
      冬: 三冬/初冬/仲冬/晩冬
      その他: 暮/新年/none
    語: 「%<kigo>s」

    以下のJSON形式で回答してください（コードブロックなし、JSONのみ）:
    {
      "season": "上記の細分類から1つ",
      "canonical_word": "正式な季語（入力と同じなら null）",
      "parent_kigo": "親季語があれば記載（なければ null）",
      "explanation": "季語としての解説（50〜150字程度）。無季の場合は null"
    }
  PROMPT

  class ApiError < StandardError; end

  def initialize
    @api_key = nil
    @connection = nil
  end

  def explain(kigo_word)
    cached = KigoExplanation.find_by(kigo_word: kigo_word)
    return cached if cached

    data = fetch_from_api(kigo_word)
    KigoExplanation.create!(
      kigo_word: kigo_word,
      season: data['season'] || 'none',
      canonical_word: data['canonical_word'],
      parent_kigo: data['parent_kigo'],
      explanation: data['explanation']
    )
  end

  private

  def connection
    @connection ||= Faraday.new(
      url: API_URL,
      request: { timeout: TIMEOUT }
    )
  end

  def api_key
    @api_key ||= ENV.fetch('GEMINI_API_KEY')
  end

  def fetch_from_api(kigo_word)
    prompt = format(PROMPT_TEMPLATE, kigo: kigo_word)
    path = "/v1beta/models/#{MODEL}:generateContent"

    response = connection.post(path) do |req|
      req.params['key'] = api_key
      req.headers['Content-Type'] = 'application/json'
      req.body = {
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: {
          responseMimeType: 'application/json'
        }
      }.to_json
    end

    handle_response(response)
  end

  def handle_response(response)
    unless response.success?
      raise ApiError,
            "Gemini API error: #{response.status}"
    end

    body = JSON.parse(response.body)
    text = body.dig(
      'candidates', 0, 'content', 'parts', 0, 'text'
    )
    raise ApiError, 'Empty response from API' if text.blank?

    JSON.parse(text)
  rescue JSON::ParserError
    raise ApiError, 'Invalid JSON from API'
  end
end
