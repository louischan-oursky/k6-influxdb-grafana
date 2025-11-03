.PHONY: k6
k6:
	xk6 build --with github.com/grafana/xk6-output-influxdb

run:
	K6_INFLUXDB_ORGANIZATION=loadtest K6_INFLUXDB_BUCKET=loadtest K6_INFLUXDB_INSECURE=true K6_INFLUXDB_TOKEN=loadtest K6_OUT=xk6-influxdb=http://127.0.0.1:8086 ./k6 run options.js
