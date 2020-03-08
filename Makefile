# We are using the `deploy.sh` script for the deployment, NOT the default make command from Tavis.
#
# When travis runs, It expects and calls the `make` command (and the Makefile) by default.
# We are NOT using this Makefile but the file ./web/Makefile
# We're adding the `test` step to avoid this scenario and make sure travis doesn't run `make`.

test:
	@echo $(PROFILE) at $(REGION)

# TODO: Review the below code:
# At this point it is unclear why we need these
# The variables 
#	- DEVUPJSON
#	- REGION
# are not set anyway
# the files:
#	- project.dev.json.in
#	- project.dev.json
# Have been replaced and should be obsolete

dev:
	go generate
	jq $(DEVUPJSON) project.dev.json.in > project.dev.json
	@echo $$AWS_ACCESS_KEY_ID
	apex -r $(REGION) --env dev deploy

devlogs:
	@echo $$AWS_ACCESS_KEY_ID
	apex -r $(REGION) --env dev logs

# END TODO
