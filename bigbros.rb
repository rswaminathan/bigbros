require 'rubygems'
require 'bundler/setup'
require 'mime'
require 'gmail'
require 'base64'
require 'yaml'

while true do
  
  config = YAML.load_file(File.expand_path("gmail.yml"))

  t = Time.now.strftime("%d-%m-%y-%H-%M-%S")
  `screencapture -x ./#{t}.png`

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

  sleep(60*rand(15)+60)
  while `system_idle_time.sh`.to_i > 30 do
    sleep(60)
  end
end
