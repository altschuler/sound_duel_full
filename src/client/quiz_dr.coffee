#!! This script controls the 3... 2... 1... Start!... animation before a
#!! question begins.
#!!
#!! It removes the countdown and reinserts it in order to restart the animation
#!! and ensure that the animation is not playing while the element is hidden
#!! (instead of just hiding it with `display: none`, which doesn't stop the
#!!  animation)


# From: http://stackoverflow.com/a/9255507/118608
Template.question.startQuestion = ->
  console.log 'Template.question.startQuestion() called'

  # Reset progress bar
  Session.set 'gameProgress', 100
  $('#asset-bar')
    .attr('style', "width: 100%")
    .text Math.floor(currentQuiz().pointsPerQuestion)

  # Hide questions
  $('#alternative-container').hide()

  # Remove countdown
  $countdown = $(".sound-duel-countdown")
  $insertion_point = $countdown.prev()
  $countdown.remove()
  $countdown.removeClass('smaller')

  # **iOS**: Ensure that sound is started
  is_iOS =
    if navigator.userAgent.match /(iPad|iPhone|iPod)/g
      true
    else
      false
  is_iOS = true

  if is_iOS and Session.get('currentQuestion') == 0

    $button = $('<button>Start</button>')
    $button.click ->

      # Play silent audio clip top obtain the right from iOS to play audio
      Template.assets.playSilence()

      # Remove button
      @remove()

      __startQuestion($insertion_point, $countdown)

    # Insert button
    $insertion_point.after($button)
  else
    Template.assets.loadSound()

    __startQuestion($insertion_point, $countdown)

  # Skip animation if spacebar is pressed
  $('body').keyup( (e) ->
    if e.keyCode == 32
      # user has pressed space
      Template.question.showQuestion()
  )

__startQuestion = ($insertion_point, $countdown) ->
  # Insert and show countdown
  $insertion_point.after($countdown)
  $countdown.show()

  # # Reset animation
  # countdown = $(".sound-duel-countdown")[0]
  # if countdown
  #   countdown.style.webkitAnimation = "none"
  #   countdown.style.MozAnimation    = "none"
  #   countdown.style.animation       = "none"
  #   setTimeout( ->
  #     countdown.style.webkitAnimation = ""
  #     countdown.style.MozAnimation    = ""
  #     countdown.style.animation       = ""
  #   , 10)

  # Setup variables
  i = 0
  texts = ['3', '2', '1', 'Start!']
  $('.sound-duel-countdown').text(texts[i])

  # Change text on every animation iteration
  $(".sound-duel-countdown").bind(
    "animationiteration webkitAnimationIteration oAnimationIteration
     MSAnimationIteration",
    ->
      console.log 'Animation iteration hit'
      i += 1
      $(this).text(texts[i])
      if texts[i].length > 2
        $(this).addClass('smaller')
      else
        $(this).removeClass('smaller')
  )

  # When the animation has ended show the questions and play the sound
  $(".sound-duel-countdown").bind(
    "animationend webkitAnimationEnd oAnimationEnd MSAnimationEnd", ->
      console.log 'Animation iteration hit'
      Template.question.showQuestion()
  )


Template.question.showQuestion = ->
  console.log('showQuestion called')
  # Hide countdown, show questions
  $('[data-sd-quiz-progressbar]').show()
  $(".sound-duel-countdown").hide()
  $('#alternative-container').show()

  # Enable answer buttons
  $('.alternative').prop 'disabled', false

  # Play sound
  Template.assets.playAsset()
