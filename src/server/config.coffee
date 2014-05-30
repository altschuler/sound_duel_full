
## Configure facebook

# 1. Remove configuration entry in case service is already configured
ServiceConfiguration.configurations.remove({
  service: 'facebook'
})

# 2. Insert the credentials into the database
ServiceConfiguration.configurations.insert({
  service: 'facebook'
  appId: '1485565445007266'
  secret: '1d2cd30b442adafde8f4319f99b1fc46'
})
