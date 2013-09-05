module ApplicationHelper
  # Renders div container with flash messages
  # Available flash message types:
  # * info (blue)
  # * notice (yellow)
  # * success (green)
  # * error (red)
  # @return [String] rendered <div class='flash'> container with flash messages or nil
  #   if there are no flash messages
  def flash_messages
    return if flash.empty?

    content_tag(:div, class: 'flash container') do
      flash.collect do |type, message|
        if message.present?
          content_tag(:div, class: "alert alert-#{type}") do
            content_tag(:p, message)
          end
        end
      end.join("\n").html_safe
    end
  end
end
