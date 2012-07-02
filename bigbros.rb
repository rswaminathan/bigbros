require 'rubygems'
require 'bundler/setup'
require 'mime'
require 'gmail'
require 'base64'
require 'yaml'
require 'open-uri'
require 'ruby_gntp'

  config = YAML.load_file(File.expand_path("settings.yml"))

def config
  YAML.load_file(File.expand_path("settings.yml"))
end


def growl_notify(title, text)
  GNTP.notify(app_name: "Beeminder-Ruby", title: title, text: text, icon: "http://icons.iconarchive.com/icons/gordon-irving/iWork-10/256/pages-brown-icon.png") if config["growl"]
end

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

def do_pomodoro
  #take screenshot around 3/4 times every pomodoro
  pomodoro_time = config["pomodoro_time"]
  growl_notify("Pomodoro Time", "Start your #{pomodoro_time} minute pomodoro")
  pomodoro_time.times.each do |t|
    sleep(60)
    email_screenshot if internet_connection? && !idle? && rand(5) == 4
    while idle? do  #don't quit pomodoro when idle
      sleep(30)
    end
  end
end

def take_a_break
  break_time = config["break_time"].to_i
  growl_notify("Break Time", "You have a #{break_time} minute break")
  sleep(break_time*60 - 30)
  growl_notify("Break Ending", "Break ending in 30 seconds")
  sleep(30)
end

while true do
  do_pomodoro
  take_a_break
end
