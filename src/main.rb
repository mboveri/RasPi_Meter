require 'faraday'
require 'json'
require 'rpi_gpio'


def call_new_relic()
  account_id = ENV['NEW_RELIC_ACCOUNT_ID']
  query = ENV['INSIGHTS_QUERY']
  headers =  { 
    'X-Query-Key' => ENV['NEW_RELIC_INSIGHTS_QUERY_KEY'],
    'Accept' => 'application/json'
  }
  url = "https://insights-api.newrelic.com/v1/accounts/#{account_id}/query?nrql=#{query}"

  response = Faraday.get(url, nil, headers)
  puts response.body
end

def flash_led()
  RPi::GPIO.setup PIN_NUM, :as => :output
  RPi::GPIO.set_high PIN_NUM
  sleep(5)
  RPi::GPIO.set_low PIN_NUM
  sleep(5)
end

def set_angle(pwm, angle)
  duty = angle / 18 + 2
  puts "Setting servo to #{angle} with duty cycle #{duty}"
  pwm.duty_cycle = duty
end

puts "starting"
PIN_NUM = 03
PWM_FREQ = 50
RPi::GPIO.set_numbering :board
RPi::GPIO.setup PIN_NUM, :as => :output
pwm = RPi::GPIO::PWM.new(PIN_NUM, PWM_FREQ)

pwm.start(0)
set_angle(pwm, 0)
sleep(3)
set_angle(pwm, 90)
sleep(3)
set_angle(pwm, 180)

pwm.stop
RPi::GPIO.reset
puts "done."
