# src/server/main.coffee

fs = Npm.require 'fs'

# methods

refreshDb = ->
  console.log "Refreshing db.."

  # clear database
  # TODO: only for development
  ## Meteor.users.remove({})
  Games.remove({})
  Challenges.remove({})
  Quizzes.remove({})
  Questions.remove({})
  Sounds.remove({})

  # get audiofiles from /public
  audioFiles = fs.readdirSync(CONFIG.ASSETS_DIR).filter (file) ->
    ~file.indexOf('.mp3')

  # parse questions from sample file
  sampleQuizzes = EJSON.parse(Assets.getText CONFIG.SAMPLE_DATA)

  # populate database
  for quiz in sampleQuizzes

    # Insert questions from quiz as separate question objects in database
    questionIds = []
    for question in quiz.questions

      # find associated segments
      segments = audioFiles.filter (file) ->
        ~file.indexOf(question.soundfilePrefix)

      soundId = Sounds.insert segments: segments
      question.soundId = soundId

      # insert question into databse
      questionId = Questions.insert(question)
      questionIds.push(questionId)

    # Replace the 'questions' property with the property 'questionIds' that
    # references the questions ID in the MongoDB
    delete quiz.questions
    quiz.questionIds = questionIds
    quiz.pointsPerQuestion = CONFIG.POINTS_PER_QUESTION
    questionId = Quizzes.insert(quiz)


  # print some info
  console.log "#Questions: #{Questions.find().count()}"
  console.log "#Sounds: #{audioFiles.length}"

# update players to idle with keepalive
# and remove long idling players
keepaliveLoop = ->
  Meteor.setInterval( ->
    now = (new Date()).getTime()
    threshold = now - CONFIG.ONLINE_TRESHOLD

    # set players to idle
    Meteor.users.update lastKeepalive: { $lt: threshold },
      $set: { online: false }

  , CONFIG.ONLINE_TRESHOLD)


Meteor.methods
  keepalive: (playerId) ->
    Meteor.users.update playerId, $set:
      online: true
      lastKeepalive: (new Date()).getTime()

  sendEmail: (options) ->
    check([options.to, options.subject, options.html], [String])

    options.from = "#{CONFIG.SITE_TITLE} <#{CONFIG.SITE_EMAIL}>"

    # Let other method calls from the same client start running,
    # without waiting for the email sending to complete.
    this.unblock()

    Email.send options


# initialize

Meteor.startup ->
  refreshDb()
  keepaliveLoop()
