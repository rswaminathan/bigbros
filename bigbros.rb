require 'rubygems'
require 'bundler/setup'
require 'mime'
require 'gmail'
require 'base64'
require 'yaml'
require 'open-uri'

def internet_connection?
  begin
    return true if open("http://google.com")
  rescue
    false
  end
end

def idle?
  idle = `ioreg -c IOHIDSystem | perl -ane 'if (/Idle/) {$idle=(pop @F)/1000000000; print $idle; last}'`.to_f
  idle > 30
end

def email_screenshot
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
end

while true do
  email_screenshot if internet_connection? && !idle?
  sleep(60*rand(20)+60)
  while idle? do
    sleep(60)
  end
end
