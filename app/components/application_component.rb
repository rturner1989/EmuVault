# frozen_string_literal: true

class ApplicationComponent < ViewComponent::Base
  include Styleable

  def generate_id
    "gen_#{SecureRandom.uuid.delete('-')}"
  end

  # Converts class name to Stimulus controller identifier.
  # e.g. Layouts::AppShellComponent -> "layouts--app-shell-component"
  def js_controller_name
    self.class.name.underscore.dasherize.gsub("/", "--")
  end

  TARGET_MAPPINGS = {
    blank: "_blank",
    self: "_self",
    parent: "_parent",
    top: "_top"
  }.freeze

  private def target_for(target)
    return nil if target.nil?
    return target if TARGET_MAPPINGS.value?(target)

    TARGET_MAPPINGS[target.to_sym]
  end
end
