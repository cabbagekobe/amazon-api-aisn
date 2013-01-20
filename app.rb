# coding: UTF-8

require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'


configure do
  set :haml, { :format => :html5 }
  # -- basic 認証 --
  set :username, 'username'
  set :token, '123456789'
  set :password, 'password'
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
  alias_method :u, :escape
  # Example
  # = h scary_output

  def nl2br(str)
    str = html_escape(str)
    str.gsub(/\r\n|\r|\n/, "<br />")
  end
end

get '/' do
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
