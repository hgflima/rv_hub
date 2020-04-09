class MainAuthorizer < ApplicationAuthorizer
  authorizer(
    name: "RvHubCognito", # <= name is used as the "function" name
    identity_source: "Authorization", # maps to method.request.header.Authorization
    type: :cognito_user_pools,
    provider_arns: [
      "arn:aws:cognito-idp:us-east-1:#{Jets.aws.account}:userpool/us-east-1_3hyPC1KZi",
    ],
  )
  # no lambda function
end