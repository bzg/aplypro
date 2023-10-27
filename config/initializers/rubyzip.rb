# frozen_string_literal: true

require "zip"

Zip.unicode_names = true
Zip.force_entry_names_encoding = "UTF-8"
Zip.continue_on_exists_proc = true