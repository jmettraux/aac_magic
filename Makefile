
generate:
	@echo
	ruby src/_generate.rb
	@echo
	wc src/spells.md
	@echo

stats:
	@echo
	ruby src/_stats.rb
	@echo

