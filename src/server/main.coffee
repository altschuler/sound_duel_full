# src/server/main.coffee

fs = Npm.require 'fs'
Future = Npm.require 'fibers/future'
probe = Meteor.require 'node-ffprobe'

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
  sampleQuizzes = EJSON.parse(Assets.getText CONFIG.DATA_PATH)

  # populate database
  for quiz in sampleQuizzes

    # Insert questions from quiz as separate question objects in database
    questionIds = []

    for question in quiz.questions

      # find associated segment
      segment = audioFiles.filter( (file) ->
        ~file.indexOf(question.soundfilePrefix)
      ).pop()

      # get duration of segment
      fut = new Future()
      probe "#{CONFIG.ASSETS_DIR}/#{segment}", (err, data) ->
        if err?
          console.log err
        else
          fut['return'] data.format.duration

      duration = fut.wait()

      # insert sound document
      soundId = Sounds.insert
        segment: segment
        duration: duration
      question.soundId = soundId

      # insert question into databse
      questionId = Questions.insert question
      questionIds.push questionId

    # Replace the 'questions' property with the property 'questionIds' that
    # references the questions ID in the MongoDB
    delete quiz.questions
    quiz.questionIds = questionIds
    quiz.pointsPerQuestion = CONFIG.POINTS_PER_QUESTION
    questionId = Quizzes.insert(quiz)


  # print some info
  console.log "#Questions: #{Questions.find().count()}"
  console.log "#Sounds: #{audioFiles.length}"


Meteor.methods
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
