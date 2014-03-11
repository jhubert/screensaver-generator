## file: app.rb

require 'dotenv'
Dotenv.load

require 'sinatra'
require 'sinatra/activerecord'
require './config/environments' #database configuration
require 'oauth2'
require 'json'

require 'sinatra/partial'

require 'stripe'

Stripe.api_key = "sk_test_DrN5wIPuOzNjCF2e5Rz49F46"

require_relative './lib/auth.rb'
require_relative './models/package.rb'

enable :sessions

set :partial_template_engine, :erb

get '/' do
  erb :index
end

get '/savers' do
  secure_endpoint

  @packages = Package.where(email_address: current_email)

  erb :list
end

get '/savers/new' do
  secure_endpoint

  erb :new
end

get '/savers/:id' do
  secure_endpoint

  @package = Package.find(params[:id])
  @email = current_email

  erb :show
end

get '/savers/:id/edit' do
  secure_endpoint

  @package = Package.find(params[:id])

  erb :edit
end

get '/savers/:id/demo' do
  secure_endpoint

  @package = Package.find(params[:id])

  erb :demo, layout: false
end

post '/savers' do
  secure_endpoint
  @package = create_package(params[:package])
  redirect "/savers/#{@package.id}"
end

post '/savers/:id' do
  secure_endpoint
  @package = update_package(params[:id], params[:package])
  redirect "/savers/#{@package.id}"
end

post '/charge' do
  @package = Package.where(id: params[:package_id], email_address: current_email).first

  create_charge(@package)

  @package.update_attribute(:paid, true)

  redirect "/savers/#{@package.id}"
end

def secure_endpoint
  redirect '/' unless logged_in?
end

def logged_in?
  !!session[:access_token]
end

def current_email
  if access_token
    email_endpoint = 'https://www.googleapis.com/userinfo/email?alt=json'
    response = access_token.get(email_endpoint).parsed
    response["data"]["email"]
  end
rescue OAuth2::Error
  redirect '/'
end

def create_package(attrs = {})
  Package.create(
    name: attrs[:name],
    quotes_as_csv: attrs[:quotes_as_csv],
    email_address: current_email
  )
end

def update_package(id, attrs = {})
  package = Package.find(id)
  package.update_attributes(
    name: attrs[:name],
    quotes_as_csv: attrs[:quotes_as_csv]
  )
  package
end

def create_charge(package, token)
  Stripe::Charge.create(
    amount: 2000,
    currency: "usd",
    card: token,
    description: "Charge for ##{package.id} - #{package.name}"
  )
end
