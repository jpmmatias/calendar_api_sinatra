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

    it 'can filter events by start_date and end_date' do
      event1 = create(:event, owner_id: user.id, start_date: '2024-11-01T15:30', end_date: '2025-11-01T15:30')
      event2 = create(:event, owner_id: user.id, start_date: '2024-11-01T15:30', end_date: '2025-11-01T15:30')
      event3 = create(:event, owner_id: user.id, name: 'Filtrado', start_date: '2022-11-01T15:30',
                              end_date: '2023-11-01T15:30')

      header 'Authorization', "Bearer #{token(user)}"
      get '/v1/events?start_date=2024-01-01T15:30&end_date=2026-11-01T15:30'

      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to include('application/json')
      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body.count).to eq(2)
      expect(parsed_body[0]['name']).to eq(event1.name)
      expect(parsed_body[0]['name']).not_to eq(event3.name)
      expect(parsed_body[1]['name']).to eq(event2.name)
      expect(parsed_body[1]['name']).not_to eq(event3.name)
      expect(parsed_body[2]).to eq(nil)
    end

    it 'can filter and return but nothing fits the query' do
      create(:event, owner_id: user.id, start_date: '2021-11-01T15:30', end_date: '2022-11-01T15:30')
      create(:event, owner_id: user.id, start_date: '2021-11-01T15:30', end_date: '2021-11-01T15:30')
      create(:event, owner_id: user.id, start_date: '2022-11-01T15:30',
                     end_date: '2023-11-01T15:30')

      header 'Authorization', "Bearer #{token(user)}"
      get '/v1/events?start_date=2024-01-01T15:30&end_date=2026-11-01T15:30'

      parsed_body = JSON.parse(last_response.body)

      expect(last_response.status).to eq(200)
      expect(parsed_body).to eq([])
    end

    it 'can filter by datetime but there were no events' do
      header 'Authorization', "Bearer #{token(user)}"
      get '/v1/events?start_date=2024-01-01T15:30&end_date=2026-11-01T15:30'

      parsed_body = JSON.parse(last_response.body)

      expect(last_response.status).to eq(200)
      expect(parsed_body).to eq([])
    end

    it 'error param invalid' do
      header 'Authorization', "Bearer #{token(user)}"
      get '/v1/events?start_date=bskladjk&end_date=afjl3i2kjn4fm2'

      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to include('application/json')
      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body['error']).to eq('Par??metros de filtros invalidos, tente novamente')
    end

    it 'just start_date is sended' do
      event1 = create(:event, owner_id: user.id, start_date: '2024-11-01T15:30', end_date: '2025-11-01T15:30')
      event2 = create(:event, owner_id: user.id, start_date: '2024-11-01T15:30', end_date: '2025-11-01T15:30')
      event3 = create(:event, owner_id: user.id, name: 'Filtrado', start_date: '2022-11-01T15:30',
                              end_date: '2023-11-01T15:30')

      header 'Authorization', "Bearer #{token(user)}"
      get '/v1/events?start_date=2024-01-01T15:30'

      parsed_body = JSON.parse(last_response.body)

      expect(last_response.status).to eq(200)
      expect(parsed_body.count).to eq(2)
      expect(parsed_body[0]['name']).to eq(event1.name)
      expect(parsed_body[0]['name']).not_to eq(event3.name)
      expect(parsed_body[1]['name']).to eq(event2.name)
      expect(parsed_body[1]['name']).not_to eq(event3.name)
      expect(parsed_body[2]).to eq(nil)
    end
    it 'just end_date is sended' do
      event1 = create(:event, owner_id: user.id, start_date: '2024-11-01T15:30', end_date: '2025-11-01T15:30')
      event2 = create(:event, owner_id: user.id, start_date: '2024-11-01T15:30', end_date: '2025-11-01T15:30')
      event3 = create(:event, owner_id: user.id, name: 'Filtrado', start_date: '2022-11-01T15:30',
                              end_date: '2023-11-01T15:30')

      header 'Authorization', "Bearer #{token(user)}"
      get '/v1/events?end_date=2026-11-01T15:30'

      parsed_body = JSON.parse(last_response.body)

      expect(last_response.status).to eq(200)
      expect(parsed_body.count).to eq(3)
      expect(parsed_body[0]['name']).to eq(event1.name)
      expect(parsed_body[1]['name']).to eq(event2.name)
      expect(parsed_body[2]['name']).to eq(event3.name)
    end

    it 'Can filter with UTC datetime' do
      event1 = create(:event, owner_id: user.id, start_date: '2024-11-01T15:30', end_date: '2025-11-01T15:30')
      event2 = create(:event, owner_id: user.id, start_date: '2024-11-01T15:30', end_date: '2025-11-01T15:30')
      event3 = create(:event, owner_id: user.id, name: 'Filtrado', start_date: '2022-11-01T15:30',
                              end_date: '2023-11-01T15:30')

      header 'Authorization', "Bearer #{token(user)}"
      get '/v1/events?start_date=2024-10-01+13:26:08&end_date=2026-10-01+13:26:08'

      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to include('application/json')
      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body.count).to eq(2)
      expect(parsed_body[0]['name']).to eq(event1.name)
      expect(parsed_body[0]['name']).not_to eq(event3.name)
      expect(parsed_body[1]['name']).to eq(event2.name)
      expect(parsed_body[1]['name']).not_to eq(event3.name)
      expect(parsed_body[2]).to eq(nil)
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

    it 'only participants can see' do
      event = create(:event)
      another_user = create(:user)

      create(:invite, sender_id: event.owner_id, receiver_id: another_user.id, event_id: event.id, status: 1)

      header 'Authorization', "Bearer #{token(user)}"
      get "/v1/events/#{event.id}"

      expect(last_response.status).to eq 403
      expect(last_response.content_type).to include('application/json')
      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body['error']).to eq('User not allowed')
    end
  end

  context 'POST /v1/events' do
    it 'create an event' do
      new_event = {
        'name': 'CCXP',
        'local': 'S??o Paulo',
        'description': 'A melhor descri????o que existe',
        'start_date': 15.days.from_now,
        'end_date': 20.days.from_now
      }

      header 'Authorization', "Bearer #{token(user)}"
      post '/v1/events', new_event.to_json, 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq 201
      expect(last_response.content_type).to include('application/json')

      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body['name']).to eq('CCXP')
      expect(parsed_body['description']).to eq('A melhor descri????o que existe')
      expect(parsed_body['owner']['name']).to eq(user.name)
      expect(parsed_body['start_date']).to eq(DateTime.parse(new_event[:start_date].to_s).utc.to_s)
      expect(parsed_body['end_date']).to eq(DateTime.parse(new_event[:end_date].to_s).utc.to_s)
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

  context 'POST /v1/events/csv' do
    it 'create with CSV File' do
      3.times { create(:user) }
      header 'Authorization', "Bearer #{token(user)}"
      post '/v1/events/csv',
           :file => Rack::Test::UploadedFile.new(
             "#{Dir.pwd}/spec/fixtures/eventss.csv",
             'text/csv'
           ), 'CONTENT_TYPE' => 'text/csv'
      expect(last_response.status).to eq 200
    end
  end

  context 'PUT /v1/events/:id' do
    it 'Edit event successufuly' do
      event = create(:event, owner_id: user.id)

      event_changes = {
        'name': 'Evento Mudado com Sucesso',
        'local': 'Costa Rica',
        'description': 'Evento Mudado com sucesso',
        'start_date': 88.days.from_now,
        'end_date': 100.days.from_now
      }

      header 'Authorization', "Bearer #{token(user)}"
      put "/v1/events/#{event.id}", event_changes.to_json, 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to eq('application/json')

      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body['name']).not_to eq(event.name)
      expect(parsed_body['description']).not_to eq(event.description)
      expect(parsed_body['name']).to eq(event_changes[:name])
      expect(parsed_body['description']).to eq(event_changes[:description])
      expect(parsed_body['local']).to eq(event_changes[:local])
      expect(parsed_body['owner']['name']).to eq(user.name)
      expect(parsed_body['start_date']).to eq(DateTime.parse(event_changes[:start_date].to_s).utc.to_s)
      expect(parsed_body['end_date']).to eq(DateTime.parse(event_changes[:end_date].to_s).utc.to_s)
    end
    it 'accepts only the field to edit' do
      event = create(:event, owner_id: user.id)
      event_changes = {
        'name': 'Evento Mudado com Sucesso'
      }

      header 'Authorization', "Bearer #{token(user)}"
      put "/v1/events/#{event.id}", event_changes.to_json, 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to eq('application/json')

      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body['name']).not_to eq(event.name)
      expect(parsed_body['description']).to eq(event.description)
      expect(parsed_body['name']).to eq(event_changes[:name])
      expect(parsed_body['local']).to eq(event.local)
      expect(parsed_body['owner']['name']).to eq(user.name)
    end

    it 'but event not found' do
      event_changes = {
        'name': 'Evento Mudado com Sucesso'
      }

      header 'Authorization', "Bearer #{token(user)}"
      put '/v1/events/324234', event_changes.to_json, 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq(404)
      expect(last_response.content_type).to eq('application/json')
    end

    it 'but nil fields' do
      event = create(:event, owner_id: user.id)

      event_changes = {
        'name': nil,
        'local': nil,
        'description': nil,
        'start_date': 88.days.from_now,
        'end_date': 100.days.from_now
      }

      header 'Authorization', "Bearer #{token(user)}"
      put "/v1/events/#{event.id}", event_changes.to_json, 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')

      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body['error']).to eq('Error when update event, please try again')
    end

    it 'only the owner can edit' do
      event = create(:event)

      event_changes = {
        'name': 'Evento Mudado com Sucesso',
        'local': 'Costa Rica',
        'description': 'Evento Mudado com sucesso',
        'start_date': 88.days.from_now,
        'end_date': 100.days.from_now
      }

      header 'Authorization', "Bearer #{token(user)}"
      put "/v1/events/#{event.id}", event_changes.to_json, 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq(403)
    end
  end

  context 'DELETE /v1/events/:id' do
    it 'Successufuly delete event' do
      event = create(:event, owner_id: user.id)

      header 'Authorization', "Bearer #{token(user)}"
      delete "/v1/events/#{event.id}", 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq 204

      expect(Event.all).to eq([])
    end
    it 'only the owner can delete' do
      event = create(:event)

      header 'Authorization', "Bearer #{token(user)}"
      delete "/v1/events/#{event.id}", 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq 403
    end
    it 'the invites and the documents are delete as well' do
      event = event_with_documents(3, user.id)
      create(:invite, event_id: event.id, status: 1, sender_id: user.id, receiver_id: create(:user).id)

      header 'Authorization', "Bearer #{token(user)}"
      delete "/v1/events/#{event.id}", 'CONTENT_TYPE' => 'application/json'

      expect(Event.all.count).to eq(0)
      expect(Document.all.count).to eq(0)
      expect(Invite.all.count).to eq(0)
    end
  end
end
