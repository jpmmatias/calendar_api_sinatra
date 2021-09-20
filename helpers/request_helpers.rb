helpers do
  def get_body(req)
    req.body.rewind
    JSON.parse(req.body.read)
  rescue JSON::ParserError
    halt response_body(400, error: 'Please send JSON for the API')
  end

  def response_body(status, body)
    [status(status), body.to_json]
  end

  def update_values(body)
    body.map { |key, value| { key.gsub(' 00:00:00+00', '') => value } }.reduce(:merge)
  end
end
