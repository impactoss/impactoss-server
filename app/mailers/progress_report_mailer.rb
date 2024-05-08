class ProgressReportMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.progress_report_mailer.updated.subject
  #
  def updated(progress_report, category)
    return if category.manager_email.blank?

    @category = category
    @indicator = progress_report.indicator
    @manager_name = @category.manager_name
    @client_url = ENV.fetch("CLIENT_URL", "https://undefined.client.url")

    mail to: @category.manager_email, subject: I18n.t("progress_report_mailer.updated.subject")
  end
end
