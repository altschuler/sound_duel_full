# src/server/game_controller.coffee

# helpers

findQuestions = ->
  # TODO: avoid getting the same questions
  Questions.find({},
    limit: CONFIG.NUMBER_OF_QUESTION
    # limit: 2 # For development
    fields: { _id: 1 }
  ).fetch()

insertGame = (playerId) ->
  # Find the quiz of the day
  now = new Date()
  quiz_of_the_day = Quizzes.find(
    startDate: {$lt: now}
    endDate:   {$gt: now}
  ,
    limit: 1
    sort: ['endDate', 'desc'] # Grab the quiz that ends the soonest
  )

  if quiz_of_the_day.count() is 0
    throw new Meteor.Error 'Quiz of the day not found'

  quiz_of_the_day = quiz_of_the_day.fetch()[0]

  Games.insert
    playerId:          playerId
    quizId:            quiz_of_the_day._id
    pointsPerQuestion: CONFIG.POINTS_PER_QUESTION
    state:             'init'
    currentQuestion:   0
    answers:           []

insertChallenge = ({
  playerId,
  challengeeId,
  challengeeEmail,
  gameId,
  challengeeGameId })->

  Challenges.insert
    challengerId:     playerId
    challengeeId:     challengeeId
    challengeeEmail:  challengeeEmail
    challengerGameId: gameId
    challengeeGameId: challengeeGameId
    notified:         false

notifyChallenge = (gameId)->

  challenge = Challenges.findOne { challengerGameId: gameId }

  #if game is by challenger and invite by email
  if challenge and challenge.challengeeEmail
    #send invite mail to challengee when challenger has played
    Meteor.call 'notifyUserOnChallenge',
      challenge.challengeeEmail, Meteor.userId()
    return

  challenge = Challenges.findOne { challengeeGameId: gameId }

  #if game is by challengee and invited by email
  if challenge and challenge.challengeeEmail
    #send info mail to challenger when challengee has played
    challenger = Meteor.users.findOne challenge.challengerId
    Meteor.call 'notifyUserOnAnswer',
      challenger.emails[0].address, Meteor.userId()
    return

# methods

Meteor.methods
  newGame: (playerId, {challengeeId, acceptChallengeId, challengeeEmail}) ->
    unless Meteor.users.find(playerId).count() is 1
      throw new Meteor.Error 'player not found'
    # cannot challenge and answer challenge at the same time
    if (challengeeId and acceptChallengeId) or
    (challengeeEmail and acceptChallengeId)
      throw new Meteor.Error 'cannot challenge and accept
       challenge at the same time'
    if challengeeId and challengeeEmail
      throw new Meteor.Error 'cannot challenge both player and email'

    # if accepting challenge, find the game
    if acceptChallengeId
      gameId = Challenges.findOne(acceptChallengeId).challengeeGameId
      game = Games.findOne gameId
      #if invited via email, playerId is not set
      if not game.playerId?
        Games.update game._id, $set: { playerId: playerId }
    # else, create new game
    else
      gameId = insertGame(playerId)
      challengeId = null

    # if challenging, create new game for challengee
    if challengeeId or challengeeEmail

      if playerId is challengeeId
        throw new Meteor.Error 'cannot challenge yourself'

      challengee = Meteor.users.findOne {
        emails: { $elemMatch: { address: challengeeEmail } }
      }
      if challengee and playerId is challengee._id
        throw new Meteor.Error 'cannot challenge yourself'

      challengeeGameId = insertGame(challengeeId)

      challengeId = insertChallenge
        playerId: playerId
        challengeeId: challengeeId
        challengeeEmail: challengeeEmail
        gameId: gameId
        challengeeGameId: challengeeGameId

    # return game id and challenge id
    {
      gameId:      gameId
      challengeId: challengeId
    }

  endGame: (currentGameId) ->
    game = Games.findOne currentGameId
    throw new Meteor.Error 'game not found' unless game?

    # calculate score
    score = 0
    correctAnswers = 0
    for a in game.answers
      q = Questions.findOne a.questionId
      if a.answer is q.correctAnswer
        correctAnswers++
        score += a.points

    notifyChallenge currentGameId

    # mark game as finished
    Games.update game._id,
      $set: {
        state: 'finished'
        score: score
        correctAnswers: correctAnswers
      }

