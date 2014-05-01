# app/server/player_controller.coffee

# methods
Meteor.methods
  newPlayer: (username) ->
    # username not set
    unless username
      throw new Meteor.Error 409, 'Username not set.'
    # username alretaken
    else if Meteor.users.find({ username: username }).count() > 0
      throw new Meteor.Error 409, 'Username already taken'

    Meteor.users.insert
      username: username
      profile:
        online: true
        highscoreIds: []


  updatePlayerUsername: (id, username) ->
    # username not set
    unless username
      throw new Meteor.Error 409, 'Username not set.'
    # username already taken
    else if Meteor.users.find( username: username ).count() > 0
      throw new Meteor.Error 409, 'Username already taken.'

    Meteor.users.update id, $set: { username: username }


  logoutPlayer: (id) ->
    Meteor.users.update id, $set: { 'profile.online': false }
