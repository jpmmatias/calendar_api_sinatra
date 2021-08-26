FactoryBot.define do
    factory :document do
      event 
      file_path { ['spec/fixtures/teste.xlsx', 'spec/fixtures/teste.pptx', 'spec/fixtures/test_image.jpeg'].sample }
    end
  end
  