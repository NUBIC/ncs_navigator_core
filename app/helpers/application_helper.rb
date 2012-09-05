# -*- coding: utf-8 -*-


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

  def mdes_version_is_after?(version = 3.0)
    NcsNavigatorCore.mdes.version.to_f >= version
  end

  # text helpers

  def blank_safe(str, default = "___")
    str.blank? ? default : str
  end

  def nil_safe(str, default = "___")
    str.nil? ? str.inspect : blank_safe(str, default)
  end

  def display_person(person)
    person.to_s.blank? ? "#{person.public_id}" : "#{person}"
  end

  def display_participant(participant)
    participant.person ? display_person(participant.person) : "#{participant.public_id}"
  end

  def public_identifier_row(id)
    id = id.to_s
    (id.length < 16) ? content_tag(:td, id) : content_tag(:td, truncate(id, :length => 16), :title => id)
  end

  ##
  # Takes MDES formatted phone number (XXXYYYZZZZ)
  # and parses into area code, exchange, and line number
  def phone_number_formatter(nbr, separator = "-")
    return nbr if nbr.to_s.length != 10
    nbr.insert(3, separator).insert(7, separator)
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

  def sample_type(value)
    value = sample_extenstion(value).downcase
    if value.include? "ur"
      "URINE"
    elsif ( (value.include? "rb") || (value.include? "ad") || (value.include? "lv") || (value.include? "px"))
      "WHOLE BLOOD"
    elsif ( (value.include? "ss") || (value.include? "rd"))
      "SERUM"
    elsif ( (value.include? "pp") || (value.include? "pn"))
      "PLASMA"
    elsif value.include? "db"
      "DUST"
    elsif value.include? "w"
      "WATER"
    else
      "TYPE UNKNOWN"
    end

  end

  def sample_root_id(value)
    dash = value.index("-")
    value[0, dash]
  end

  def sample_extenstion(value)
    dash = value.index("-") + 1
    value[dash, value.length]
  end

  def continuable?(event)
    continuable_events = [ PatientStudyCalendar::PREGNANCY_SCREENER,
                           PatientStudyCalendar::BIRTH_VISIT_INTERVIEW,
                           PatientStudyCalendar::HI_LO_CONVERSION,
                           PatientStudyCalendar::INFORMED_CONSENT ]

    continuable_events.include?(event.to_s)
  end

end
