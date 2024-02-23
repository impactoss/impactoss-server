# frozen_string_literal: true

# For some reason this isn't set properly in the job environment
I18n.locale = Rails.application.config.i18n.locale

class ApplicationJob < ActiveJob::Base
end
