
generate:
	@echo
	ruby src/_generate.rb
	@echo
	wc src/spells.md
	@echo
g: generate

stats:
	@echo
	ruby src/_stats.rb
	@echo
s: stats

descriptions:
	@echo
	ruby src/_desc.rb
	@echo
d: descriptions

