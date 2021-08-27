require 'faker'

5.times do
  event = Event.create!(
    name: Faker::Hipster.sentence(word_count: 2),
    local: Faker::University.name,
    owner: Faker::Name.unique.name,
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
end
