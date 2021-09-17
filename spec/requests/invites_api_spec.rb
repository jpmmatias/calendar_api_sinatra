require 'spec_helper'

describe 'Invite API' do
  def app
    Sinatra::Application
  end

  def token(user)
    JWT.encode payload(user), ENV['JWT_SECRET'], 'HS256'
  end

  def payload(user)
    {
      exp: Time.now.to_i + 60 * 60,
      iat: Time.now.to_i,
      iss: ENV['JWT_ISSUER'],
      scopes: %w[events documents],
      user: { email: user.email, name: user.name, id: user.id }
    }
  end

  let(:user) { create(:user) }

  context 'GET /v1/invites' do
    it 'User see all your invites' do
      sender = create(:user)
      event1 = create(:event, owner_id: sender.id)
      event2 = create(:event, owner_id: sender.id)
      event3 = create(:event, owner_id: sender.id)
      create(:invite, sender_id: sender.id, receiver_id: user.id, event_id: event1.id)
      create(:invite, sender_id: sender.id, receiver_id: user.id, event_id: event2.id)
      create(:invite, sender_id: sender.id, receiver_id: user.id, event_id: event3.id)

      header 'Authorization', "Bearer #{token(user)}"
      get 'v1/invites'

      expect(last_response.status).to eq 200
      expect(last_response.content_type).to include('application/json')

      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body[0]['event_name']).to eq(event1.name)
      expect(parsed_body[0]['event_start_date']).to eq(event1.start_date.to_s)
      expect(parsed_body[0]['event_end_date']).to eq(event1.end_date.to_s)
      expect(parsed_body[0]['sender_name']).to eq(sender.name)

      expect(parsed_body[1]['event_name']).to eq(event2.name)
      expect(parsed_body[1]['event_start_date']).to eq(event2.start_date.to_s)
      expect(parsed_body[1]['event_end_date']).to eq(event2.end_date.to_s)
      expect(parsed_body[1]['sender_name']).to eq(sender.name)

      expect(parsed_body[2]['event_name']).to eq(event3.name)
      expect(parsed_body[2]['event_start_date']).to eq(event3.start_date.to_s)
      expect(parsed_body[2]['event_end_date']).to eq(event3.end_date.to_s)
      expect(parsed_body[2]['sender_name']).to eq(sender.name)
    end

    it "Get empty array if don't have any invite" do
      header 'Authorization', "Bearer #{token(user)}"
      get 'v1/invites'

      expect(last_response.status).to eq 200
      expect(last_response.content_type).to include('application/json')

      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body).to eq([])
    end
  end

  context 'POST /v1/events/:event_id/invite' do
    it 'create an invite with email' do
      reciver = create(:user)
      event = create(:event, owner_id: user.id)

      header 'Authorization', "Bearer #{token(user)}"
      post "/v1/events/#{event.id}/invite", { users_emails: [reciver.email] }.to_json,
           'CONTENT_TYPE' => 'application/json'
      expect(last_response.status).to eq 201
      expect(last_response.content_type).to include('application/json')

      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body[0]['event_name']).to eq(event.name)
      expect(parsed_body[0]['sender_name']).to eq(user.name)
      expect(Invite.last.receiver_id).to eq(reciver.id)
      expect(Invite.last.sender_id).to eq(user.id)
      expect(Invite.last.event_id).to eq(event.id)
    end

    it 'create an invite with user id' do
      reciver = create(:user)
      event = create(:event, owner_id: user.id)

      header 'Authorization', "Bearer #{token(user)}"
      post "/v1/events/#{event.id}/invite", { user_id: reciver.id }.to_json,
           'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq 201
      expect(last_response.content_type).to include('application/json')

      parsed_body = JSON.parse(last_response.body)
      expect(parsed_body[0]['event_name']).to eq(event.name)
      expect(parsed_body[0]['sender_name']).to eq(user.name)
      expect(Invite.last.receiver_id).to eq(reciver.id)
      expect(Invite.last.sender_id).to eq(user.id)
      expect(Invite.last.event_id).to eq(event.id)
    end

    it 'create multiples invites with an array of emails' do
      reciver = create(:user)
      reciver2 = create(:user)
      reciver3 = create(:user)
      event = create(:event, owner_id: user.id)

      header 'Authorization', "Bearer #{token(user)}"
      post "/v1/events/#{event.id}/invite", { users_emails: [reciver.email, reciver2.email, reciver3.email] }.to_json,
           'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq 201
      expect(last_response.content_type).to include('application/json')
      expect(Invite.find_by(receiver_id: reciver2.id).event).to eq(event)
      expect(Invite.find_by(receiver_id: reciver3.id).event).to eq(event)
    end

    it 'not json body' do
      event = create(:event, owner_id: user.id)
      header 'Authorization', "Bearer #{token(user)}"
      post "/v1/events/#{event.id}/invite", {},
           'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq 400
      expect(last_response.content_type).to include('application/json')

      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body['error']).to eq('Please send JSON for the API')
    end

    it "can't create invite if event day already passed" do
      reciver = create(:user)
      event = create(:event, owner_id: user.id, start_date: 2.days.ago, end_date: 1.day.ago)

      header 'Authorization', "Bearer #{token(user)}"
      post "/v1/events/#{event.id}/invite", { users_emails: [reciver.email] }.to_json,
           'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq 400
      expect(last_response.content_type).to include('application/json')

      expect(Invite.all).to eq([])
    end

    it "can't create multiple invites if event already passed" do
      reciver = create(:user)
      reciver2 = create(:user)
      reciver3 = create(:user)
      event = create(:event, owner_id: user.id, start_date: 2.days.ago, end_date: 1.day.ago)

      header 'Authorization', "Bearer #{token(user)}"
      post "/v1/events/#{event.id}/invite", { users_emails: [reciver.email, reciver2.email, reciver3.email] }.to_json,
           'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq 400

      expect(Invite.all).to eq([])
    end

    it "can't invite user if user already invited" do
      reciver = create(:user)
      event = create(:event, owner_id: user.id)
      first_sender = create(:user)

      create(:invite, receiver_id: reciver.id, sender_id: first_sender.id, event_id: event.id)

      header 'Authorization', "Bearer #{token(user)}"
      post "/v1/events/#{event.id}/invite", { users_emails: [reciver.email] }.to_json,
           'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq 400

      parsed_body = JSON.parse(last_response.body)
      expect(parsed_body['error']).to eq('User already invited')
    end

    it 'user not found from email' do
      event = create(:event, owner_id: user.id)

      header 'Authorization', "Bearer #{token(user)}"
      post "/v1/events/#{event.id}/invite", { users_emails: ['email@gmail.com'] }.to_json,
           'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq 400

      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body['error']).to eq("Couldn't find User with 'email'= email@gmail.com")
    end

    it 'user not found from id' do
      event = create(:event, owner_id: user.id)

      header 'Authorization', "Bearer #{token(user)}"
      post "/v1/events/#{event.id}/invite", { user_id: 1234 }.to_json,
           'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq 400

      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body['error']).to eq("Couldn't find User with 'id'=1234")
    end

    it 'non existent event' do
      reciver = create(:user)

      header 'Authorization', "Bearer #{token(user)}"
      post '/v1/events/32145/invite', { user_id: reciver.id }.to_json,
           'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq 400

      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body['error']).to eq('Event not found')
    end

    it 'sending ID and Email' do
      reciver = create(:user)
      event = create(:event, owner_id: user.id)

      header 'Authorization', "Bearer #{token(user)}"
      post "/v1/events/#{event.id}/invite", { users_emails: [reciver.email], user_id: reciver.id }.to_json,
           'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq 400

      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body['error']).to eq('Send email or the ID from the user, but not both')
    end
  end

  context 'PUT /v1/invites/:id/accept' do
    it 'accept invite' do
      sender = create(:user)
      invite = create(:invite, receiver_id: user.id, sender_id: sender.id)

      header 'Authorization', "Bearer #{token(user)}"
      put "/v1/invites/#{invite.id}/accept"

      expect(last_response.status).to eq 200
      expect(last_response.content_type).to include('application/json')

      expect(Invite.find(invite.id).status).to eq('accepted')
    end

    it 'see user on participants event list' do
      reciver = create(:user)
      reciver2 = create(:user)
      reciver3 = create(:user)
      event = create(:event, owner_id: user.id)
      create(:invite, receiver_id: reciver.id, event_id: event.id, sender_id: user.id, status: 1)
      create(:invite, receiver_id: reciver2.id, event_id: event.id, sender_id: user.id, status: 1)
      create(:invite, receiver_id: reciver3.id, event_id: event.id, sender_id: user.id, status: 1)

      header 'Authorization', "Bearer #{token(user)}"
      get "/v1/events/#{event.id}"

      expect(last_response.status).to eq 200
      expect(last_response.content_type).to include('application/json')

      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body['participants'][0]['name']).to eq(user.name)
      expect(parsed_body['participants'][0]['id']).to eq(user.id)
      expect(parsed_body['participants'][0]['email']).to eq(user.email)

      expect(parsed_body['participants'][1]['name']).to eq(reciver.name)
      expect(parsed_body['participants'][1]['id']).to eq(reciver.id)
      expect(parsed_body['participants'][1]['email']).to eq(reciver.email)

      expect(parsed_body['participants'][2]['name']).to eq(reciver2.name)
      expect(parsed_body['participants'][2]['id']).to eq(reciver2.id)
      expect(parsed_body['participants'][2]['email']).to eq(reciver2.email)

      expect(parsed_body['participants'][3]['name']).to eq(reciver3.name)
      expect(parsed_body['participants'][3]['id']).to eq(reciver3.id)
      expect(parsed_body['participants'][3]['email']).to eq(reciver3.email)
    end

    it "can't accept invite if event day already passed" do
      sender = create(:user)
      event = create(:event, owner_id: sender.id, start_date: 2.days.ago, end_date: 1.day.ago)
      invite = create(:invite, event_id: event.id, sender_id: sender.id, receiver_id: user.id)

      header 'Authorization', "Bearer #{token(user)}"
      put "/v1/invites/#{invite.id}/accept"

      expect(last_response.status).to eq 400
      expect(last_response.content_type).to include('application/json')
      expect(Invite.last.status).to eq('unanswered')

      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body['error']).to eq('Event day already passed')
    end

    it 'possible change status after already had one' do
      sender = create(:user)
      invite = create(:invite, receiver_id: user.id, sender_id: sender.id, status: 2)

      expect(invite.status).to eq('refused')

      header 'Authorization', "Bearer #{token(user)}"
      put "/v1/invites/#{invite.id}/accept"

      expect(last_response.status).to eq 200
      expect(last_response.content_type).to include('application/json')

      expect(Invite.find(invite.id).status).to eq('accepted')
      expect(EventSerializer.new(invite.event).response[:participants].count).to eq(2)
    end
  end

  context 'PUT /v1/invites/:id/refuse' do
    it 'refuse invite' do
      sender = create(:user)
      invite = create(:invite, receiver_id: user.id, sender_id: sender.id)

      header 'Authorization', "Bearer #{token(user)}"
      put "/v1/invites/#{invite.id}/refuse"

      expect(last_response.status).to eq 200
      expect(last_response.content_type).to include('application/json')

      expect(Invite.find(invite.id).status).to eq('refused')
    end

    it "can't refuse invite if event day already passed" do
      sender = create(:user)
      event = create(:event, owner_id: sender.id, start_date: 2.days.ago, end_date: 1.day.ago)
      invite = create(:invite, event_id: event.id, sender_id: sender.id, receiver_id: user.id)

      header 'Authorization', "Bearer #{token(user)}"
      put "/v1/invites/#{invite.id}/refuse"

      expect(last_response.status).to eq 400
      expect(last_response.content_type).to include('application/json')
      expect(Invite.last.status).to eq('unanswered')

      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body['error']).to eq('Event day already passed')
    end

    it 'possible change status after already had one' do
      sender = create(:user)
      invite = create(:invite, receiver_id: user.id, sender_id: sender.id, status: 1)

      expect(invite.status).to eq('accepted')

      header 'Authorization', "Bearer #{token(user)}"
      put "/v1/invites/#{invite.id}/refuse"

      expect(last_response.status).to eq 200
      expect(last_response.content_type).to include('application/json')

      expect(Invite.find(invite.id).status).to eq('refused')
      expect(EventSerializer.new(invite.event).response[:participants].count).to eq(1)
    end
  end

  context 'PUT /v1/invites/:id/perhaps' do
    it 'perhaps in the future accept invite (perhaps)' do
      sender = create(:user)
      invite = create(:invite, receiver_id: user.id, sender_id: sender.id)

      header 'Authorization', "Bearer #{token(user)}"
      put "/v1/invites/#{invite.id}/perhaps"

      expect(last_response.status).to eq 200
      expect(last_response.content_type).to include('application/json')

      expect(Invite.find(invite.id).status).to eq('perhaps')
    end

    it "can't put perhaps on invite if event day already passed" do
      sender = create(:user)
      event = create(:event, owner_id: sender.id, start_date: 2.days.ago, end_date: 1.day.ago)
      invite = create(:invite, event_id: event.id, sender_id: sender.id, receiver_id: user.id)

      header 'Authorization', "Bearer #{token(user)}"
      put "/v1/invites/#{invite.id}/perhaps"

      expect(last_response.status).to eq 400
      expect(last_response.content_type).to include('application/json')
      expect(Invite.last.status).to eq('unanswered')

      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body['error']).to eq('Event day already passed')
    end

    it 'possible change status after already had one' do
      sender = create(:user)
      invite = create(:invite, receiver_id: user.id, sender_id: sender.id, status: 1)

      expect(invite.status).to eq('accepted')

      header 'Authorization', "Bearer #{token(user)}"
      put "/v1/invites/#{invite.id}/perhaps"

      expect(last_response.status).to eq 200
      expect(last_response.content_type).to include('application/json')

      expect(Invite.find(invite.id).status).to eq('perhaps')
      expect(EventSerializer.new(invite.event).response[:participants].count).to eq(1)
    end
  end
end
