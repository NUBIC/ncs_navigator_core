PSC Fixtures
============

This directory contains artifacts which are used to test Cases' integration with
PSC without PSC running.

## Template updates

When you update the main exported template (NCS Hi-Lo.xml), please
simultaneously update the snapshot in `current_hilo_template_snapshot.xml`.
A snapshot is the result from either of these resources in PSC's API:
  * `studies/{study-identifier}/template/current.xml` (for last released)
  * `studies/{study-identifier}/template/development.xml` (for current development, if any)

Failure to update the snapshot will make some of the tests (e.g.,
`spec/lib/psc_template_spec.rb`) not reflective of the runtime system and so
useless.
