
# From: http://stackoverflow.com/a/9255507/118608
Template.question.startQuestion = ->

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
    ->
      # Hide countdown, show questions
      $(this).hide()
      $('#alternative-container').show()

      # Enable answer buttons
      $('.alternative').prop 'disabled', false
      Template.assets.playAsset()
  )
