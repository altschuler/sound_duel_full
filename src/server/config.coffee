## Rename this file to `config.coffee` and insert your
## facebook app-id and secret

## Configure facebook

# 1. Remove configuration entry in case service is already configured
ServiceConfiguration.configurations.remove({
  service: 'facebook'
})

# 2. Insert the credentials into the database
ServiceConfiguration.configurations.insert({
  service: 'facebook'
  # appId:   '<FACEBOOK-APP-ID>'
  # secret:  '<FACEBOOK-APP-SECRET>'
})
