# encoding:UTF-8

require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
require 'pp'
require 'amazon_product'

configure do
  set :haml, { :format => :html5 }
end

def amazon_product (amazonId)
  req = AmazonProduct["jp"]
  req.configure do |c|
    c.key      = ENV['AMAZON_API_KEY']
    c.secret   = ENV['AMAZON_API_SECRET']
    c.tag      = ENV['AMAZON_API_TAG']
  end
  req << {
    :operation    => 'ItemLookup',
    :ItemId       => amazonId ,
    :response_group => %w{Medium},
  }
  res = req.get
  @item = res.find('Item')
  return @item
end

def amazon_search (word)
  req = AmazonProduct["jp"]
  req.configure do |c|
    c.key      = ENV['AMAZON_API_KEY']
    c.secret   = ENV['AMAZON_API_SECRET']
    c.tag      = ENV['AMAZON_API_TAG']
  end
  req << {
    :operation    => 'ItemSearch',
    :search_index => "All",
    :response_group => %w{Medium},
    :keywords => word,
  }
  res = req.get
  @item = res.find('Item')
  return @item
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
  alias_method :u, :escape
end

get '/' do
  @item = ""
  @msg = "amazonId(ISDN or ASIN)"
  haml :index
end

post '/' do
  amazon_product (params[:amazonId])
  @msg = "No Product"
  haml :index
end

post '/search' do
  amazon_search (params[:search])
  @msg = "No Product"
  haml :index
end

get '/search/*' do |keyword|
  amazon_search (keyword)
  @msg = "No Product"
  haml :index
end

get '/*.css' do |path|
  content_type 'text/css', :charset => 'utf-8'
  scss path.to_sym
end

get '/*.html' do |path|
  begin
    pass unless File.exist?(File.join(options.views, "#{path}.haml"))
    haml path.to_sym
  rescue Errno::ENOENT
    redirect not_found
  end
end

get '/*' do |path|
  pass unless File.exist?(File.join(options.views, "#{path}.haml"))
  haml path.to_sym
end
