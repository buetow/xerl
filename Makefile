all: check format push
check:
	@echo Checking for valid XML
	find . -name \*.xml -type f | while read xml; do \
		xmllint "$$xml" >/dev/null; \
		done
format:
	@echo Re-Formatting XML files
	find . -name \*.xml -type f | while read xml; do \
		xmllint --format "$$xml" >"$$xml.tmp" && \
		mv "$$xml.tmp" "$$xml"; \
		done
	git commit -a -m 'Reformatted XML' || exit 0
push:
	git push origin hosts
