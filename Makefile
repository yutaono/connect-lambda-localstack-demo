.PHONY: build deploy clean

ENDPOINT ?= http://localhost:4566
FUNCTION_NAME ?= demo-function
REGION ?= ap-northeast-1

build:
	buf lint
	buf generate
	GOOS=linux GOARCH=amd64 go build -tags lambda.norpc -o bootstrap cmd/server/main.go
	zip function.zip bootstrap

deploy:
	env ENDPOINT=$(ENDPOINT) FUNCTION_NAME=$(FUNCTION_NAME) REGION=$(REGION) bash deploy.sh

clean:
	rm -f bootstrap function.zip
	rm -rf gen
