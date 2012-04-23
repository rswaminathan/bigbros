require 'rubygems'
require 'bundler/setup'
require 'flickraw'
require 'mime'
require 'gmail'
require 'base64'

load 'gmail.rb'
t = Time.now.strftime("%d-%m-%y-%H-%M-%S")
`screencapture ./#{t}.png`

msg = "Random screenshot"


gmail = Gmail.new(email, Base64.decode64(password))

gmail.deliver do 
  to "ida.noeman@gmail.com"
  subject "Random screenshot"
  text_part do
    "check this out"
  end
  add_file "./#{t}.png"
end

gmail.logout

#remove file
`rm #{t}.png`
