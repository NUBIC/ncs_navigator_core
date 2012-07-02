# -*- coding: utf-8 -*-


# Disable JSON root generation for Surveyor.
# FIXME: This should really live somewhere else, like an #as_json option.

require 'rabl'
Rabl.register!
Rabl.configure {|config| config.include_json_root = false }