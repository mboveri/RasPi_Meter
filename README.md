# cluster_clock
Gathers DC/OS cluster metrics from new relic and sends them to a servo.

# Running it
Configure secrets in `local.env`. See `local.env.example` for an example of what keys are required.

```
docker-compose up --build clusterclock
```
