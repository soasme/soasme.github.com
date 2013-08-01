site:
	rm -rf tag
	rm -rf categories
	exec jekyll --no-server --no-auto
	rsync -vr --inplace --delete _site/tag/ tag
	rsync -vr --inplace --delete _site/categories/ categories
	git add categories
	git add tag
	git commit -m 'make site.'
	@echo 'Success to build site'

commit_post:
	git commit -m 'add new post'

commit: site commit_post
