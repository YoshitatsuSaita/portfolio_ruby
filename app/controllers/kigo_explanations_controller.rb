class KigoExplanationsController < ApplicationController
  before_action :logged_in_user

  def show
    @haiku = Haiku.find(params[:haiku_id])
    service = GeminiApiService.new
    @explanation = service.explain(@haiku.kigo)
  rescue GeminiApiService::ApiError
    @error = '季語の解説を取得できませんでした。' \
             '時間をおいて再度お試しください。'
  end

  def destroy
    @haiku = Haiku.find(params[:haiku_id])
    KigoExplanation.find_by(kigo_word: @haiku.kigo)&.destroy
    redirect_to haiku_kigo_explanation_path(@haiku)
  end
end
