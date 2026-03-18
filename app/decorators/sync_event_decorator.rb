# frozen_string_literal: true

class SyncEventDecorator < ApplicationDecorator
  DEVICE_BADGE_COLORS = { phone: :orange, tablet: :yellow, desktop: :purple }.freeze

  def device_type
    ua = user_agent.to_s
    if ua.match?(/iPad|Android.*Tablet|Kindle/i)
      :tablet
    elsif ua.match?(/Mobile|Android|iPhone|iPod/i)
      :phone
    else
      :desktop
    end
  end

  def device_label
    { phone: "Phone", tablet: "Tablet", desktop: "Desktop" }[device_type]
  end

  def device_badge_color
    DEVICE_BADGE_COLORS[device_type]
  end

  def action_label
    object.action.to_s == "push" ? "Upload" : "Download"
  end

  def action_icon
    object.action.to_s == "push" ? "fa-arrow-up" : "fa-arrow-down"
  end

  def action_badge_color
    object.action.to_s == "push" ? :green : :cyan
  end

  def performed_at_label
    object.performed_at.strftime("%b %-d, %Y at %H:%M")
  end

  def game_title
    object.game_save.game.title
  end

  def game_id
    object.game_save.game_id
  end
end
