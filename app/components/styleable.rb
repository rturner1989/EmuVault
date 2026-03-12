# frozen_string_literal: true

module Styleable
  extend ActiveSupport::Concern

  def style(name = self.class.default_style_name, **)
    self.class.style_for(name, **)
  end

  class_methods do
    def style_for(name = default_style_name, **)
      styles = style_config[name.to_sym]
      return [] if styles.blank?

      default_classes = Array(styles[:default])
      compiled_styles = compile_styles(styles, **)
      (default_classes + compiled_styles).compact
    end

    def style(name = default_style_name, **config)
      style_config[name.to_sym] ||= config.freeze
    end

    def style_config
      @style_config ||= {}
    end

    def default_style_name
      @default_style_name ||= name.demodulize.underscore
    end

    def compile_styles(styles, **kwargs)
      kwargs.flat_map do |k, v|
        style = styles.with_indifferent_access.dig(k, v)

        case style
        when Proc then style.call(**kwargs)
        else style
        end
      end
    end
  end
end
