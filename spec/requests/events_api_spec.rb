require 'spec_helper'

describe 'Events API' do
  context 'GET /v1/events' do
    it 'should get enrollments courses' do
      event1 = Event.create!(
        name: 'Ruby Conf',
        local: 'Online',
        description: 'A maior descrição que existe',
        owner: 'Henrique Morato',
        start_date: 10.days.from_now,
        final_date: 15.days.from_now
      )

      event2 = Event.create!(
        name: 'CCXP',
        local: 'Online',
        description: 'A maior descrição que existe',
        owner: 'John Cena',
        start_date: 15.days.from_now,
        final_date: 20.days.from_now
      )

      get '/v1/events'

      expect(response).to have_http_status(200)
      expect(response.content_type).to include('application/json')
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.count).to eq(Event.count)
      expect(parsed_body[0]['name']).to eq(event1.name)
      expect(parsed_body[1]['name']).to eq(event2.name)
    end
  end
end
