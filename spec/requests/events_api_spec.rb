require 'spec_helper'
require 'fileutils'

describe 'Event API' do
  def app
    Sinatra::Application
  end

  let(:user) { create(:user, email: 'email@gmail.com') }

  context 'GET /v1/events' do
    it 'should get all events' do
      event1 = create(:event, owner_id: user.id)
      event2 = create(:event, owner_id: user.id)

      header 'Authorization', "Bearer #{token(user)}"
      get '/v1/events'

      expect(last_response.status).to eq 200
      expect(last_response.content_type).to include('application/json')

      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body.count).to eq(Event.where(owner_id: user.id).count)
      expect(parsed_body.count).to eq(Event.count)

      expect(parsed_body[0]['name']).to eq(event1.name)
      expect(parsed_body[0]['owner']['name']).to eq(user.name)
      expect(parsed_body[0]['local']).to eq(event1.local)
      expect(parsed_body[0]['description']).to eq(event1.description)

      expect(parsed_body[1]['name']).to eq(event2.name)
      expect(parsed_body[1]['owner']['name']).to eq(user.name)
      expect(parsed_body[1]['local']).to eq(event2.local)
      expect(parsed_body[1]['description']).to eq(event2.description)
    end

    it 'does not have any events' do
      header 'Authorization', "Bearer #{token(user)}"
      get '/v1/events'

      expect(last_response.status).to eq 200
      parsed_body = JSON.parse(last_response.body)
      expect(parsed_body).to eq([])
    end
  end

  context 'GET /v1/events/:id' do
    it 'get specific event' do
      event = create(:event, owner_id: user.id)
      header 'Authorization', "Bearer #{token(user)}"
      get "/v1/events/#{event.id}"

      expect(last_response.status).to eq 200
      expect(last_response.content_type).to include('application/json')

      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body['name']).to eq(event.name)
      expect(parsed_body['owner']['name']).to eq(user.name)
      expect(parsed_body['local']).to eq(event.local)
      expect(parsed_body['description']).to eq(event.description)
    end

    it 'non existent event' do
      header 'Authorization', "Bearer #{token(user)}"
      get "/v1/events/#{rand(1...1000)}"
      expect(last_response.status).to eq 404
    end
  end

  context 'POST /v1/events' do
    it 'create an event' do
      new_event = {
        'name': 'CCXP',
        'local': 'São Paulo',
        'description': 'A melhor descrição que existe',
        'start_date': 15.days.from_now,
        'end_date': 20.days.from_now
      }

      header 'Authorization', "Bearer #{token(user)}"
      post '/v1/events', new_event.to_json, 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq 201
      expect(last_response.content_type).to include('application/json')

      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body['name']).to eq('CCXP')
      expect(parsed_body['description']).to eq('A melhor descrição que existe')
      expect(parsed_body['owner']['name']).to eq(user.name)
    end
    it 'create with CSV File' do
      3.times { create(:user) }
      header 'Authorization', "Bearer #{token(user)}"
      post '/v1/events',
           :file => Rack::Test::UploadedFile.new(
             "#{Dir.pwd}/spec/fixtures/eventss.csv",
             'text/csv'
           ), 'CONTENT_TYPE' => 'text/csv'
      expect(last_response.status).to eq 201
      expect(Event.all.count).to eq(2)
    end

    it 'error on creating with CSV on event fields' do
      3.times { create(:user) }
      header 'Authorization', "Bearer #{token(user)}"
      post '/v1/events',
           :file => Rack::Test::UploadedFile.new(
             "#{Dir.pwd}/spec/fixtures/events_with_field_error.csv",
             'text/csv'
           ), 'CONTENT_TYPE' => 'text/csv'

      expect(last_response.status).to eq 400
      expect(Event.all.count).to eq(0)
      expect(Invite.all.count).to eq(0)

      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body['error']).to eq("Validation failed: Description can't be blank")
    end

    it 'create with CSV File error beause non existent user' do
      2.times { create(:user) }
      header 'Authorization', "Bearer #{token(user)}"
      post '/v1/events',
           :file => Rack::Test::UploadedFile.new(
             "#{Dir.pwd}/spec/fixtures/eventss.csv",
             'text/csv'
           ), 'CONTENT_TYPE' => 'text/csv'

      expect(last_response.status).to eq 400

      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body['error']).to eq('Error on users invitation, please try again')
    end
    it 'error on event fields' do
      new_event = {
        'name': 'CCXP'
      }

      header 'Authorization', "Bearer #{token(user)}"
      post '/v1/events', new_event.to_json, 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq 400
      expect(last_response.content_type).to include('application/json')
    end

    it 'body is not an json' do
      wrong_event_type = '<h2> Evento </h2>'

      header 'Authorization', "Bearer #{token(user)}"
      post '/v1/events', wrong_event_type, 'CONTENT_TYPE' => 'html/text'
      expect(last_response.status).not_to eq 500
    end
  end
end
