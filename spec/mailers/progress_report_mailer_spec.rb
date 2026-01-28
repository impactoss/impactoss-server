require "cgi"
require "rails_helper"

RSpec.describe ProgressReportMailer, type: :mailer do
  describe "updated" do
    # Use admin for config-independence - they can always be assigned
    let(:admin) { FactoryBot.create(:user, :admin) }
    let(:category) { FactoryBot.create(:category, manager: admin) }
    let(:measure) { FactoryBot.create(:measure) }
    let(:recommendation) { FactoryBot.create(:recommendation) }
    let(:contributor_indicator) { FactoryBot.create(:indicator, manager: admin) }
    let(:progress_report) { FactoryBot.create(:progress_report, indicator: contributor_indicator) }
    let(:mail) { described_class.updated(progress_report, category) }

    before do
      measure.indicators << contributor_indicator
      recommendation.measures << measure
    end

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t("progress_report_mailer.updated.subject"))
      expect(mail.to).to eq([admin.email])
      expect(mail.from).to eq(["no-reply@mail.impactoss.org"])
    end

    it "mentions the manager's name" do
      expect(mail.text_part.body).to match(admin.name)
      expect(mail.html_part.body).to match(CGI.escapeHTML(admin.name))
    end

    it "mentions the indicator title" do
      expect(mail.text_part.body).to match(contributor_indicator.title)
      expect(mail.html_part.body).to match(contributor_indicator.title)
    end

    it "links to the progress report" do
      expect(mail.text_part.body).to match("/reports/#{progress_report.id}")
      expect(mail.html_part.body).to match("/reports/#{progress_report.id}")
    end
  end
end
