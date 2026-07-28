class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }, unless: -> { Rails.env.test? }

  def new
  end

  def create
    if @user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for @user
      redirect_to after_authentication_url
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = "Try another email address or password."
          render status: :unprocessable_entity
        end
        format.html { redirect_to new_session_path, alert: "Try another email address or password." }
      end
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end
end
