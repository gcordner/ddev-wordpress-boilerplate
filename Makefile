.PHONY: lint fix stan

lint:
	ddev composer lint

fix:
	ddev composer fix

stan:
	ddev composer stan

