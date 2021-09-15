get '/v1/events/:event_id/documents' do
  user = request.env[:user]
  event = Event.where(['id = ? and owner_id=?', params['event_id'].to_s, user['id'].to_s]).first
  response_body(200, event.documents)
end

get '/v1/events/:event_id/documents/:id' do
  user = request.env[:user]
  event = Event.where(['id = ? and owner_id=?', params['event_id'].to_s, user['id'].to_s]).first
  document = Document.where(['id = ? and event_id = ?', params['id'].to_s, event.id.to_s]).first
  return response_body(200, document) if document

  [status(404), error('Nonexistent document')]
end

get '/v1/events/:event_id/documents/:id/download' do
  status 200
  document = Document.find(params[:id])
  send_file "./#{document.file_path}", filename: document.file_name, type: 'Application/octet-stream'
end

post '/v1/events/:event_id/documents' do
  return response_body(400, { error: 'File param error' }) if params[:file].nil?

  event = Event.where(id: params['event_id']).first

  return response_body(404, { error: "Can't upload document because event don't exist" }) if event.nil?

  file_name = params[:file][:filename]
  file = params[:file][:tempfile]
  type = params[:file][:type]

  document = Document.new(event: event, file_path: "./public/uploads/#{file_name}", file_type: type,
                          file_name: file_name)

  if document.save && !file_name.nil?
    if type == 'application/vnd.openxmlformats-officedocument.presentationml.presentation'
      File.open("./public/uploads/#{file_name}", 'wb') do |f|
        f.write(file.read.force_encoding('UTF-8'))
      end
    else
      File.open("./public/uploads/#{file_name}", 'wb') do |f|
        f.write(file.read)
      end
    end
    status 201
  end
end
