class ComfyBlog::FormBuilder < ActionView::Helpers::FormBuilder
  
  helpers = field_helpers -
    %w(hidden_field fields_for) +
    %w(select)
    
  helpers.each do |name|
    class_eval %Q^
      def #{name}(field, *args)
        options = args.extract_options!
        args << options
        return super if options.delete(:disable_builder)
        default_field('#{name}', field, options){ super }
      end
    ^
  end
  
  def default_field(type, field, options = {}, &block)
    errors = if object.respond_to?(:errors) && object.errors[field].present?
      "<div class='errors'>#{[object.errors[field]].flatten.first}</div>"
    end
    if desc = options.delete(:desc)
      desc = "<div class='desc'>#{desc}</div>"
    end
    %(
      <div class='control-group #{'error' if errors}'>
        #{label_for(field, options)}
        <div class='controls'>
          #{yield}
          <div class="help-inline">#{errors}</div>
        </div>
        #{desc}
      </div>
    ).html_safe
  end
  
  def label_for(field, options)
    label = options.delete(:label) || field.to_s.titleize.capitalize
    "<label for=\"#{object_name}_#{field}\" class='control-label'>#{label}</label>".html_safe
  end
  
  def simple_field(label = nil, content = nil, options = {}, &block)
    content ||= @template.capture(&block) if block_given?
    %(
      <div class='control-group #{options.delete(:class)}'>
        #{label}
        <div class='controls'>#{content}</div>
      </div>
    ).html_safe
  end
  
end