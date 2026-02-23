require "rails_helper"
require "json"

if Features.enabled?(:progress_reports)
  RSpec.describe DueDatesController, type: :controller do
    describe "Get index" do
      subject { get :index, format: :json }
      let!(:due_date) { FactoryBot.create(:due_date) }
      let!(:draft_due_date) { FactoryBot.create(:due_date, draft: true) }

      # Define roles at class level
      def self.allowed_view_all_roles
        @allowed_view_all_roles ||= Permissions.roles_with_permission("due_date", "view_all")
      end

      def self.all_roles
        @all_roles ||= Permissions::ROLE_HIERARCHY.keys
      end

      context "when not signed in" do
        it "no due_dates are shown" do
          json = JSON.parse(subject.body)
          expect(json["data"].length).to eq(0)
        end
      end

      context "when signed in" do
        let(:guest) { FactoryBot.create(:user) }

        it "guest (no roles) will not see any due_dates" do
          sign_in guest
          json = JSON.parse(subject.body)
          expect(json["data"].length).to eq(0)
        end

        # Test each role's visibility based on view_all permission
        all_roles.each do |role|
          context role.to_s do
            let(:user) { FactoryBot.create(:user, role.to_sym) }

            it "sees appropriate due_dates based on permissions" do
              sign_in user
              json = JSON.parse(subject.body)

              if self.class.allowed_view_all_roles.include?(role)
                # Can see all due dates
                expect(json["data"].length).to eq(2)
              else
                # Cannot see any due dates
                expect(json["data"].length).to eq(0)
              end
            end
          end
        end
      end
    end

    describe "Scope permission system tests" do
      include_examples "all or nothing scope permission system",
        "due_date", "view_all"
    end
  end
end
