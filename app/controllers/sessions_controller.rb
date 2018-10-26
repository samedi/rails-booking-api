# frozen_string_literal: true

# Provides actions for authenticating patients.
class SessionsController < ApplicationController
  def create
    authorize_patient(auth_hash.credentials.access_token)
    redirect_to request.env['omniauth.origin'] || root_url
  end

  def destroy
    session.destroy
    redirect_to root_url
  end

  def show_access_token
    redirect_to root_url if !current_patient || !Rails.env.development?
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
