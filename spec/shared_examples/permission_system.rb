# spec/support/shared_examples/permission_system.rb

RSpec.shared_examples "permission system" do |model_name, action, http_method, params_proc|
  describe "#{model_name} #{action} permission system" do
    let(:guest) { FactoryBot.create(:user) }

    [
      {config: ["admin"], description: "admin-only"},
      {config: ["manager"], description: "manager+ (via hierarchy)"},
      {config: ["contributor"], description: "all roles (via hierarchy)"},
      {config: [], description: "disabled for all roles"}
    ].each do |test_case|
      context "when configured as #{test_case[:description]}" do
        before do
          allow(Permissions).to receive(:allowed_for).and_call_original

          # Stub for both string and symbol versions
          allow(Permissions).to receive(:allowed_for)
            .with(model_name, action)
            .and_return(test_case[:config])
          allow(Permissions).to receive(:allowed_for)
            .with(model_name, action.to_s)
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
            guest = FactoryBot.create(:user)
            sign_in guest

            response = send(http_method, action, format: :json, params: params_proc.call)

            expect(response).to be_forbidden, "guest should always be forbidden"
          end
        end
      end
    end
  end
end

# Scope permission tests - Index with filtering
RSpec.shared_examples "filtered scope permission system" do |model_name, field_name, permission_name, field_value|
  describe "#{model_name} #{permission_name} scope permission system" do
    let!(:normal_record) {
      # Normal record = published (not draft, not archived)
      attrs = {}
      attrs[:draft] = false
      attrs[:is_archive] = false if field_name != :is_archive
      FactoryBot.create(model_name.to_sym, **attrs)
    }
    let!(:filtered_record) {
      # Filtered record should ONLY have the field we're testing set to true
      # All other visibility fields should be false (maximally visible except for the one we're testing)
      attrs = {field_name => field_value}

      # Set other visibility fields to false
      if field_name == :draft
        attrs[:is_archive] = false
      elsif field_name == :is_archive
        attrs[:draft] = false
      end

      FactoryBot.create(model_name.to_sym, **attrs)
    }
    [
      {config: ["admin"], description: "admin-only"},
      {config: ["contributor"], description: "all roles"},
      {config: [], description: "no roles"}
    ].each do |test_case|
      context "when #{permission_name} configured as #{test_case[:description]}" do
        before do
          allow(Permissions).to receive(:allowed_for).and_call_original

          # Stub for both string and symbol versions
          allow(Permissions).to receive(:allowed_for)
            .with(model_name, permission_name)
            .and_return(test_case[:config])
          allow(Permissions).to receive(:allowed_for)
            .with(model_name, permission_name.to_sym)
            .and_return(test_case[:config])

          # Also stub other scope permissions
          scope_permissions = ["view_draft", "view_archived"].reject { |p| p == permission_name.to_s }
          scope_permissions.each do |perm|
            allow(Permissions).to receive(:allowed_for)
              .with(model_name, perm)
              .and_return([])
            allow(Permissions).to receive(:allowed_for)
              .with(model_name, perm.to_sym)
              .and_return([])
          end
        end

        it "filters records correctly based on permission" do
          min_level = test_case[:config].map { |r| Permissions::ROLE_HIERARCHY[r] }.compact.min
          Permissions::ROLE_HIERARCHY.each do |role, level|
            user = FactoryBot.create(:user, role.to_sym)
            sign_in user

            get :index, format: :json
            json = JSON.parse(response.body)
            ids = json["data"].map { |d| d["id"].to_i }

            expect(ids).to include(normal_record.id),
              "#{role} should see normal records"

            if min_level && level >= min_level
              expect(ids).to include(filtered_record.id),
                "#{role} (level #{level}) should see #{field_name}=#{field_value} records"
            else
              expect(ids).not_to include(filtered_record.id),
                "#{role} (level #{level}) should NOT see #{field_name}=#{field_value} records"
            end
          end
        end

        it "public users never see filtered records" do
          get :index, format: :json
          json = JSON.parse(response.body)
          ids = json["data"].map { |d| d["id"].to_i }

          expect(ids).to include(normal_record.id)
          expect(ids).not_to include(filtered_record.id)
        end
      end
    end
  end
end

# Scope permission tests - Index with all-or-nothing
RSpec.shared_examples "all or nothing scope permission system" do |model_name, permission_name|
  describe "#{model_name} #{permission_name} scope permission system" do
    let!(:record) { FactoryBot.create(model_name.to_sym) }

    [
      {config: ["admin"], description: "admin-only"},
      {config: ["contributor"], description: "all roles"},
      {config: [], description: "no roles"}
    ].each do |test_case|
      context "when #{permission_name} configured as #{test_case[:description]}" do
        before do
          allow(Permissions).to receive(:allowed_for).and_call_original

          # Stub for both string and symbol versions
          allow(Permissions).to receive(:allowed_for)
            .with(model_name, permission_name)
            .and_return(test_case[:config])
          allow(Permissions).to receive(:allowed_for)
            .with(model_name, permission_name.to_sym)
            .and_return(test_case[:config])
        end

        it "enforces all-or-nothing visibility based on permission" do
          min_level = test_case[:config].map { |r| Permissions::ROLE_HIERARCHY[r] }.compact.min

          Permissions::ROLE_HIERARCHY.each do |role, level|
            user = FactoryBot.create(:user, role.to_sym)
            sign_in user

            get :index, format: :json
            json = JSON.parse(response.body)

            if min_level && level >= min_level
              expect(json["data"]).not_to be_empty,
                "#{role} (level #{level}) should see all #{model_name} records"
              expect(json["data"].map { |d| d["id"].to_i }).to include(record.id)
            else
              expect(json["data"]).to be_empty,
                "#{role} (level #{level}) should see no #{model_name} records"
            end
          end
        end

        it "public users see nothing" do
          get :index, format: :json
          json = JSON.parse(response.body)
          expect(json["data"]).to be_empty,
            "public should see no #{model_name} records"
        end
      end
    end
  end
end
