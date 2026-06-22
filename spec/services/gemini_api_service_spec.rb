require 'rails_helper'

RSpec.describe GeminiApiService do
  let(:service) { described_class.new }

  describe '#explain' do
    context 'DBキャッシュがある場合' do
      let!(:cached) { create(:kigo_explanation) }

      it 'APIを呼ばずにキャッシュを返すこと' do
        result = service.explain('蛙')
        expect(result).to eq(cached)
      end
    end

    context 'DBキャッシュがない場合' do
      let(:api_response_body) do
        {
          candidates: [{
            content: {
              parts: [{
                text: {
                  season: '春',
                  canonical_word: nil,
                  parent_kigo: nil,
                  explanation: '春の季語。'
                }.to_json
              }]
            }
          }]
        }.to_json
      end

      before do
        allow(ENV).to receive(:fetch)
          .with('GEMINI_API_KEY')
          .and_return('test-key')
        stub_request(:post, /generativelanguage\.googleapis\.com/)
          .to_return(
            status: 200,
            body: api_response_body,
            headers: {
              'Content-Type' => 'application/json'
            }
          )
      end

      it 'APIから取得してDBに保存すること' do
        expect do
          service.explain('桜')
        end.to change(KigoExplanation, :count).by(1)
      end

      it '正しいデータを返すこと' do
        result = service.explain('桜')
        expect(result.kigo_word).to eq('桜')
        expect(result.season).to eq('春')
      end
    end

    context 'APIがエラーを返した場合' do
      before do
        allow(ENV).to receive(:fetch)
          .with('GEMINI_API_KEY')
          .and_return('test-key')
        stub_request(:post, /generativelanguage\.googleapis\.com/)
          .to_return(status: 500, body: 'Error')
      end

      it 'ApiErrorが発生すること' do
        expect do
          service.explain('桜')
        end.to raise_error(described_class::ApiError)
      end
    end
  end
end
