require 'httparty'
require 'json'

module FCM
  include HTTParty

  @host = 'https://fcm.googleapis.com/fcm/send'
  @format = :json
  @key = nil

  class << self
    attr_accessor :host, :format, :key

    def key(identity = nil)
      if @key.is_a?(Hash)
        raise %{If your key is a hash of keys you'l need to pass a identifier to the notification!} if identity.nil?
        return @key[identity]
      else
        return @key
      end
    end

    def key_identities
      if @key.is_a?(Hash)
        return @key.keys
      else
        return nil
      end
    end
  end

  def self.send_notification(device_tokens:, data:, notification:, options: {})
    n = FCM::Notification.new(device_tokens: device_tokens,
                              data: data,
                              notification: notification,
                              options: options)
    self.send_notifications([n])
  end

  def self.send_notifications(notifications)
    responses = []
    notifications.each do |n|
      responses << self.prepare_and_send(n)
    end
    responses
  end

  private

  def self.prepare_and_send(n)
    if n.device_tokens.count < 1 || n.device_tokens.count > 1000
      raise "Number of device_tokens invalid, keep it betwen 1 and 1000"
    end
    if !n.collapse_key.nil? && n.time_to_live.nil?
      raise %q{If you are defining a "colapse key" you need a "time to live"}
    end
    if @key.is_a?(Hash) && n.identity.nil?
      raise %{If your key is a hash of keys you'l need to pass a identifier to the notification!}
    end

    if self.format == :json
      self.send_push_as_json(n)
    else
      raise "Invalid format"
    end
  end

  def self.send_push_as_json(n)
    headers_body = RequestCreator.create_headers_body(n)
    return self.send_to_server(headers_body[:headers], headers_body[:body].to_json)
  end

  def self.send_to_server(headers, body)
    params = {:headers => headers, :body => body}
    response = self.post(self.host, params)
    return build_response(response)
  end

  def self.build_response(response)
    case response.code
      when 200
        {:response =>  'success', :body => JSON.parse(response.body), :headers => response.headers, :status_code => response.code}
      when 400
        {:response => 'Only applies for JSON requests. Indicates that the request could not be parsed as JSON, or it contained invalid fields.', :status_code => response.code}
      when 401
        {:response => 'There was an error authenticating the sender account.', :status_code => response.code}
      when 500
        {:response => 'There was an internal error in the FCM server while trying to process the request.', :status_code => response.code}
      when 503
        {:response => 'Server is temporarily unavailable.', :status_code => response.code}
    end
  end

end
