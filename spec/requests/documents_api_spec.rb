require 'spec_helper'
require 'fileutils'

describe 'Document API' do
  def app
    Sinatra::Application
  end

  let(:user) { create(:user) }

  before(:all) do
    Dir.mkdir("#{Dir.pwd}/public") unless Dir.exist?("#{Dir.pwd}/public")
    Dir.mkdir("#{Dir.pwd}/public/uploads") unless Dir.exist?("#{Dir.pwd}/public/uploads")
  end

  after(:all) do
    FileUtils.rm_rf('public/uploads', secure: true)
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

  context 'GET /v1/events/:event_id/documents' do
    it 'get all the documents from an event' do
      event = event_with_documents(3, user.id)
      documents = event.documents

      header 'Authorization', "Bearer #{token(user)}"
      get "/v1/events/#{event.id}/documents"

      expect(last_response.status).to eq 200
      expect(last_response.content_type).to include('application/json')

      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body[0]['file_path']).to eq(documents[0].file_path)
      expect(parsed_body[1]['file_path']).to eq(documents[1].file_path)
      expect(parsed_body[2]['file_path']).to eq(documents[2].file_path)
    end

    it 'event does not have documents created' do
      event = create(:event, owner_id: user.id)

      header 'Authorization', "Bearer #{token(user)}"
      get "/v1/events/#{event.id}/documents"

      expect(last_response.status).to eq 200
      parsed_body = JSON.parse(last_response.body)
      expect(parsed_body).to eq([])
    end
  end

  context 'GET /v1/events/:event_id/documents/:id' do
    it 'get specifc document from event' do
      event = create(:event, owner_id: user.id)
      document = create(:document, :image, event: event)

      header 'Authorization', "Bearer #{token(user)}"
      get "/v1/events/#{event.id}/documents/#{document.id}"

      expect(last_response.status).to eq 200
      expect(last_response.content_type).to include('application/json')
      parsed_body = JSON.parse(last_response.body)
      expect(parsed_body['file_path']).to eq(document.file_path)
      expect(parsed_body['file_type']).to eq(document.file_type)
      expect(parsed_body['file_name']).to eq(document.file_name)
    end
  end

  context 'POST /v1/events/:event_id/documents' do
    it 'create an document' do
      event = create(:event, owner_id: user.id)

      header 'Authorization', "Bearer #{token(user)}"
      post "/v1/events/#{event.id}/documents",
           :file => Rack::Test::UploadedFile.new(
             'spec/fixtures/test_image.jpeg',
             'image/jpeg'
           ), 'CONTENT_TYPE' => 'image/jpeg'

      expect(last_response.status).to eq 201
    end

    it 'can upload PDF' do
      event = create(:event, owner_id: user.id)

      header 'Authorization', "Bearer #{token(user)}"
      post "/v1/events/#{event.id}/documents",
           :file => Rack::Test::UploadedFile.new(
             'spec/fixtures/Desafio - Programa de OnBoarding.pdf',
             'appplication/pdf'
           ),
           'CONTENT_TYPE' => 'appplication/pdf'

      expect(last_response.status).to eq 201
    end

    it 'can upload DOCX' do
      event = create(:event, owner_id: user.id)
      mime_type_docx = 'application/vnd.openxmlformats-officedocument.presentationml.presentation'

      header 'Authorization', "Bearer #{token(user)}"
      post "/v1/events/#{event.id}/documents",
           :file => Rack::Test::UploadedFile.new(
             'spec/fixtures/Teste.docx', mime_type_docx
           ), 'CONTENT_TYPE' => mime_type_docx

      expect(last_response.status).to eq 201
    end

    it 'can upload ODS' do
      event = create(:event, owner_id: user.id)

      header 'Authorization', "Bearer #{token(user)}"
      post "/v1/events/#{event.id}/documents",
           :file => Rack::Test::UploadedFile.new('spec/fixtures/teste.ods',
                                                 'application/vnd.oasis.opendocument.spreadsheet'),
           'CONTENT_TYPE' => 'application/vnd.oasis.opendocument.spreadsheet'
      expect(last_response.status).to eq 201
    end

    it 'can upload XLSX' do
      event = create(:event, owner_id: user.id)

      header 'Authorization', "Bearer #{token(user)}"
      post "/v1/events/#{event.id}/documents",
           :file => Rack::Test::UploadedFile.new(
             'spec/fixtures/teste.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
           ),
           'CONTENT_TYPE' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'

      expect(last_response.status).to eq 201
    end

    it 'can upload PPTX' do
      event = create(:event, owner_id: user.id)
      mime_type_pptx = 'application/vnd.openxmlformats-officedocument.presentationml.presentation'

      header 'Authorization', "Bearer #{token(user)}"
      post "/v1/events/#{event.id}/documents",
           :file => Rack::Test::UploadedFile.new('spec/fixtures/teste.pptx', mime_type_pptx),
           'CONTENT_TYPE' => mime_type_pptx

      expect(last_response.status).to eq 201
    end

    it 'empty file' do
      event = create(:event, owner_id: user.id)

      header 'Authorization', "Bearer #{token(user)}"
      post "/v1/events/#{event.id}/documents"

      expect(last_response.status).to eq 400
    end

    it "event don't exist" do
      header 'Authorization', "Bearer #{token(user)}"
      post "/v1/events/#{rand(1...1000)}/documents",
           :file => Rack::Test::UploadedFile.new(
             'spec/fixtures/Desafio - Programa de OnBoarding.pdf',
             'appplication/pdf'
           ),
           'CONTENT_TYPE' => 'appplication/pdf'

      expect(last_response.status).to eq 404
    end
  end

  context 'GET GET /v1/events/:event_id/documents/:id/download' do
    it 'successfully' do
      event = create(:event, owner_id: user.id)
      document = create(:document, event: event)

      header 'Authorization', "Bearer #{token(user)}"
      get "/v1/events/#{event.id}/documents/#{document.id}/download"

      expect(last_response.status).to eq(200)
      expect(last_response.headers['Content-Type']).to eq('Application/octet-stream')
    end
  end
end
