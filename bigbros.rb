require 'rubygems'
require 'bundler/setup'
require 'flickraw'
require 'mime'
require 'gmail'
require 'base64'
require 'yaml'

exit if rand(20) < 19

config = YAML.load_file(File.expand_path("gmail.yml"))

t = Time.now.strftime("%d-%m-%y-%H-%M-%S")
`screencapture ./#{t}.png`

msg = "Random screenshot"


gmail = Gmail.new(config["email"], Base64.decode64(config["password"]))

gmail.deliver do 
  to config["to"]
  subject "Random screenshot"
  text_part do
    "check this out"
  end
  add_file "./#{t}.png"
end

gmail.logout

#remove file
`rm #{t}.png`
