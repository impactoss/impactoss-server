# Preview all emails at http://localhost:3000/rails/mailers/due_date_mailer
class DueDateMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/due_date_mailer/due
  def due
    DueDateMailer.due(FactoryBot.create(:due_date, :with_manager))
  end

  # Preview this email at http://localhost:3000/rails/mailers/due_date_mailer/overdue
  def overdue
    DueDateMailer.overdue(FactoryBot.create(:due_date, :with_manager))
  end
end
