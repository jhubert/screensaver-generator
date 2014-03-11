# Setup Google Auth

ENV['G_API_CLIENT'] = "296595219401-b8mtqvh4m7j18766h3l8obq2auhgtigu.apps.googleusercontent.com"
ENV['G_API_SECRET'] = "rF8kbg0RurjZFo8tHTPLK1Ug"

# Scopes are space separated strings
SCOPES = [
    'https://www.googleapis.com/auth/userinfo.email'
].join(' ')

unless G_API_CLIENT = ENV['G_API_CLIENT']
  raise "You must specify the G_API_CLIENT env variable"
end

unless G_API_SECRET = ENV['G_API_SECRET']
  raise "You must specify the G_API_SECRET env veriable"
end

def client
  client ||= OAuth2::Client.new(G_API_CLIENT, G_API_SECRET, {
                site: 'https://accounts.google.com',
                authorize_url: "/o/oauth2/auth",
                token_url: "/o/oauth2/token"
              })
end

get "/auth" do
  redirect client.auth_code.authorize_url(
    redirect_uri: redirect_uri,
    scope: SCOPES,
    access_type: 'offline'
  )
end

get '/oauth/callback' do
  token = client.auth_code.get_token(params[:code], redirect_uri: redirect_uri)
  session[:access_token] = token.token

  redirect :savers
end

def access_token
  return unless session[:access_token]
  OAuth2::AccessToken.new(client, session[:access_token])
end

def redirect_uri
  uri = URI.parse(request.url)
  uri.path = '/oauth/callback'
  uri.query = nil
  uri.to_s
end

