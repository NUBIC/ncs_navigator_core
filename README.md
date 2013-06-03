NCS Navigator Cases (formerly known as NCS Navigator Core)
==================

NCS Navigator Cases (formerly NCS Navigator Core) manages participant
activity and records interactions between Study Center personnel and participants.
It can be used as a way to administer instruments to a participant
for any event in the participant cycle. Also it is used to
synchronize data between the NCS Navigator Offline [field]][] application
and the NCS Navigator Core application.

Cases extensively uses [Patient Study Calendar][] [PSC][] to not only determine
the participant schedule but also to inform Cases of the structure of
the National Children's Study [NCS][].

The data schema is based on the Master Data Element Specification (MDES)
of the National Children Study, versions 2.0-2.2.

It is a Ruby on Rails application which uses Rails 3 and a PostgreSQL
database.

[field]: https://github.com/NUBIC/ncs_navigator_field
[Patient Study Calendar]: https://cabig.nci.nih.gov/community/tools/PatientStudyCalendar
[PSC]: https://github.com/NCIP/psc
[NCS]: http://www.nationalchildrensstudy.gov/Pages/default.aspx

Prerequisites
-------------

On the deployment workstation:

* Ruby 1.9.3
* RubyGems
* [Bundler][] (install as a gem)
* A [git][] client

On the application server:

* Ruby 1.9.3
* RubyGems
* [Bundler][] (install as a gem)
* [Passenger][]
* A [git][] client
* Access to a PostgreSQL server

[Bundler]: http://gembundler.com/
[git]: http://git-scm.com/
[Passenger]: http://modrails.com/
[ree]: http://www.rubyenterpriseedition.com/

Setup
-----

### Configuration on the application server

#### Database setup

Cases uses [bcdatabase][] to discover the database
configuration to use. Bcdatabase looks for a [YAML][] file with a
particular structure under `/etc/nubic/db`.

[bcdatabase]: https://github.com/NUBIC/bcdatabase/blob/master/README.markdown
[YAML]: http://yaml.org/

* For a staging deployment, the file name should be `/etc/nubic/db/ncsdb_staging.yml`
* For production, it should be `/etc/nubic/db/ncsdb_prod.yml`

Example:

    defaults:
      adapter: postgresql
      host: ncsdb-staging
      port: 5432
    ncs_navigator_core:
      database: ncs_navigator_core_staging   # database name
      username: ncs_navigator_core
      password: ncs_navigator_core

#### Authentication setup

Cases uses [Aker-Rails][] and [Aker][] for authentication.

[Aker-Rails]: https://github.com/NUBIC/aker-rails/
[Aker]: http://rubydoc.info/github/NUBIC/aker/

First, create a file under `/etc/nubic/ncs` for the the central
authentication parameters. These parameters will be used for all NCS
Navigator applications on the same server.

* In staging, the file name should be `aker-staging.yml`
* In production, the file name should be `aker-prod.yml`

Contents:

    cas:
      base_url: https://cas.myinst.edu/

Second, define a bootstrap user in
`/etc/nubic/ncs/navigator.ini`. (See [NCS Staff Portal][] setup.)

Finally, Cases (and most of the applications in the NCS Navigator suite) use
the [ncs_navigator_authority][] gem for authentication, which requires a running
instance of NCS Staff Portal [ncs_staff_portal][] setup with Staff having particular roles.

[ncs_navigator_authority]: https://github.com/NUBIC/ncs_navigator_authority
[ncs_staff_portal]: https://github.com/NUBIC/ncs_staff_portal

#### Center-specific setup

Cases uses [ncs_navigator_configuration][] for shared
configuration of the NCS Navigator suite applications. Most
configuration properties are documented in its [sample
configuration][ncsn_conf_sample]. Cases looks for the
configuration in its default location, `/etc/nubic/ncs/navigator.ini`.

[ncs_navigator_configuration]: https://github.com/NUBIC/ncs_navigator_configuration
[ncsn_conf_sample]: http://rubydoc.info/gems/ncs_navigator_configuration/file/sample_configuration.ini

To further customize Cases for your center, add one or more of
the following configuration elements to the `[Core]` section of
the configuration file.

    # Configuration options which are used by or which describe NCS
    # Navigator Cases in this instance of the suite.

    # The root URI for NCS Navigator Cases.
    uri = "https://ncsnavigator.ncsstudycenter.org/"

    # The Name and Phone number of the Study Center
    study_center_name = "NCS Study Center"
    study_center_phone_number = "123-555-1234"
    toll_free_number = "800-555-1234"

    # Whether or not the Study Center collects specimens and samples
    with_specimens = "true"

    # The identifier of the specimen/sample shipper
    shipper_id = "shipper_id"

    # The email addresses used in the application
    mail_from = "ncs_navigator@greaterchicagoncs.org"
    email_exception_recipients = "dev@greaterchicagoncs.org pm@greaterchicagoncs.org"


### Deployment

Cases is deployed with [capistrano][cap] from a workstation. On
the workstation, you need to create a configuration file
`/etc/nubic/db/ncs_deploy.yml` to describe where it should be
deployed to.

[cap]: https://github.com/capistrano/capistrano/wiki/

Example:

    ncs_navigator_core:
      # Repository for cases. This will always be this value
      # unless you wish to deploy your own fork.
      repo: "git://github.com/NUBIC/ncs_navigator_core.git"
      # path on the server where application will be deployed
      deploy_to: "/www/apps/ncs_navigator_core"
      # staging server hostname
      staging_app_server: "staging.server"
      # production server hostname
      production_app_server: "production.server"


After you check out the code, run `bundle install` to install the gems
you'll need. The first time you deploy, capistrano needs to set up the
directory layout it expects:

    $ bundle exec cap production deploy:setup

Then deploy to the configured server:

    $ bundle exec cap production deploy:migrations

(This deploys to your production server; to deploy to staging instead,
substitute "staging" for "production".)

After the first deployment, you should only need to run
`deploy:migrations` to get new versions. You can also use
`deploy:pending` to see what would be deployed.

If you have problems deploying, you can run this:

    $ bundle exec cap production deploy:check

and capistrano will try to tell you why it cannot deploy.

if you make changes to the footer logo paths in navigator.ini in between
deploys, you have to run rake task to copy images

    $ bundle exec cap production config:images

#### Deployment user

As currently configured, Cases will be deployed as the user you
use to connect to the application server. The target directory must be
writable by that user, and (by way of Passenger) the software will be
executed with that users' permissions.

Most likely, the use account you use to connect to the application
server will be your personal account. We [may add specific
support][1622] for deploying using a different account from the login
account, but an option for now is to use an alias defined in
`.ssh/config` on the workstation. See issue [1622][] for a more
detailed discussion of this option.

[1622]: https://code.bioinformatics.northwestern.edu/issues/issues/show/1622

### Initialization

Cases relies on many lists of data as determined by the MDES (see Code lists below).
It ships with [rake][] tasks which will populate these lists
from outside sources.

All the tasks should be executed from the application root on the
server where the application is deployed. Each one will need to be run
at least once for each environment in which Cases is deployed.

RAILS_ENV needs to be set to the appropriate value (production, staging) when running
the various setup rake tasks for production or staging environment.
e.g `bundle exec rake db:seed RAILS_ENV=production`

[rake]: http://rake.rubyforge.org/

#### Code lists

Initialize the code lists from the MDES using [ncs_mdes][]:

    $ bundle exec rake db:seed

[ncs_mdes]: https://github.com/NUBIC/ncs_mdes

#### Instruments

Cases uses [surveyor][] to create the instruments used by the [NCS][]. These surveys
are proprietary and not currently available to the public. They are packaged as a
separate [ncs-instruments][] gem. Follow the instructions there to copy the instruments
into a directory named surveys at the root of the deployed application.

Once the instruments are in the surveys directory, Cases is shipped with a [rake][] task
that will parse the survey syntax and load the surveys into the database.

    $ bundle exec rake setup:surveys

[surveyor]: https://github.com/NUBIC/surveyor
[ncs-instruments]: https://github.com/NUBIC/ncs_navigator_instruments
