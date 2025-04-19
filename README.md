# Connect Lambda LocalStack Demo

This is a simple example for developing and testing AWS Lambda functions locally using LocalStack, Go, and [Connect](https://connectrpc.com/).

## Prerequisites

- Docker
- AWS CLI
- Go
- make

## Getting Started

```sh
# Start LocalStack
docker-compose up -d

# Build
make build

# Deploy
make deploy

# Invoke Lambda via API Gateway
export API_ID=TODO # set the result of make deploy
curl -H "Content-Type: application/json" \
 -d '{"name":"World"}' \
 "http://localhost:4566/_aws/execute-api/${API_ID}/dev/greet.v1.GreetService/Greet"
curl -H "Content-Type: application/json" \
 -d '{"timezone":"Asia/Tokyo"}' \
 "http://localhost:4566/_aws/execute-api/${API_ID}/dev/greet.v1.GreetService/GetTime"
```

## Cleanup

```sh
make clean
docker-compose down
```

---

This project is for local development and testing only.
