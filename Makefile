build:
	go-bindata cmd
	go build

build-dev:
	go-bindata -debug cmd
	go build

install-dev:
	ln -s $(PWD)/jidder ~/.krew/bin/kubectl-jid
	ln -s $(PWD)/jidder ~/.krew/bin/kubectl-jid_cols

deps:
	@go-bindata --version || go install github.com/jteeuwen/go-bindata/go-bindata@latest

cross: deps
	go-bindata cmd
	GOOS=linux GOARCH=amd64 go build -o build/jidder-Linux-amd64
	GOOS=linux GOARCH=arm64 go build -o build/jidder-Linux-arm64
	GOOS=darwin GOARCH=amd64 go build -o build/jidder-Darwin-amd64
	GOOS=darwin GOARCH=arm64 go build -o build/jidder-Darwin-arm64

ci: cross
	zip build/jidder.zip build/jidder-Darwin-amd64 build/jidder-Darwin-arm64 build/jidder-Linu-amd64 build/jidder-Linux-arm64
	tar -czvf build/jidder.tgz -C build jidder-Darwin-amd64 jidder-Darwin-arm64 jidder-Linux-amd64 jidder-Linux-arm64

clean:
	rm -rf build
	rm -rf /usr/local/bin/kubectl-jid*
	rm -rf ~/.krew/bin/kubectl-jid*
	rm -rf ~/.krew/store/jid/
	rm -rf ~/.krew/receipts/jid.yaml
	rm -rf ~/.krew/store/jid-cols/
	rm -rf ~/.krew/receipts/jid-cols.yaml