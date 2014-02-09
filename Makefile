.PHONY: deps server test syncdb serverdb ami

brewapi: api.go mtgjson.go etl.go search.go
	go build -o brewapi

deps:
	go get -d -v ./...


serve:
	DECKBREW_HOSTNAME="http://localhost:3000" go run mtgjson.go etl.go api.go search.go

test: cards.json 
	go test -v

syncdb: cards.json 
	go run mtgjson.go etl.go api.go search.go load cards.json

ami: deckbrew
	packer build template.json

deckbrew: Makefile *.go schema/*.sql
	mkdir -p deckbrew
	cp *.go deckbrew
	cp -r formats deckbrew
	cp Makefile deckbrew

cards.json:
	wget http://mtgjson.com/json/AllSets-x.json.zip
	unzip AllSets-x.json.zip
	mv mnt/compendium/DevLab/mtgjson/web/json/AllSets-x.json cards.json
	rm -f AllSets-x.json.zip
	rm -rf mnt

clean:
	rm -f brewapi
	rm -rf deckbrew
