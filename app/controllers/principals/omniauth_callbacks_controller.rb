# frozen_string_literal: true

module Principals
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :verify_authenticity_token, only: :developer

    def developer
      @principal = Principal.from_omniauth(forged_developer_hash(request.env["omniauth.auth"]))

      if @principal.save
        flash[:notice] = t("auth.success")
        sign_in_and_redirect @principal
      else
        flash[:alert] = t("auth.failure")
        redirect_to login_path
      end
    end

    private

    def forged_developer_hash(attrs)
      forged = {
        "credentials" => { token: "fake token", secret: "fake secret" }
      }

      attrs.merge(forged)
    end
  end
end
