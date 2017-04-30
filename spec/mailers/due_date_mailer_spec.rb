require "rails_helper"

RSpec.describe DueDateMailer, type: :mailer do
  describe "due" do
    let(:manager) { FactoryGirl.create(:user) }
    let(:mail) { DueDateMailer.due(FactoryGirl.create(:due_date, manager: manager)) }

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('due_date_mailer.due.subject'))
      expect(mail.to).to eq([manager.email])
      expect(mail.from).to eq(["donotreply@undp-sadata-staging.herokuapp.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "overdue" do
    let(:manager) { FactoryGirl.create(:user) }
    let(:mail) { DueDateMailer.overdue(FactoryGirl.create(:due_date, manager: manager)) }

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('due_date_mailer.overdue.subject'))
      expect(mail.to).to eq([manager.email])
      expect(mail.from).to eq(["donotreply@undp-sadata-staging.herokuapp.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
