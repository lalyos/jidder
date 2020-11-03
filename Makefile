build:
	go-bindata cmd
	go build

deps:
	@go-bindata --version || go get github.com/jteeuwen/go-bindata/...

cross: deps
	go-bindata cmd
	GOOS=linux go build -o build/jidder-Linux
	GOOS=darwin go build -o build/jidder-Darwin
	chmod +x build/jidder-*

ci: cross
	zip build/jidder.zip build/jidder-Darwin build/jidder-Linux

clean:
	rm -rf build