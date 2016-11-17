class Api::V1::SessionsController < Devise::SessionsController
  resource_description do
    api_version '1'
  end

  respond_to :json

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :POST, '/sessions', 'Create a session'
  param :user, Hash do
    param :nickname, :undef
    param :password, :undef
  end
  def create
    user = warden.authenticate!(auth_options)
    sign_in resource_name, user

    render json: {
      id: user.id,
      nickname: user.nickname,
      email: user.email,
      avatar: user.avatar.url(:x32)
    }
  end
end
