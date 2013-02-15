module ApplicationHelper
  def tabulated_error_messages_for(*params)
    options = params.last.is_a?(Hash) ? params.pop.symbolize_keys : {}
    objects = params.collect { |object_name| instance_variable_get("@#{ object_name }") }.compact
    count   = objects.inject(0) { |sum, object| sum + object.errors.count }
    unless count.zero?
      error_messages = objects.map { |object| object.errors.full_messages.map { |msg| content_tag(:div, "&#8226; #{ msg }") } }
      <<-EOS
        <table class="errors">
          <tr>
            <td class="item">Your #{ params.first } has not been created</td>
            <td>#{ error_messages }</td>
          </tr>
        </table>
      EOS
    else
      ""
    end
  end
  
  def multi_select(param_name, select_options, current_options = [], html_options = {}, options ={})
    field_name = options[:override_label].blank? ? param_name.to_s.humanize : options[:override_label]
    default_html_options = { :multiple => true, :name => "#{ param_name }[]" }
    html_options  = default_html_options.merge(html_options)
    
    content_tag("label",
      content_tag("span", field_name) +
        select_tag(param_name, options_for_select(select_options, current_options), html_options) )
  end
end
