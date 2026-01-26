# spec/support/shared_examples/permission_system.rb

RSpec.shared_examples "permission system" do |model_name, action, http_method, params_proc|
  describe "#{model_name} #{action} permission system" do
    let(:guest) { FactoryBot.create(:user) }

    [
      { config: ['admin'], description: "admin-only" },
      { config: ['manager'], description: "manager+ (via hierarchy)" },
      { config: ['contributor'], description: "all roles (via hierarchy)" },
      { config: [], description: "disabled for all roles" }
    ].each do |test_case|
      context "when configured as #{test_case[:description]}" do
        before do
          # Allow other calls to pass through, only stub the specific action
          allow(Permissions).to receive(:allowed_for).and_call_original
          allow(Permissions).to receive(:allowed_for)
            .with(model_name, action)
            .and_return(test_case[:config])
        end

        if test_case[:config].empty?
          it "denies all roles when disabled" do
            %w[admin manager contributor].each do |role|
              user = FactoryBot.create(:user, role.to_sym)
              sign_in user

              response = send(http_method, action, format: :json, params: params_proc.call)
              expect(response).to be_forbidden, "#{role} should be forbidden when #{action} is disabled"
            end
          end

          it "denies guest users when disabled" do
            sign_in guest
            response = send(http_method, action, format: :json, params: params_proc.call)
            expect(response).to be_forbidden, "guest should be forbidden when #{action} is disabled"
          end
        else
          it "enforces role hierarchy correctly" do
            min_allowed_level = test_case[:config].map { |r| Permissions::ROLE_HIERARCHY[r] }.compact.min

            Permissions::ROLE_HIERARCHY.each do |role, level|
              user = FactoryBot.create(:user, role.to_sym)
              sign_in user

              response = send(http_method, action, format: :json, params: params_proc.call)

              if level >= min_allowed_level
                expect(response).not_to be_forbidden,
                  "#{role} (level #{level}) should be allowed when minimum level is #{min_allowed_level}"
              else
                expect(response).to be_forbidden,
                  "#{role} (level #{level}) should be forbidden when minimum level is #{min_allowed_level}"
              end
            end
          end

          it "denies guest users (no roles)" do
            sign_in guest
            response = send(http_method, action, format: :json, params: params_proc.call)
            expect(response).to be_forbidden, "guest should always be forbidden"
          end
        end
      end
    end
  end
end
