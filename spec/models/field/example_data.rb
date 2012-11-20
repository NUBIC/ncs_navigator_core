require 'spec_helper'

shared_context 'example data' do
  let(:data_fn) { File.expand_path('../../../fixtures/psc/scheduled_activity_report.json', __FILE__) }
  let(:data) { JSON.parse(File.read(data_fn)) }

  let(:activity_name) { 'Low-Intensity Interview' }
  let(:event_data_collection) { 'event:low_intensity_data_collection' }
  let(:event_informed_consent) { 'event:informed_consent' }
  let(:ideal_date) { '2012-07-06' }
  let(:instrument_pregnotpreg) { 'instrument:2.0:ins_que_lipregnotpreg_int_li_p2_v2.0' }
  let(:person_id) { '2f85c94e-edbb-4cbe-b9ab-5f12c033323f' }
  let(:scheduled_date) { '2012-07-10' }
end
