# k6-influxdb-grafana

## Overview

This repository contains a simply k6 InfluxDB v2 setup with Grafana.

The intended use case is letting you to run k6,
and stream the real-time results to InfluxDB v2,
and view the results in Grafana.

## How do I use this

1. Your machine has `xk6` and `go` available in `PATH`. If you are a Nix Flake user and a direnv user, then you can just make use of the flake in this repository.
2. Your machine has a recent enough copy of `docker`.
3. Run `make k6` to build a custom build of k6 with support for `github.com/grafana/xk6-output-influxdb`.
3. Run `docker compose up` to start InfluxDB and Grafana.
4. Visit Grafana at `http://localhost:3000`. The credentials are in `docker-compose.yaml`.
5. Run `TEST_RUN_ID=some_string_to_identify_this_run make run` to run a sample load test.
6. See the real-time results in Grafana dashboard.

## What's next

You are supposed to write your own k6 testing scenarios.
The example in this repository is for demo purpose only.

## Test results

The results are written to `./influxdb_data/`.
If you want to clear everything, you can remove this directory.

## TODO

1. Security hardening by generating the credentials instead of using static ones.

## The Flux queries used in the dashboard

The following Flux queries are used in building the dashboard.
They are listed here for reference only.

```flux
from(bucket: v.defaultBucket)
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == "http_reqs")
  |> filter(fn: (r) => r["_field"] == "value")
  |> filter(fn: (r) => if "${test_run_id}" == "null" then true else r["test_run_id"] == "${test_run_id}")
  |> group(columns: ["scenario"])
  |> aggregateWindow(every: v.windowPeriod, fn: sum)
  |> yield(name: "http_reqs_per_second")


from(bucket: v.defaultBucket)
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == "iterations")
  |> filter(fn: (r) => r["_field"] == "value")
  |> filter(fn: (r) => if "${test_run_id}" == "null" then true else r["test_run_id"] == "${test_run_id}")
  |> group(columns: ["scenario"])
  |> aggregateWindow(every: v.windowPeriod, fn: sum)
  |> yield(name: "iterations_per_second")


from(bucket: v.defaultBucket)
  |> range(start: v.timeRangeStart, stop:v.timeRangeStop)
  |> filter(fn: (r) => r._measurement == "http_req_duration")
  |> filter(fn: (r) => r._field == "value")
  |> filter(fn: (r) => if "${test_run_id}" == "null" then true else r["test_run_id"] == "${test_run_id}")
  |> group(columns: [])
  |> aggregateWindow(every: v.windowPeriod, fn: mean)
  |> yield(name: "mean")
from(bucket: v.defaultBucket)
  |> range(start: v.timeRangeStart, stop:v.timeRangeStop)
  |> filter(fn: (r) => r._measurement == "http_req_duration")
  |> filter(fn: (r) => r._field == "value")
  |> filter(fn: (r) => if "${test_run_id}" == "null" then true else r["test_run_id"] == "${test_run_id}")
  |> group(columns: [])
  |> aggregateWindow(every: v.windowPeriod, fn: (tables=<-, column) => tables |> quantile(q: 0.5))
  |> yield(name: "p50")
from(bucket: v.defaultBucket)
  |> range(start: v.timeRangeStart, stop:v.timeRangeStop)
  |> filter(fn: (r) => r._measurement == "http_req_duration")
  |> filter(fn: (r) => r._field == "value")
  |> filter(fn: (r) => if "${test_run_id}" == "null" then true else r["test_run_id"] == "${test_run_id}")
  |> group(columns: [])
  |> aggregateWindow(every: v.windowPeriod, fn: (tables=<-, column) => tables |> quantile(q: 0.95))
  |> yield(name: "p95")


from(bucket: v.defaultBucket)
  |> range(start: v.timeRangeStart, stop:v.timeRangeStop)
  |> filter(fn: (r) => r._measurement == "iteration_duration")
  |> filter(fn: (r) => r._field == "value")
  |> filter(fn: (r) => if "${test_run_id}" == "null" then true else r["test_run_id"] == "${test_run_id}")
  |> group(columns: ["scenario"])
  |> aggregateWindow(every: v.windowPeriod, fn: mean)
  |> yield(name: "mean")
from(bucket: v.defaultBucket)
  |> range(start: v.timeRangeStart, stop:v.timeRangeStop)
  |> filter(fn: (r) => r._measurement == "iteration_duration")
  |> filter(fn: (r) => r._field == "value")
  |> filter(fn: (r) => if "${test_run_id}" == "null" then true else r["test_run_id"] == "${test_run_id}")
  |> group(columns: ["scenario"])
  |> aggregateWindow(every: v.windowPeriod, fn: (tables=<-, column) => tables |> quantile(q: 0.5))
  |> yield(name: "p50")
from(bucket: v.defaultBucket)
  |> range(start: v.timeRangeStart, stop:v.timeRangeStop)
  |> filter(fn: (r) => r._measurement == "iteration_duration")
  |> filter(fn: (r) => r._field == "value")
  |> filter(fn: (r) => if "${test_run_id}" == "null" then true else r["test_run_id"] == "${test_run_id}")
  |> group(columns: ["scenario"])
  |> aggregateWindow(every: v.windowPeriod, fn: (tables=<-, column) => tables |> quantile(q: 0.95))
  |> yield(name: "p95")

from(bucket: v.defaultBucket)
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == "http_req_failed")
  |> filter(fn: (r) => r["_field"] == "value")
  |> filter(fn: (r) => if "${test_run_id}" == "null" then true else r["test_run_id"] == "${test_run_id}")
  |> group(columns: ["scenario"])
  |> aggregateWindow(every: v.windowPeriod, fn: mean)
  |> yield(name: "http_req_failed")
```
