clean:
	-@docker kill ncona-blog 2>/dev/null ||:
	-@docker rm ncona-blog 2>/dev/null ||:
.PHONY: clean

build:
	@docker build -t ncona-blog .
.PHONY: build

start: build
	@docker run -it -p 4000:4000 -v $(PWD)/_drafts:/blog/_drafts -v $(PWD)/_posts:/blog/_posts -v $(PWD)/images:/blog/images ncona-blog
.PHONY: start

generate-tags: build
	@docker run -it -v $(PWD)/tag-pages:/blog/tag-pages ncona-blog ./_scripts/tag-generator.py
.PHONY: start

verify: clean build
	@docker run -it ncona-blog ./_scripts/verify-all-tags-committed.sh
.PHONY: verify
