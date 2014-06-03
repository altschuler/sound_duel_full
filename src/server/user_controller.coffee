# app/server/user_controller.coffee

# hook
Accounts.onCreateUser (options, user) ->
  if user.services.facebook and user.services.facebook.email
    user.emails = [] unless user.emails
    user.emails.push
      address: user.services.facebook.email
      verified: false

  user.profile = options.profile
  user.online = true;

  user


# methods
Meteor.methods
  logoutUser: (id) ->
    Meteor.users.update id, $set: { online: false }
