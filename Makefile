emoji_borrower: clean
	nim -d:release -d:ssl --opt:speed --app:console --outdir:dist c emoji_borrower

clean:
	rm -rf dist/emoji_borrower

install: emoji_borrower
	cp dist/emoji_borrower /usr/bin/emoji_borrower
	chmod +x /usr/bin/emoji_borrower

uninstall:
	rm -rf /usr/bin/emoji_borrower
