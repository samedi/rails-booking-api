# frozen_string_literal: true

# Parent class for all user-facing controllers.
class ApplicationController < ActionController::Base
  before_action :set_locale

  private

  helper_method def current_patient
    @current_patient ||= load_patient
  end

  def authorize_patient(access_token)
    session[:patient_access_token] = access_token
  end

  def load_patient
    patient_access_token = session[:patient_access_token]
    return nil unless patient_access_token

    Patient.new(access_token: patient_access_token)
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    { locale: I18n.locale }
  end
end
