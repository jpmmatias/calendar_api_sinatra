FactoryBot.define do
    factory :document do
      event 
      file_path { ['spec/fixtures/test_image.jpeg', 'spec/fixtures/teste_doc.docx', 'spec/fixtures/teste_pdf.pdf'].sample }
    end
  end
  