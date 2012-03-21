unreadMessageCount = 0

setDocumentTitle = ->
  title = 'CoffeeShop'
  if unreadMessageCount > 0
    title += " (#{unreadMessageCount})"
  document.title = title

windowFocused = ->
  this.isActive = true
  unreadMessageCount = 0
  setDocumentTitle()

$(window).focus ->
  windowFocused()

$(window).blur ->
  this.isActive = false

initialize = ->
  window.isActive = true

  $command = $('#command')
  $command.focus()
  $command.on 'keyup', (event) ->
    return if event.keyCode != 13
    $this = $(this)
    if $this.val() != ''
      socket.emit('command', $this.val())
      $this.val('')

socket = io.connect('http://#{window.location.host}')

socket.on 'init', (data) ->
  userName = data.self
  for user in data.users
    addUser(user)
  for message in data.messages
    addMessage(message.user, message.text)

socket.on 'add_user', (user) ->
  addUser(user)

socket.on 'remove_user', (user) ->
  $('#users #'+user).remove()

socket.on 'add_message', (message) ->
  addMessage(message.user, message.text)

addUser = (user) ->
  $user = $('<div />')
  $user.attr('id', user)
  $user.html(user)
  $('#users').append($user)

addMessage = (user, message) ->
  if this.isActive == false
    unreadMessageCount += 1
    setDocumentTitle()

  $msg = $('<tr />')
  $msg.html("<td class='username'>#{user}</td><td class='message'>#{message}</td>")
  $('#messages').append($msg)

$ -> initialize()
