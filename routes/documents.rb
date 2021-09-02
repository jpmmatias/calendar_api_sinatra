get '/v1/events/:event_id/documents' do
  user = request.env[:user]
  event = Event.where(['id = ? and owner_id=?', params['event_id'].to_s, user['id'].to_s]).first
  status 200
  { success: true, documents: event.documents }.to_json
end

get '/v1/events/:event_id/documents/:id' do
  user = request.env[:user]
  event = Event.where(['id = ? and owner_id=?', params['event_id'].to_s, user['id'].to_s]).first
  document = Document.where(['id = ? and event_id = ?', params['id'].to_s, event.id.to_s]).first
  if document.nil?
    status 404
    json({ success: false, message: 'Nonexistent document' })
  else
    status 200
    { success: true, document: document }.to_json
  end
end

get '/v1/events/:event_id/documents/:id/download' do
  status 200
  document = Document.find(params[:id])
  send_file "./#{document.file_path}", filename: document.file_name, type: 'Application/octet-stream'
end

post '/v1/events/:event_id/documents' do
  if params[:file].nil?
    status 400
    return { success: false, message: 'File param error' }.to_json
  end

  event = Event.where(id: params['event_id']).first

  if event.nil?
    status 404
    return { success: false, message: "Can't upload document because event don't exist" }.to_json
  end

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
    return { success: true }.to_json
  end
end
