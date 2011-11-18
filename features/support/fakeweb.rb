FakeWeb.allow_net_connect = %r[^https?://(localhost|127.0.0.1)]

FakeWeb.register_uri(:get, /\/api\/v1\/subjects\/registered_with_psc$/, 
                     :body => "#{Rails.root}/features/fixtures/fakeweb/registered_with_psc.json", :status => ["200", "OK"], :content_type => "application/json")

FakeWeb.register_uri(:get, /\/api\/v1\/subjects\/registered_with_psc\/schedules.json$/, 
                    :body => "#{Rails.root}/features/fixtures/fakeweb/registered_with_psc_schedule.json", :status => ["200", "OK"], :content_type => "application/json")

FakeWeb.register_uri(:get, /\/api\/v1\/subjects\/((?!registered_with_psc))/, :body => "Unknown", :status => ["401", "Unknown"])

FakeWeb.register_uri(:get, /\/api\/v1\/studies.json$/,
                     :body => "#{Rails.root}/features/fixtures/fakeweb/studies.json", :content_type => "application/json")

FakeWeb.register_uri(:get, /\/api\/v1\/sites/, 
                     :body => "#{Rails.root}/features/fixtures/fakeweb/sites.xml", :content_type => "text/xml")

FakeWeb.register_uri(:get, /\/api\/v1\/studies\/(.*)\/template\/current.xml$/,
                     :body => "#{Rails.root}/features/fixtures/fakeweb/template.xml", :content_type => "text/xml")

FakeWeb.register_uri(:post, /\/api\/v1\/studies\/(.*)\/sites\/(.*)\/subject-assignments$/,
                    :body => "", :status => ["201", "Created"])

FakeWeb.register_uri(:get, /\/api\/v1\/reports\/scheduled-activities.json/,
                    :body => "#{Rails.root}/features/fixtures/fakeweb/scheduled_activities.json", :status => ["200", "OK"])
                    
FakeWeb.register_uri(:post, /\/api\/v1\/studies\/(.*)\/schedules\/(.*)/,
                    :body => "", :status => ["201", "Created"])
