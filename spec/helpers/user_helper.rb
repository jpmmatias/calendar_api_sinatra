module UserHelpers
  def token(user)
    JWT.encode payload(user), ENV['JWT_SECRET'], 'HS256'
  end

  def payload(user)
    {
      exp: Time.now.to_i + 60 * 60,
      iat: Time.now.to_i,
      iss: ENV['JWT_ISSUER'],
      scopes: %w[events documents],
      user: { id: user.id, name: user.name, email: user.email }
    }
  end
end
