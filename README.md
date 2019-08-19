# DC/OS Capacity Meter
**Goal** - Create a capacity meter for our DC/OS cluster.   

Our focus was to map out the potential for failure within our DC/OS cluster based on hardware constraints: CPU / Memory / Disk space. Every hour the meter will sample the usage and display the currently most used. During the live demo seen below CPU is the most utilized at just under 70%. We use colorful LEDs to signify which hardware type is currently displayed. As we hit 95% we also trigger a flashing red LED to alert that we are nearly at capacity.

### The Team
![The Team](/images/The_Team.png "The Team")
Left to Right - Matt Boveri, David Crowder, Sam Livingston, Ian Kottman, Anthony (Big Boss) Ross

### Meter Metrics
1. 0 - 70% = Green
1. 71 - 85% = Yellow
1. 86% - 100% = Red
1. At 95%+ Red LED is illuminated

![Usage Meter](/images/usage_meter.gif)

![Cluster CPU Meter](/images/meter_face_CPU.jpg?raw=true "Cluster Meter CPU")

![Cluster Memory Meter](/images/meter_face_MEM.jpg?raw=true "Cluster Meter Memory")

![Raspberry Pi Top](/images/PI_top.jpg?raw=true "Cluster Meter Raspberry Pi Top")

![Raspberry Pi Side](/images/PI_side.jpg?raw=true "Cluster Meter Raspberry Pi Side")

# Running it
Configure secrets in `local.env`. See `local.env.example` for an example of what keys are required.

```
docker-compose up --build clustermeter
docker push {your_own_path}/clustermeter:1.0
```
# Raspberry Pi Configuration

Using the below chart for the Raspberry Pi we mapped the servo and led to available GPIO pins and grounds.  As we were not using a breadboard for this proof of concept each GPIO connection also had a ground connection.  The GPIO connections are as follows:
1. Servo - GPIO2 / Raspberry Pi slot 3
1. Blue LED - GPIO3 / Raspberry Pi slot 5
1. Green LED - GPIO4 / Raspberry Pi slot 7
1. Yellow LED - GPIO17 / Raspberry Pi slot 11
1. Red LED - GPIO27 / Raspberry Pi slot 13

Using the [Plastic Gear Analog servo from Micro Center](https://www.microcenter.com/product/487781/mini-analog-servo) we were able to calculate the proper PWM frequency and servo range of 50 and 180 respectively.

![Raspberry Pi 3 Configuration](/images/Raspberry_Pi.png?raw=true "Raspberry Pi 3 Configuration")
