# app/server/main.coffee

fs = Npm.require 'fs'

# methods

refreshDb = ->
  console.log "Refreshing db.."

  # clear database
  # TODO: only for development
  Meteor.users.remove({})
  Games.remove({})
  Challenges.remove({})
  Highscores.remove({})
  Questions.remove({})
  Sounds.remove({})

  # get audiofiles from /public
  audioFiles = fs.readdirSync(CONFIG.ASSETS_DIR).filter (file) ->
    ~file.indexOf('.mp3')

  # parse questions from sample file
  sampleQuestions = JSON.parse(Assets.getText CONFIG.SAMPLE_DATA)

  # populate database
  for sample in sampleQuestions
    questionId = Questions.insert(sample)

    # find associated segments
    segments = audioFiles.filter (file) ->
      ~file.indexOf(sample.soundfilePrefix)

    soundId = Sounds.insert segments: segments

    Questions.update questionId, $set: { soundId: soundId }

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
      $set: { 'profile.online': false }

  , CONFIG.ONLINE_TRESHOLD)


# initialize

Meteor.startup ->
  refreshDb()

  keepaliveLoop()
