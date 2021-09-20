class UserSerializer
  def initialize(user)
    @user = user
  end

  def response
    { id: @user.id,
      name: @user.name,
      email: @user.email }
  end

end
