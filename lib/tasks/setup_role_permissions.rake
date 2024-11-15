namespace :permissions do
  task setup: :environment do
    RolePermission::Setup.call
  end
end
