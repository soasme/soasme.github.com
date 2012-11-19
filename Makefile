t:
	rm -rf tag
	exec jekyll --no-server --no-auto
	rsync -vr --inplace --delete _site/tag/ tag
	@echo 'Success to build site'
