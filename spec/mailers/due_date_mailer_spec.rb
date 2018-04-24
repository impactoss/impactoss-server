require "rails_helper"

RSpec.describe DueDateMailer, type: :mailer do
  describe "due" do
    let(:manager) { FactoryGirl.create(:user) }
    let(:due_date) { FactoryGirl.create(:due_date, manager: manager) }
    let(:mail) { DueDateMailer.due(due_date) }

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('due_date_mailer.due.subject'))
      expect(mail.to).to eq([manager.email])
      expect(mail.from).to eq(["no-reply@mail.impactoss.org"])
    end

    it "mentions the managers name" do
      expect(mail.body.encoded).to match(manager.name)
    end

    it "mentions the indicator title" do
      expect(mail.body.encoded).to match(due_date.indicator.title)
    end
  end

  describe "overdue" do
    let(:manager) { FactoryGirl.create(:user) }
    let(:due_date) { FactoryGirl.create(:due_date, manager: manager) }
    let(:mail) { DueDateMailer.overdue(due_date) }

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('due_date_mailer.overdue.subject'))
      expect(mail.to).to eq([manager.email])
      expect(mail.from).to eq(["no-reply@mail.impactoss.org"])
    end

    it "mentions the managers name" do
      expect(mail.body.encoded).to match(manager.name)
    end

    it "mentions the indicator title" do
      expect(mail.body.encoded).to match(due_date.indicator.title)
    end
  end

  describe "category due" do
    let(:manager) { FactoryGirl.create(:user) }
    let(:due_date) { FactoryGirl.create(:due_date) }
    let(:category) { FactoryGirl.create(:category, manager: manager) }
    let(:mail) { DueDateMailer.category_due(due_date, category) }

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('due_date_mailer.category_due.subject'))
      expect(mail.to).to eq([manager.email])
      expect(mail.from).to eq(["no-reply@mail.impactoss.org"])
    end

    it "mentions the managers name" do
      expect(mail.body.encoded).to match(manager.name)
    end

    it "mentions the indicator title" do
      expect(mail.body.encoded).to match(due_date.indicator.title)
    end
  end

  describe "category over due" do
    let(:manager) { FactoryGirl.create(:user) }
    let(:due_date) { FactoryGirl.create(:due_date) }
    let(:category) { FactoryGirl.create(:category, manager: manager) }
    let(:mail) { DueDateMailer.category_overdue(due_date, category) }

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('due_date_mailer.category_overdue.subject'))
      expect(mail.to).to eq([manager.email])
      expect(mail.from).to eq(["no-reply@mail.impactoss.org"])
    end

    it "mentions the managers name" do
      expect(mail.body.encoded).to match(manager.name)
    end

    it "mentions the indicator title" do
      expect(mail.body.encoded).to match(due_date.indicator.title)
    end
  end
end
