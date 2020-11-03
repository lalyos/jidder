build:
	go-bindata cmd
	go build

deps:
	go get github.com/jteeuwen/go-bindata/...

cross: deps
	go-bindata cmd
	GOOS=linux go build -o jidder-Linux
	GOOS=darwin go build -o jidder-Darwin