# This script deploys the invite API.
# This script is called by the `deploy.sh` file in the /web folder (this folder)
# We use this to deploy the lambda API with Travis CI
# The hard code variable TRAVIS_PROFILE below will be overridden when .travis.yml runs
TRAVIS_PROFILE = ins-dev

# We create a function to simplify getting variables for aws parameter store.

define ssm
$(shell aws --profile $(TRAVIS_PROFILE) ssm get-parameters --names $1 --with-decryption --query Parameters[0].Value --output text)
endef

# We get the profile information in we have in AWS DEV.
# These are for the DEV, PROD and DEMO environment

TRAVIS_PROFILE_DEV = $(call ssm,TRAVIS_PROFILE_DEV)
TRAVIS_PROFILE_PROD = $(call ssm,TRAVIS_PROFILE_PROD)
TRAVIS_PROFILE_DEMO = $(call ssm,TRAVIS_PROFILE_DEMO)

# We create a function to simplify getting variables for aws parameter store from the PROD.

define ssm-prod
$(shell aws --profile $(TRAVIS_PROFILE_PROD) ssm get-parameters --names $1 --with-decryption --query Parameters[0].Value --output text)
endef

# We create a function to simplify getting variables for aws parameter store from the DEMO.

define ssm-demo
$(shell aws --profile $(TRAVIS_PROFILE_DEMO) ssm get-parameters --names $1 --with-decryption --query Parameters[0].Value --output text)
endef

# We prepare variables for up in UPJSON and PRODUPJSON.
# These variables are comming from AWS Parameter Store
# - STAGE
# - DOMAIN
# - EMAIL_FOR_NOTIFICATION_GENERIC
# - PRIVATE_SUBNET_1
# - PRIVATE_SUBNET_2
# - PRIVATE_SUBNET_3
# - DEFAULT_SECURITY_GROUP
# - LAMBDA_TO_RDS_SECURITY_GROUP

UPJSON = '.profile |= "$(TRAVIS_PROFILE_DEV)" \
		  |.stages.production |= (.domain = "invite.$(call ssm,STAGE).$(call ssm,DOMAIN)" | .zone = "$(call ssm,STAGE).$(call ssm,DOMAIN)") \
		  | .actions[0].emails |= ["invite+$(call ssm,EMAIL_FOR_NOTIFICATION_GENERIC)"] \
		  | .lambda.vpc.subnets |= [ "$(call ssm,PRIVATE_SUBNET_1)", "$(call ssm,PRIVATE_SUBNET_2)", "$(call ssm,PRIVATE_SUBNET_3)" ] \
		  | .lambda.vpc.security_groups |= [ "$(call ssm,DEFAULT_SECURITY_GROUP)", "$(call ssm,LAMBDA_TO_RDS_SECURITY_GROUP)" ]'

#UPJSON for Production

PRODUPJSON = '.profile |= "$(TRAVIS_PROFILE_PROD)" \
		  |.stages.production |= (.domain = "invite.$(call ssm-prod,DOMAIN)" | .zone = "$(call ssm-prod,DOMAIN)") \
		  | .actions[0].emails |= ["invite+$(call ssm-prod,EMAIL_FOR_NOTIFICATION_GENERIC)"] \
		  | .lambda.vpc.subnets |= [ "$(call ssm-prod,PRIVATE_SUBNET_1)", "$(call ssm-prod,PRIVATE_SUBNET_2)", "$(call ssm-prod,PRIVATE_SUBNET_3)" ] \
		  | .lambda.vpc.security_groups |= [ "$(call ssm-prod,DEFAULT_SECURITY_GROUP)", "$(call ssm-prod,LAMBDA_TO_RDS_SECURITY_GROUP)" ]'

#UPJSON for Demo

DEMOUPJSON = '.profile |= "$(TRAVIS_PROFILE_DEMO)" \
		  |.stages.production |= (.domain = "invite.$(call ssm-demo,STAGE).$(call ssm-demo,DOMAIN)" | .zone = "$(call ssm-demo,STAGE).$(call ssm-demo,DOMAIN)") \
		  | .actions[0].emails |= ["invite+$(call ssm-demo,EMAIL_FOR_NOTIFICATION_GENERIC)"] \
		  | .lambda.vpc.subnets |= [ "$(call ssm-demo,PRIVATE_SUBNET_1)", "$(call ssm-demo,PRIVATE_SUBNET_2)", "$(call ssm-demo,PRIVATE_SUBNET_3)" ] \
		  | .lambda.vpc.security_groups |= [ "$(call ssm-demo,DEFAULT_SECURITY_GROUP)", "$(call ssm-demo,LAMBDA_TO_RDS_SECURITY_GROUP)" ]'

# We have everything, we can run up now.

dev:
	# add more info to facilitate debugging
	# START this is `dev` in Makefile
	# The current TRAVIS_PROFILE is: 
	echo $(TRAVIS_PROFILE)
	# The profile we will use for deployment is
	echo $(TRAVIS_PROFILE_DEV)
	# We replace the relevant variable in the up.json file
	# We use the template defined in up.json.in for that
	jq $(UPJSON) up.json.in > up.json
	up deploy production
	# END this is dev in Makefile

prod:
	# add more info to facilitate debugging
	# START this is `prod` in Makefile
	# The current TRAVIS_PROFILE is: 
	echo $(TRAVIS_PROFILE)
	# The profile we will use for deployment is
	echo $(TRAVIS_PROFILE_PROD)
	@echo $$AWS_ACCESS_KEY_ID
	# We replace the relevant variable in the up.json file
	# We use the template defined in up.json.in for that
	jq $(PRODUPJSON) up.json.in > up.json
	up deploy production
	# END this is `prod` in Makefile

demo:
	# add more info to facilitate debugging
	# START this is `demo` in Makefile
	# The current TRAVIS_PROFILE is: 
	echo $(TRAVIS_PROFILE)
	# The profile we will use for deployment is
	echo $(TRAVIS_PROFILE_DEMO)
	@echo $$AWS_ACCESS_KEY_ID
	# We replace the relevant variable in the up.json file
	# We use the template defined in up.json.in for that
	jq $(DEMOUPJSON) up.json.in > up.json
	up deploy production
	# END this is demo in Makefile

testdev:
	curl -H "Authorization: Bearer $(shell aws --profile $(TRAVIS_PROFILE)-dev ssm get-parameters --names API_ACCESS_TOKEN --with-decryption --query Parameters[0].Value --output text)" https://invite.$(call ssm,STAGE).$(call ssm,DOMAIN)/metrics

testdemo:	
	curl -H "Authorization: Bearer $(shell aws --profile $(TRAVIS_PROFILE) ssm get-parameters --names $(API_ACCESS_TOKEN) --with-decryption --query Parameters[0].Value --output text)" https://invite.$(call ssm,STAGE).$(call ssm,DOMAIN)/metrics	

testprod:	
	curl -H "Authorization: Bearer $(shell aws --profile $(TRAVIS_PROFILE) ssm get-parameters --names $(API_ACCESS_TOKEN) --with-decryption --query Parameters[0].Value --output text)" https://invite.$(call ssm,DOMAIN)/metrics	

testping:	
	curl -i -H "Authorization: Bearer $(shell aws --profile $(TRAVIS_PROFILE) ssm get-parameters --names $(API_ACCESS_TOKEN) --with-decryption --query Parameters[0].Value --output text)" https://invite.$(ZONE)/health_check 
