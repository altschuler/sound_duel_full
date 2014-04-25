# app/server/player_controller.coffee

# methods
Meteor.methods
  newPlayer: (username) ->
    # username not set
    unless username
      throw new Meteor.Error 409, 'Username not set'
    # username alretaken
    else if Meteor.users.find({ username: username }).count() > 0
      throw new Meteor.Error 409, 'Username taken'

    Meteor.users.insert
      username: username
      profile:
        online: true
        highscoreIds: []


  updatePlayerUsername: (id, username) ->
    # username not set
    unless username
      throw new Meteor.Error 409, 'Username not set'
    # username alretaken
    else if Meteor.users.find( username: username ).count() > 0
      throw new Meteor.Error 409, 'Username taken'

    Meteor.users.update id, $set: { username: username }
