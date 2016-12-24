module FeatureSpecHelpers
  def flash?(content)
    page.has_css?('.callout', text: content)
  end

  def admin_user
    FactoryGirl.create(:user, :admin)
  end

  def manager_user
    FactoryGirl.create(:user, :manager)
  end

  def reporter_user
    FactoryGirl.create(:user, :reporter)
  end

  def user
    FactoryGirl.create(:user)
  end
end
