.PHONY: check

check:
	flake8
	shellcheck -e SC1003 -e SC1090 pygmentize
