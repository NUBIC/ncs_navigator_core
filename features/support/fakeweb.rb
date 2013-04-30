# -*- coding: utf-8 -*-


FakeWeb.allow_net_connect = %r[^https?://(localhost|127.0.0.1)]
FakeWeb.register_uri(:get, /\/api\/v1\/subjects\/registered_with_psc$/,
                     :body => "#{Rails.root}/features/fixtures/fakeweb/registered_with_psc.json", :status => ["200", "OK"], :content_type => "application/json")

FakeWeb.register_uri(:get, /\/api\/v1\/subjects\/registered_with_psc\/schedules.json$/,
                    :body => "#{Rails.root}/features/fixtures/fakeweb/registered_with_psc_schedule.json", :status => ["200", "OK"], :content_type => "application/json")


FakeWeb.register_uri(:get, /\/api\/v1\/subjects\/w324-rteb-2c7z$/,
                     :body => "#{Rails.root}/features/fixtures/fakeweb/registered_with_psc.json", :status => ["200", "OK"], :content_type => "application/json")

FakeWeb.register_uri(:get, /\/api\/v1\/subjects\/w324-rteb-2c7z\/schedules.json$/,
                    :body => "#{Rails.root}/features/fixtures/fakeweb/event_windows_participant_schedule.json", :status => ["200", "OK"], :content_type => "application/json")

FakeWeb.register_uri(:get, /\/api\/v1\/subjects\/((?!(registered_with_psc|w324-rteb-2c7z)))/, :body => "Unknown", :status => ["401", "Unknown"])

FakeWeb.register_uri(:get, /\/api\/v1\/studies.json$/,
                     :body => "#{Rails.root}/features/fixtures/fakeweb/studies.json", :content_type => "application/json")

FakeWeb.register_uri(:get, /\/api\/v1\/sites/,
                     :body => "#{Rails.root}/features/fixtures/fakeweb/sites.xml", :content_type => "text/xml")

FakeWeb.register_uri(:get, /\/api\/v1\/studies\/(.*)\/template\/current.xml$/,
                     :body => "#{Rails.root}/features/fixtures/fakeweb/template.xml", :content_type => "text/xml")

FakeWeb.register_uri(:post, /\/api\/v1\/studies\/(.*)\/sites\/(.*)\/subject-assignments$/,
                    :body => "", :status => ["201", "Created"])

# PSC scheduled activity report
[
  %w(end-date=2005-07-30&responsible-user=test_user&start-date=2005-07-01&state=scheduled scheduled_activities_for_july_2005.json),
  %w(end-date=2012-03-01&responsible-user=test_user&start-date=2012-02-01&state=scheduled scheduled_activities_for_february.json),
  %w(end-date=2013-01-07&responsible-user=test_user&start-date=2013-01-01&state=scheduled scheduled_activities_2013-01-01.json)
].each do |qs, fn|
  FakeWeb.register_uri(:get, %r[/api/v1/reports/scheduled-activities\.json\?#{qs}$],
                       :body => File.expand_path("../../fixtures/fakeweb/#{fn}", __FILE__),
                       :status => ['200', 'OK'],
                       :content_type => 'application/json')
end
