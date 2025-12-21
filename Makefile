NAME="til"

run:
	zig build
	@$(MAKE) install

debug:
	zig build run 2>&1 | less

prod:
	zig build -Doptimize=ReleaseFast
	@$(MAKE) install

install:
	@# Make sure to add `export PATH="$HOME/bin:$PATH"` to be able to use it from anywhere.
	mkdir -p ~/bin
	rm -f ~/bin/$(NAME)
	mv ./zig-out/bin/$(NAME) ~/bin/$(NAME)

