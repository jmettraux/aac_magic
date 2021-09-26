
generate:
	@echo
	ruby lib/generate.rb
	@echo
	wc src/spells*.md
	@echo
g: generate

stats:
	@echo
	ruby lib/stats.rb
	@echo
s: stats

descriptions:
	@echo
	ruby lib/desc.rb
	@echo
d: descriptions

