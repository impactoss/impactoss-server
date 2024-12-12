require "cgi"
require "rails_helper"

RSpec.describe DueDateMailer, type: :mailer do
  let(:future_date) { Date.new(2035, 12, 25) }
  let(:overdue_date) { Date.new(2019, 12, 25) }

  describe "due" do
    let(:manager) { FactoryBot.create(:user) }
    let(:due_date) { FactoryBot.create(:due_date, due_date: future_date, manager: manager) }
    let(:mail) { DueDateMailer.due(due_date) }

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t("due_date_mailer.due.subject"))
      expect(mail.to).to eq([manager.email])
      expect(mail.from).to eq(["no-reply@mail.impactoss.org"])
    end

    it "mentions the managers name" do
      expect(mail.text_part.body).to match(manager.name)
      expect(mail.html_part.body).to match(CGI.escapeHTML(manager.name))
    end

    it "mentions the indicator title" do
      expect(mail.text_part.body).to match(due_date.indicator.title)
      expect(mail.html_part.body).to match(due_date.indicator.title)
    end

    it "localises the due date" do
      expect(mail.text_part.body).to match("25/12/2035")
      expect(mail.html_part.body).to match("25/12/2035")
    end
  end

  describe "overdue" do
    let(:manager) { FactoryBot.create(:user) }
    let(:due_date) { FactoryBot.create(:due_date, due_date: overdue_date, manager: manager) }
    let(:mail) { DueDateMailer.overdue(due_date) }

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t("due_date_mailer.overdue.subject"))
      expect(mail.to).to eq([manager.email])
      expect(mail.from).to eq(["no-reply@mail.impactoss.org"])
    end

    it "mentions the managers name" do
      expect(mail.text_part.body).to match(manager.name)
      expect(mail.html_part.body).to match(CGI.escapeHTML(manager.name))
    end

    it "mentions the indicator title" do
      expect(mail.text_part.body).to match(due_date.indicator.title)
      expect(mail.html_part.body).to match(due_date.indicator.title)
    end

    it "localises the due date" do
      expect(mail.text_part.body).to match("25/12/2019")
      expect(mail.html_part.body).to match("25/12/2019")
    end
  end

  describe "category due" do
    let(:manager) { FactoryBot.create(:user, :manager) }
    let(:due_date) { FactoryBot.create(:due_date, due_date: future_date) }
    let(:category) { FactoryBot.create(:category, manager: manager) }
    let(:mail) { DueDateMailer.category_due(due_date, category) }

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t("due_date_mailer.category_due.subject"))
      expect(mail.to).to eq([manager.email])
      expect(mail.from).to eq(["no-reply@mail.impactoss.org"])
    end

    it "mentions the managers name" do
      expect(mail.text_part.body).to match(manager.name)
      expect(mail.html_part.body).to match(CGI.escapeHTML(manager.name))
    end

    it "mentions the indicator title" do
      expect(mail.text_part.body).to match(due_date.indicator.title)
      expect(mail.html_part.body).to match(due_date.indicator.title)
    end

    it "localises the due date" do
      expect(mail.text_part.body).to match("25/12/2035")
      expect(mail.html_part.body).to match("25/12/2035")
    end
  end

  describe "category over due" do
    let(:manager) { FactoryBot.create(:user, :manager) }
    let(:due_date) { FactoryBot.create(:due_date, due_date: overdue_date) }
    let(:category) { FactoryBot.create(:category, manager: manager) }
    let(:mail) { DueDateMailer.category_overdue(due_date, category) }

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t("due_date_mailer.category_overdue.subject"))
      expect(mail.to).to eq([manager.email])
      expect(mail.from).to eq(["no-reply@mail.impactoss.org"])
    end

    it "mentions the managers name" do
      expect(mail.text_part.body).to match(manager.name)
      expect(mail.html_part.body).to match(CGI.escapeHTML(manager.name))
    end

    it "mentions the indicator title" do
      expect(mail.text_part.body).to match(due_date.indicator.title)
      expect(mail.html_part.body).to match(due_date.indicator.title)
    end

    it "localises the due date" do
      expect(mail.text_part.body).to match("25/12/2019")
      expect(mail.html_part.body).to match("25/12/2019")
    end
  end
end
