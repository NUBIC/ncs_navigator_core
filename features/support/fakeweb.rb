FakeWeb.allow_net_connect = %r[^https?://(localhost|127.0.0.1)]

FakeWeb.register_uri(:get, /^http:\/\/pfr957:psc@localhost:8080\/psc\/api\/v1\/subjects\//, :body => "Unknown", :status => ["401", "Unknown"])

FakeWeb.register_uri(:get, /\/psc\/api\/v1\/studies.json$/,
                     :body => "#{Rails.root}/features/fixtures/fakeweb/studies.json", :content_type => "application/json")

FakeWeb.register_uri(:get, /\/psc\/api\/v1\/sites/, 
                     :body => "#{Rails.root}/features/fixtures/fakeweb/sites.xml", :content_type => "text/xml")

FakeWeb.register_uri(:get, /\/psc\/api\/v1\/studies\/(.*)\/template.xml$/,
                     :body => "#{Rails.root}/features/fixtures/fakeweb/template.xml", :content_type => "text/xml")

FakeWeb.register_uri(:post, /\/psc\/api\/v1\/studies\/(.*)\/sites\/(.*)\/subject-assignments$/,
                    :body => "", :status => ["201", "Created"])

