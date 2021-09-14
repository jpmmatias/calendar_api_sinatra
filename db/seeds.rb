require 'faker'

# User.create!(
#  name: Faker::Name.unique.name,
#  email: 'email@gmail.com',
#  password: 'senha1234'
# )

# User.create!(
# name: Faker::Name.unique.name,
#  email: 'email2@gmail.com',
#  password: 'senha1234'
# )

# User.create!(
# name: Faker::Name.unique.name,
#  email: 'email3@gmail.com',
# password: 'senha1234'
# )

5.times do
  event = Event.create!(
    name: Faker::Hipster.sentence(word_count: 2),
    local: Faker::University.name,
    owner_id: 1,
    description: Faker::Lorem.paragraph,
    start_date: Faker::Time.forward(days: 5, period: :morning),
    end_date: Faker::Time.forward(days: 23, period: :morning)
  )

  Document.create!(
    file_path: 'spec/fixtures/teste.xlsx',
    file_type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    file_name: 'teste',
    event: event
  )

  Document.create!(
    file_path: 'spec/fixtures/test_image.jpeg',
    file_type: 'imagem/jpeg',
    file_name: 'teste_imagem',
    event: event
  )

  Document.create!(
    file_path: 'spec/fixtures/teste.pptx',
    file_type: 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    file_name: 'teste_apresentacao',
    event: event
  )

  Invite.create!(event_id: event.id, sender_id: 1, receiver_id: 2, status: 1)

  Invite.create!(event_id: event.id, sender_id: 1, receiver_id: 3, status: 1)
end
