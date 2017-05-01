class DueDateMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.due_date_mailer.due.subject
  #
  def due(due_date)
    return unless due_date.manager_email
    @indicator = due_date.indicator
    @due_date = due_date
    @manager_name = due_date.manager_name

    mail to: due_date.manager_email, subject: I18n.t('due_date_mailer.due.subject')
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.due_date_mailer.overdue.subject
  #
  def overdue(due_date)
    return unless due_date.manager_email
    @indicator = due_date.indicator
    @due_date = due_date
    @manager_name = due_date.manager_name

    mail to: due_date.manager_email, subject: I18n.t('due_date_mailer.overdue.subject')
  end
end
