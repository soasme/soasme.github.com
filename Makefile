.DEFAULT_GOAL := serve

setup:
	bundle install

serve:
	bundle exec jekyll serve

add:
	git add _posts/*/*/*.md
	git commit -m 'add new post'
