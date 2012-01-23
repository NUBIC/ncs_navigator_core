module ApplicationHelper

  def javascript(*files)
    content_for(:head) { javascript_include_tag(*files) }
  end

  def title(page_title, show_title = true)
    @show_title = show_title
    content_for(:title) { page_title.to_s }
  end

  def show_title?
    @show_title
  end

  def app_version_helper
    version_filename = "#{Rails.root}/config/app_version.yml"
    version  = "0.0.0"
    if File.exists?(version_filename)
      app_version = YAML.load_file(version_filename)
      version = "#{app_version["major"]}.#{app_version["minor"]}.#{app_version["revision"]}"
    end
    "Release Version #{version}"
  end

  # text helpers

  def blank_safe(str, default = "___")
    str.blank? ? default : str
  end

  # Nested Attribute Form Helpers

  def generate_nested_attributes_template(f, association, association_prefix = nil )
    association_prefix = association.to_s.singularize if association_prefix.nil?
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |form_builder|
      render(association_prefix, :f => form_builder)
    end
    escape_javascript(fields)
  end

  def link_to_add_fields(name, association, additional_class = nil)
    link_to(name, 'javascript:void(0);', :class => "add_#{association.to_s} add add_link icon_link #{additional_class}", :id => "add_#{association.to_s}")
  end

  def link_to_remove_fields(name, f, association)
    f.hidden_field(:_destroy) + link_to(name, "javascript:void(0);", :class => "delete_#{association.to_s} delete_link icon_link")
  end

  def nested_record_id(builder, association)
    builder.object.id.nil? ? "new_nested_record" : "#{association.to_s.singularize}_#{builder.object.id}"
  end

  # Dispositions


  def grouped_disposition_codes(group = nil, selected_key = nil)
    grouped_options_for_select(DispositionMapper.get_grouped_options(group), selected_key, "-- Select Disposition --")
  end

end
