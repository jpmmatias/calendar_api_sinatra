require 'spec_helper'

describe 'User API' do
  def app
    Sinatra::Application
  end

  context 'POST /v1/users/new_account' do
    it 'successfully' do
      new_user = {
        'name': 'Usuário',
        'email': 'user@gmail.com',
        'password': 'senha1234'
      }

      post '/v1/users/new_account', new_user.to_json, 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq 201
      expect(last_response.content_type).to include('application/json')

      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body['success']).to eq(true)
      expect(parsed_body['message']).to eq('User created successfully')
    end
  end

  context 'POST /v1/users/login' do
    it 'successfully' do
      user = create(:user)

      body_user = {
        email: user.email,
        password: user.password
      }

      post '/v1/users/login', body_user.to_json, 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq 200
      expect(last_response.content_type).to include('application/json')

      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body).to include('token')
    end

    it 'responds with a valid JWT' do
      user = create(:user)

      body_user = {
        email: user.email,
        password: user.password
      }

      post '/v1/users/login', body_user.to_json, 'CONTENT_TYPE' => 'application/json'

      token = JSON.parse(last_response.body)['token']

      expect { JWT.decode(token, ENV['JWT_SECRET']) }.to_not raise_error
    end

    it 'returns error when user does not exist' do
      post '/v1/users/login', { email: 'ac@email.com', password: 'password' }.to_json
      expect(last_response.status).to eq(400)
    end

    it 'returns error when user password is wrong' do
      user = create(:user)
      post '/v1/users/login', { email: user.email, password: 'pass' }.to_json
      expect(last_response.status).to eq(400)
    end
  end
end
