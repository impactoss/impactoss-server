require "cgi"
require "rails_helper"

RSpec.describe ProgressReportMailer, type: :mailer do
  describe "updated" do
    let(:category) { FactoryBot.create(:category, manager:) }
    let(:measure) { FactoryBot.create(:measure) }
    let(:recommendation) { FactoryBot.create(:recommendation) }
    let(:guest) { FactoryBot.create(:user) }
    let(:manager) { FactoryBot.create(:user, :manager) }
    let(:contributor) { FactoryBot.create(:user, :contributor) }
    let(:contributor_indicator) { FactoryBot.create(:indicator, manager: contributor) }
    let(:progress_report_with_contributor) { FactoryBot.create(:progress_report, indicator: contributor_indicator) }
    let(:mail) { described_class.updated(progress_report_with_contributor, category) }

    before do
      measure.indicators << contributor_indicator
      recommendation.measures << measure
    end

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
      expect(mail.text_part.body).to match(contributor_indicator.title)
      expect(mail.html_part.body).to match(contributor_indicator.title)
    end

    it "links to the progress report" do
      expect(mail.text_part.body).to match("/reports/#{progress_report_with_contributor.id}")
      expect(mail.html_part.body).to match("/reports/#{progress_report_with_contributor.id}")
    end
  end
end
