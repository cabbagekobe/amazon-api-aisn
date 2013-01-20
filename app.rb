# encoding:UTF-8

require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
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
    c.cache    = false
    c.locale   = 'jp'
    c.encoding = 'UTF-8'
  end
  req << {
    :operation    => 'ItemLookup',
    :ItemId       => amazonId ,
    :response_group => %w{ItemAttributes Images},
  }
  res = req.get
  @item = res.find('Item')
  return @item
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
  alias_method :u, :escape

  def nl2br(str)
    str = html_escape(str)
    str.gsub(/\r\n|\r|\n/, "<br />")
  end
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
