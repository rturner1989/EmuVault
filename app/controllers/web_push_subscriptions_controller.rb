# frozen_string_literal: true

class WebPushSubscriptionsController < ApplicationController
  def create
    authorize! current_user

    current_user.web_push_subscriptions.find_or_create_by!(
      endpoint: subscription_params[:endpoint]
    ) do |sub|
      sub.p256dh = subscription_params[:p256dh]
      sub.auth = subscription_params[:auth]
    end

    head :created
  end

  def destroy
    authorize! current_user

    current_user.web_push_subscriptions
           .find_by(endpoint: params[:endpoint])
           &.destroy

    head :no_content
  end

  private def subscription_params
    params.require(:web_push_subscription).permit(:endpoint, :p256dh, :auth)
  end
end
