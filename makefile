ALLOWED_ENVS := dev qa demo prod
.PHONY: changeset deploy  describe events delete

APP_NAME =cfn-project
ASSETS_BUCKET=assets-bucket-jenkins-onboarding

# Require ENV
ifndef ENV
$(error ENV is not set. Please specify a environment name, e.g., 'make <command> ENV=dev')
endif
ifeq ($(filter $(ENV),$(ALLOWED_ENVS)),)
$(error ENV must be one of the following values: $(ALLOWED_ENVS))
endif

changeset:
	aws cloudformation package --template-file template.yml --s3-bucket ${ENV}-${ASSETS_BUCKET} --s3-prefix ${ENV}-${APP_NAME} --output-template-file packaged-template.yml
	aws cloudformation deploy --template-file packaged-template.yml --stack-name ${ENV}-${APP_NAME} --parameter-overrides Stage=${ENV} ProjectName=${APP_NAME} --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM --no-execute-changeset
deploy:
	aws cloudformation package --template-file template.yml --s3-bucket ${ENV}-${ASSETS_BUCKET} --s3-prefix ${ENV}-${APP_NAME} --output-template-file packaged-template.yml
	aws cloudformation deploy --template-file packaged-template.yml --stack-name ${ENV}-${APP_NAME} --parameter-overrides Stage=${ENV} ProjectName=${APP_NAME} --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM
describe:
	aws cloudformation describe-stacks --stack-name ${ENV}-${APP_NAME} --color on
events:
	aws cloudformation describe-stack-events --stack-name ${ENV}-${APP_NAME}
delete:
	aws cloudformation delete-stack --stack-name ${ENV}-${APP_NAME}
