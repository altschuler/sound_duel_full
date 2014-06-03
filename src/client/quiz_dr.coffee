# **iOS**: Ensure that sound is started
Template.question.ensurePlaying = ->
  setTimeout(Template.question.showQuestion, 4000)

# From: http://stackoverflow.com/a/9255507/118608
Template.question.startQuestion = ->
  console.log 'Template.question.startQuestion() called'

  # Skip animation if spacebar is pressed
  $('body').keyup( (e) ->
    if e.keyCode == 32
      # user has pressed space
      Template.question.showQuestion()
  )

  # Reset progress bar
  Session.set 'gameProgress', 100
  $('#asset-bar')
    .attr('style', "width: 100%")
    .text Math.floor(currentQuiz().pointsPerQuestion)

  # Show countdown, hide questions
  $('#alternative-container').hide()
  $(".sound-duel-countdown").show()

  # Reset animation
  countdown = $(".sound-duel-countdown")[0]
  if countdown
    countdown.style.webkitAnimation = "none"
    countdown.style.MozAnimation    = "none"
    countdown.style.animation       = "none"
    setTimeout( ->
      countdown.style.webkitAnimation = ""
      countdown.style.MozAnimation    = ""
      countdown.style.animation       = ""
    , 10)

  # Setup variables
  i = 0
  texts = ['3', '2', '1', 'Start!']
  $('.sound-duel-countdown').text(texts[i])

  # Change text on every animation iteration
  $(".sound-duel-countdown").bind(
    "animationiteration webkitAnimationIteration oAnimationIteration
     MSAnimationIteration",
    ->
      i += 1
      $(this).text(texts[i])
  )

  # When the animation has ended show the questions and play the sound
  $(".sound-duel-countdown").bind(
    "animationend webkitAnimationEnd oAnimationEnd MSAnimationEnd",
    -> Template.question.showQuestion()
  )


Template.question.showQuestion = ->
  # Hide countdown, show questions
  $('[data-sd-quiz-progressbar]').show()
  $(".sound-duel-countdown").hide()
  $('#alternative-container').show()

  # Enable answer buttons
  $('.alternative').prop 'disabled', false

  # Play sound
  Template.assets.playAsset()
