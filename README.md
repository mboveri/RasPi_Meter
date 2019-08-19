# DC/OS Doomsday Clock
**Goal** - Create a [Doomsday Clock](https://en.wikipedia.org/wiki/Doomsday_Clock) for our DC/OS cluster.   

Our focus was to map out the potential for failure within our DC/OS cluster based on hardware constraints: CPU / Memory / Disk space.  Every hour the clock displays how close the cluster is to capacity.  During the live demo seen below the CPU usage is closest to midnight at just under 70%.  Leveraging LEDs we are able to show which hardware constraint is currently being shown. As we hit 11:24 PM - 95% we also trigger a flashing red LED to signify midnight is close at hand.

### The Team
![The Team](/images/The_Team.png "The Team")
Left to Right - Matt Boveri, David Crowder, Sam Livingston, Ian Kottman, Anthony (Big Boss) Ross

### Clock Metrics
1. 0 - 70% = Green
1. 71 - 85% = Yellow
1. 86% - 100% = Red
1. At 95%+ Red LED is illuminated

![Usage Meter](/images/usage_meter.gif)

![Cluster Clock CPU](/images/clock_face_CPU.jpg?raw=true "Cluster Clock CPU")

![Cluster Clock Memory](/images/clock_face_MEM.jpg?raw=true "Cluster Clock Memory")

![Cluster Clock Raspberry Pi Top](/images/PI_top.jpg?raw=true "Cluster Clock Raspberry Pi Top")

![Cluster Clock Raspberry Pi Side](/images/PI_side.jpg?raw=true "Cluster Clock Raspberry Pi Side")

# Running it
Configure secrets in `local.env`. See `local.env.example` for an example of what keys are required.

```
docker-compose up --build clusterclock
```
# Raspberry Pi Configuration

Using the below chart for the Raspberry Pi we mapped the servo and led to available GPIO pins and grounds.  As we were not using a breadboard for this proof of concept each GPIO connection also had a ground connection.  The connections are as follows:
1. Servo - GPIO2 / Raspberry Pi slot 3
1. Blue LED - GPIO3 / Raspberry Pi slot 5
1. Green LED - GPIO4 / Raspberry Pi slot 7
1. Yellow LED - GPIO17 / Raspberry Pi slot 11
1. Red LED - GPIO27 / Raspberry Pi slot 13

Using the [Plastic Gear Analog servo from Micro Center](https://www.microcenter.com/product/487781/mini-analog-servo) we were able to calculate the proper PWM frequency and servo range of 50 and 180 respectively.

![Raspberry Pi 3 Configuration](/images/Raspberry_Pi.png?raw=true "Raspberry Pi 3 Configuration")
