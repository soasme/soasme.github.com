site:
	rm -rf tag
	rm -rf categories
	exec jekyll --no-server --no-auto
	rsync -vr --inplace --delete _site/tag/ tag
	rsync -vr --inplace --delete _site/categories/ categories
	git add categories
	git add tag
	@echo 'Success to build site'
