require 'faker'

5.times do
   event = Event.create!(
      name:  Faker::Hipster.sentence(word_count: 2), 
      local: Faker::University.name ,
      owner: Faker::Name.unique.name ,
      description: Faker::Lorem.paragraph ,
      start_date: Faker::Time.forward(days: 5, period: :morning) ,
      end_date: Faker::Time.forward(days: 23, period: :morning) ,
    ) 

    Document.create!(
        file_path: ['spec/fixtures/teste.xlsx', 'spec/fixtures/teste.pptx', 'spec/fixtures/test_image.jpeg'].sample,
        event: event
    )

    Document.create!(
        file_path: ['spec/fixtures/teste.xlsx', 'spec/fixtures/teste.pptx', 'spec/fixtures/test_image.jpeg'].sample,
        event: event
    )
end