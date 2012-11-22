##
# An {Instrument}, like an {Event}, starts its life in PSC as an activity
# label.
#
# An instrument label looks like this:
#
#     2.0:ins_que_lipregnotpreg_int_li_p2_v2.0
#
# From this, it is possible to derive the instrument's version, type code, and
# name.  This class wraps a string with methods to do that.
class InstrumentLabel
  def initialize(label)
    @label = label
    @components = @label.split(':', 2)
  end

  def version
    @components.length < 2 ? nil : @components.first
  end

  def access_code
    @components.last
  end

  ##
  # Retrieving the type code for an instrument label is kind of evil.  At
  # present, the following procedure is required:
  #
  # 1. interpret the instrument label as an access code
  # 2. find the latest survey for the access code
  # 3. find the NCS instrument type code whose display text matches the
  #    survey's title
  def ncs_code
    s = Survey.most_recent_for_access_code(access_code)

    NcsCode.for_attributes('instrument_type_code').where(:display_text => s.try(:title)).first
  end
end
