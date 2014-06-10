# src/server/user_controller.coffee

# hook
Accounts.onCreateUser (options, user) ->
  if user.services.facebook and user.services.facebook.email
    user.emails = [] unless user.emails
    user.emails.push
      address: user.services.facebook.email
      verified: false

  user.profile = options.profile
  user.online = true

  user

Accounts.onLogin (options) ->
  Meteor.users.update options.user._id, $set: { online: true }


# methods
Meteor.methods
  logoutUser: (id) ->
    Meteor.users.update id, $set: { online: false }

  notifyUserOnChallenge: (mail, challengerId) ->
    challenger = Meteor.users.findOne challengerId
    now = new Date()
    quiz = Quizzes.findOne
      startDate: {$lt: now}
      endDate:   {$gt: now}
    , {limit: 1}

    this.unblock()

    html = Handlebars.templates['invite']
      name: challenger.profile.name
      gamename: CONFIG.SITE_TITLE
      quizname: quiz.name
      rootlink: CONFIG.SITE_URL
      mail: CONFIG.SITE_EMAIL

    Meteor.call 'sendEmail',
      to: mail
      subject: "Du er blevet udfordret!"
      html: html
    , (err) ->
      if err?
        console.log "Error notify mail"
      else
        console.log "Confirm email sent"

  notifyUserOnAnswer: (mail, challengeeId) ->
    challengee = Meteor.users.findOne challengeeId

    this.unblock()

    html = Handlebars.templates['answered']
      name: challengee.profile.name
      gamename: CONFIG.SITE_TITLE
      rootlink: CONFIG.SITE_URL
      mail: CONFIG.SITE_EMAIL

    Meteor.call 'sendEmail',
      to: mail
      subject: "Din udfordring er blevet svaret!"
      html: html
    , (err) ->
      if err?
        console.log "Error answer mail"
      else
        console.log "Confirm email sent"
