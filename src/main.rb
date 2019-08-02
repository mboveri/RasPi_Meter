require 'faraday'
require 'json'
require 'rpi_gpio'

# always flush STDOUT immediately
$stdout.sync = true

Metric = Struct.new(:percent, :led_pin)
ClusterMetrics = Struct.new(:cpu, :mem, :disk)

# GPIO pins
SERVO = 3
BLUE_LED = 5
GREEN_LED = 7
YELLOW_LED = 11
RED_LED = 13
PWM_FREQ = 50
SERVO_RANGE = 180

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
  puts "mem: #{metrics.mem}, cpu: #{metrics.cpu}, disk: #{metrics.disk}"
  metrics
end

def find_worst_metric(metrics)
  [metrics.cpu, metrics.mem, metrics.disk].max_by(&:percent)
end

def critical_light(percent)
  if percent >= 95
    puts "metric at critical percent #{percent}"
    RPi::GPIO.set_high RED_LED
  else
    puts "metric not at critical percent: #{percent}"
    RPi::GPIO.set_low RED_LED
  end
end

def turn_on_led(pin)
  puts "Turning on LED at pin #{pin}"
  # turn off everything
  RPi::GPIO.set_low BLUE_LED
  RPi::GPIO.set_low GREEN_LED
  RPi::GPIO.set_low YELLOW_LED
  # turn on the one we want
  RPi::GPIO.set_high pin
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

def percent_to_angle(percent)
  (percent / 100) * SERVO_RANGE
end

def setup
  puts "setting up pins"
  RPi::GPIO.set_warnings(false)
  RPi::GPIO.set_numbering :board
  RPi::GPIO.setup SERVO, :as => :output, :initialize => :low
  RPi::GPIO.setup BLUE_LED, :as => :output, :initialize => :low
  RPi::GPIO.setup GREEN_LED, :as => :output, :initialize => :low
  RPi::GPIO.setup YELLOW_LED, :as => :output, :initialize => :low
  RPi::GPIO.setup RED_LED, :as => :output, :initialize => :low
  pwm = RPi::GPIO::PWM.new(SERVO, PWM_FREQ)
  pwm.start(0)
  pwm
end

def teardown(pwm)
  puts "tearing down"
  pwm.stop
  RPi::GPIO.set_low BLUE_LED
  RPi::GPIO.set_low GREEN_LED
  RPi::GPIO.set_low YELLOW_LED
  RPi::GPIO.set_low RED_LED
end

def debug(pwm)
  puts "testing LEDs"
  turn_on_led(BLUE_LED)
  sleep(1)
  turn_on_led(GREEN_LED)
  sleep(1)
  turn_on_led(YELLOW_LED)
  sleep(1)
  turn_on_led(RED_LED)

  puts "testing critical light: off"
  critical_light(94)
  sleep(1)
  puts "testing critical light: on"
  critical_light(95)

  puts "testing servo"
  set_angle(pwm, percent_to_angle(0))
  sleep(5)
  set_angle(pwm, percent_to_angle(70))
  sleep(20)
  set_angle(pwm, percent_to_angle(85))
  sleep(20)

  puts "testing normal workflow"
  update_metrics(pwm)
end

def update_metrics(pwm)
  puts "updating metrics"
  metrics = call_new_relic
  unless metrics.nil?
    worst_metric = find_worst_metric(metrics)
    set_angle(pwm, percent_to_angle(worst_metric.percent))
    turn_on_led(worst_metric.led_pin)
    critical_light(worst_metric.percent)
  end
end

begin 
  pwm = setup
  if ENV['DEBUG'] == 'true'
    debug(pwm)
  else
    update_metrics(pwm)
  end
ensure
  teardown(pwm)
end

puts "done."
