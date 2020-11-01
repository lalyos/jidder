build:
	go-bindata cmd
	go build

deps:
	go get github.com/jteeuwen/go-bindata/...

