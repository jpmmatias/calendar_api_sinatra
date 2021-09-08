FactoryBot.define do
  factory :document do
    event
    file_path { ['spec/fixtures/teste.xlsx', 'spec/fixtures/teste.pptx', 'spec/fixtures/test_image.jpeg'].sample }
    file_type do
      ['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'image/jpeg',
       'application/vnd.openxmlformats-officedocument.presentationml.presentation'].sample
    end
    file_name { %w[documento_1 documento_2 documento_3].sample }

    trait :image do
      file_path { 'spec/fixtures/test_image.jpeg' }
      file_type { 'image/jpeg' }
      file_name { 'imagem' }
    end

    trait :pptx do
      file_path { 'spec/fixtures/teste.pptx' }
      file_type { 'application/vnd.openxmlformats-officedocument.presentationml.presentation' }
      file_name { 'powerpoint' }
    end

    trait :planilha do
      file_path { 'spec/fixtures/teste.xlsx' }
      file_type { 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' }
      file_name { 'planilha' }
    end
  end
end

def event_with_documents(documents_count: 3)
  FactoryBot.create(:event) do |event|
    FactoryBot.create_list(:document, documents_count, event: event)
  end
end
