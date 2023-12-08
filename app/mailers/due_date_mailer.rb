class DueDateMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.due_date_mailer.due.subject
  #
  def due(due_date)
    return unless due_date.manager_email
    @indicator = due_date.indicator
    @due_date = due_date.due_date
    @manager_name = due_date.manager_name
    @client_url = ENV["CLIENT_URL"] || "https://undefined.client.url"

    mail to: due_date.manager_email, subject: I18n.t("due_date_mailer.due.subject")
  end

  def category_due(due_date, category)
    return unless category.manager_email
    @indicator = due_date.indicator
    @category = category
    @due_date = due_date.due_date
    @client_url = ENV["CLIENT_URL"] || "https://undefined.client.url"

    mail to: category.manager_email, subject: I18n.t("due_date_mailer.category_due.subject")
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.due_date_mailer.overdue.subject
  #
  def overdue(due_date)
    return unless due_date.manager_email
    @indicator = due_date.indicator
    @due_date = due_date.due_date
    @manager_name = due_date.manager_name
    @client_url = ENV["CLIENT_URL"] || "https://undefined.client.url"

    mail to: due_date.manager_email, subject: I18n.t("due_date_mailer.overdue.subject")
  end

  def category_overdue(due_date, category)
    return unless category.manager_email
    @indicator = due_date.indicator
    @category = category
    @due_date = due_date.due_date
    @client_url = ENV["CLIENT_URL"] || "https://undefined.client.url"

    mail to: category.manager_email, subject: I18n.t("due_date_mailer.category_overdue.subject")
  end
end
