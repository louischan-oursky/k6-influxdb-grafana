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
5. Run `make run` to run a sample load test.
6. See the real-time results in Grafana dashboard.

## What's next

You are supposed to write your own k6 testing scenarios.
The example in this repository is for demo purpose only.

## TODO

1. Security hardening by generating the credentials instead of using static ones.
2. Use volumes to persist real-time results.
