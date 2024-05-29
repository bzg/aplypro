# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join("spec", "support", "**", "*.rb")].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

module Helpers
  module ReadOnlyBypass
    # sometimes we need setup our test data by modifying things that
    # aren't supposed to be modified: the RIBs are marked `readonly?`
    # whilst there's an active payment request. This helper allows
    # bypassing the constraint for the sake of nicer tests.
    def with_readonly_bypass(model)
      model.instance_eval do
        def readonly?
          false
        end

        yield(model) if block_given?
      end
    end
  end
end

RSpec.configure do |config|
  require "./mock/factories/asp"

  require "./mock/apis/factories/sygne"
  require "./mock/apis/factories/fregata"

  config.before(:suite) do
    Rails.application.load_seed if missing_seeds?
  end

  config.include Helpers::ReadOnlyBypass

  config.include FactoryBot::Syntax::Methods

  config.include Devise::Test::IntegrationHelpers, type: :request

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.define_derived_metadata(file_path: %r{spec/apis/students_api/}) do |meta|
    meta[:student_api] = true
  end

  config.when_first_matching_example_defined :student_api do
    include WebmockHelpers
  end

  config.define_derived_metadata(file_path: %r{spec/lib/asp/entities/}) do |meta|
    meta[:asp_entity] = true
  end

  config.when_first_matching_example_defined :asp_entity do
    def mock_entity(name)
      klass = "ASP::Entities::#{name}".constantize
      double = instance_double(name)

      allow(double).to receive(:to_xml) { |builder| builder.send(name.downcase) }
      allow(klass).to receive(:from_payment_request).and_return(double)
    end
  end

  def missing_seeds?
    Mef.none?
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

Timecop.safe_mode = true
