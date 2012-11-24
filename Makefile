tag:
	rm -rf tag
	exec jekyll --no-server --no-auto
	rsync -vr --inplace --delete _site/tag/ tag
	@echo 'Success to build tag'

cat:
	rm -rf categories
	exec jekyll --no-server --no-auto
	rsync -vr --inplace --delete _site/categories/ categories
	@echo 'Success to build catogory'

site: tag cat
