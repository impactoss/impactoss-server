require "cgi"
require "rails_helper"

RSpec.describe ProgressReportMailer, type: :mailer do
  describe "updated" do
    let(:manager) { FactoryBot.create(:user) }
    let(:indicator) { FactoryBot.create(:indicator, manager:) }
    let(:progress_report) { FactoryBot.create(:progress_report, indicator:) }
    let(:mail) { described_class.updated(progress_report) }

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t("progress_report_mailer.updated.subject"))
      expect(mail.to).to eq([manager.email])
      expect(mail.from).to eq(["no-reply@mail.impactoss.org"])
    end

    it "mentions the manager's name" do
      expect(mail.text_part.body).to match(manager.name)
      expect(mail.html_part.body).to match(CGI.escapeHTML(manager.name))
    end

    it "mentions the indicator title" do
      expect(mail.text_part.body).to match(due_date.indicator.title)
      expect(mail.html_part.body).to match(due_date.indicator.title)
    end
  end
end
