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
	@go-bindata --version || go get github.com/jteeuwen/go-bindata/...

cross: deps
	go-bindata cmd
	GOOS=linux go build -o build/jidder-Linux
	GOOS=darwin go build -o build/jidder-Darwin

ci: cross
	zip build/jidder.zip build/jidder-Darwin build/jidder-Linux
	tar -czvf build/jidder.tgz -C build jidder-Darwin jidder-Linux

clean:
	rm -rf build
	rm -rf /usr/local/bin/kubectl-jid*
	rm -rf ~/.krew/bin/kubectl-jid*