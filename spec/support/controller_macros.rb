# frozen_string_literal: true
module ControllerMacros
  # rubocop:disable Metrics/AbcSize
  def sign_in(user = double('user'))
    if user.nil?
      allow(request.env['warden']).to receive(:authenticate!).and_throw(:warden, scope: :user)
      allow(controller).to receive(:current_user).and_return(nil)
    else
      allow(request.env['warden']).to receive(:authenticate!).and_return(user)
      allow(controller).to receive(:current_user).and_return(user)
    end
    user
  end

  def sign_in_admin
    user = sign_in
    allow(user).to receive(:role?).with('admin').and_return(true)
  end
end
