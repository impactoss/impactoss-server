# frozen_string_literal: true

class ImpactOmniauthCallbacksController < DeviseTokenAuth::OmniauthCallbacksController
  def auth_hash
    @_auth_hash ||= request.env["omniauth.auth"] ||= session.delete("dta.omniauth.auth")
  end

  def get_resource_from_auth_hash
    super

    if @resource
      @resource.name = auth_hash_name
      @resource.roles = Role.where(name: azure_role_names) || []
      @resource.save!
    end

    @resource
  end

  private

  def auth_hash_groups
    auth_hash.dig("extra", "raw_info", "groups") || []
  end

  def auth_hash_name
    [
      auth_hash.dig("info", "first_name"),
      auth_hash.dig("info", "last_name")
    ].reject(&:blank?).join(" ") || auth_hash.dig("info", "name")
  end

  def azure_groups
    {
      admin: ENV["AZURE_GROUP_ADMIN"],
      contributor: ENV["AZURE_GROUP_CONTRIBUTOR"],
      manager: ENV["AZURE_GROUP_MANAGER"]
    }
  end

  def azure_role_names
    azure_groups
      .select { |role, uuid| auth_hash_groups.include?(uuid) }
      .keys
  end
end
