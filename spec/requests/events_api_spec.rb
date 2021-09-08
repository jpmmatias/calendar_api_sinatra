require 'spec_helper'

describe 'Event API' do
  def app
    Sinatra::Application
  end

  context 'GET /v1/events' do
    it 'should get all events' do
      event1 = create(:event)
      event2 = create(:event)

      get '/v1/events'

      expect(last_response.status).to eq 200
      expect(last_response.content_type).to include('application/json')

      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body.count).to eq(Event.count)

      expect(parsed_body[0]['name']).to eq(event1.name)
      expect(parsed_body[0]['local']).to eq(event1.local)
      expect(parsed_body[0]['description']).to eq(event1.description)

      expect(parsed_body[1]['name']).to eq(event2.name)
      expect(parsed_body[1]['local']).to eq(event2.local)
      expect(parsed_body[1]['description']).to eq(event2.description)
    end

    it 'does not have any events' do
      get '/v1/events'

      expect(last_response.status).to eq 200
      parsed_body = JSON.parse(last_response.body)
      expect(parsed_body).to eq([])
    end
  end

  context 'GET /v1/events/:id' do
    it 'get specific event' do
      event = create(:event)

      get "/v1/events/#{event.id}"

      expect(last_response.status).to eq 200
      expect(last_response.content_type).to include('application/json')

      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body['name']).to eq(event.name)
      expect(parsed_body['local']).to eq(event.local)
      expect(parsed_body['description']).to eq(event.description)
    end

    it 'non existent event' do
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
        'owner': 'John Cena',
        'start_date': 15.days.from_now,
        'end_date': 20.days.from_now
      }

      post '/v1/events', new_event.to_json, 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq 201
      expect(last_response.content_type).to include('application/json')

      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body['name']).to eq('CCXP')
      expect(parsed_body['description']).to eq('A melhor descrição que existe')
      expect(parsed_body['owner']).to eq('John Cena')
    end

    it 'error on event fields' do
      new_event = {
        'name': 'CCXP'
      }

      post '/v1/events', new_event.to_json, 'CONTENT_TYPE' => 'application/json'
      expect(last_response.status).to eq 400
      expect(last_response.content_type).to include('application/json')
    end

    it 'body is not an json' do
      wrong_event_type = '<h2> Evento </h2>'
      post '/v1/events', wrong_event_type, 'CONTENT_TYPE' => 'html/text'
      expect(last_response.status).not_to eq 500
    end
  end
end
