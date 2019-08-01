require 'faraday'
require 'json'
require 'rpi_gpio'

Metric = Struct.new(:percent, :led_pin)
ClusterMetrics = Struct.new(:cpu, :mem, :disk)

# GPIO pins
SERVO = 3
BLUE_LED = 5
GREEN_LED = 7
YELLOW_LED = 11
RED_LED = 13
PWM_FREQ = 50

# calls new relic to find cluster metrics
# returns nil if it fails
def call_new_relic()
  puts "Calling new relic"
  account_id = ENV['NEW_RELIC_ACCOUNT_ID']
  query = ENV['INSIGHTS_QUERY']
  headers =  { 
    'X-Query-Key' => ENV['NEW_RELIC_INSIGHTS_QUERY_KEY'],
    'Accept' => 'application/json'
  }
  url = "https://insights-api.newrelic.com/v1/accounts/#{account_id}/query?nrql=#{query}"
  puts "calling #{url}"
  response = Faraday.get(url, nil, headers)
  unless response.success?
    "Failed to call new relic! Received status: #{response.status} and body #{response.body}" 
    return nil
  end
  event = JSON.parse(response.body)['results'].first['events'].first
  mem = (event['mem.percent'] * 100).ceil
  cpu = (event['cpus.percent'] * 100).ceil
  disk = (event['disk.percent'] * 100).ceil
  metrics = ClusterMetrics.new(
    Metric.new(cpu, BLUE_LED),
    Metric.new(mem, GREEN_LED),
    Metric.new(disk, YELLOW_LED)
  )
  puts metrics
  metrics
end

def find_worst_metric(metrics)
  [metrics.cpu, metrics.mem, metrics.disk].max_by(&:percent)
end

def flash_led(pin_num)
  RPi::GPIO.set_high pin_num
  sleep(5)
  RPi::GPIO.set_low pin_num
end

def turn_on_led(metric)
  # turn off everything
  RPi::GPIO.set_low BLUE_LED
  RPi::GPIO.set_low GREEN_LED
  RPi::GPIO.set_low YELLOW_LED
  # turn on the one we want
  RPi::GPIO.set_high metric.led_pin
end

def set_angle(pwm, angle)
  # 2.5 is the minimum, a.k.a. 0 degrees
  duty = angle / 18 + 2.5
  puts "Setting servo to #{angle} degrees with duty cycle #{duty}"
  # continuosly move towards the desired angle
  pwm.duty_cycle = duty
  # let it get to the angle
  sleep(1)
  # stop moving
  pwm.duty_cycle = 0
end

puts "setting up pins"
RPi::GPIO.reset
RPi::GPIO.set_numbering :board
RPi::GPIO.setup SERVO, :as => :output
RPi::GPIO.setup BLUE_LED, :as => :output
RPi::GPIO.setup GREEN_LED, :as => :output
RPi::GPIO.setup YELLOW_LED, :as => :output
pwm = RPi::GPIO::PWM.new(SERVO, PWM_FREQ)

metrics = call_new_relic

unless metrics.nil?
  worst_metric = find_worst_metric(metrics)
  pwm.start(0)
  set_angle(pwm, worst_metric.percent)
  turn_on_light(worst_metric)
  sleep(10)
end

pwm.stop
RPi::GPIO.reset
puts "done."
