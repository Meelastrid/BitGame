extends Node2D
signal player_fetched
signal player_loaded
signal show_loading
signal show_name_input
signal show_qr

# Constants
const DEFAULT_SETTINGS: Dictionary = {
    "connection": {"host": "kovan.cloud.enjin.io", "port": 443}, "player": {"name": ""}
}
const SETTINGS_FILE_NAME: String = "client.cfg"

# Fields
var player = {"crowns": null, "keys": null, "health_shards": null, "coins": null, "ether": null}
var _settings: PlatformSettings
var _client: WebSocketClient
var _tp_client: TrustedPlatformClient
var _app_id: int
var _tokens
var _identity: Dictionary

# Callbacks
var _fetch_player_data_callback: EnjinCallback
var _unlink_player_callback: EnjinCallback


func _init():
    _settings = PlatformSettings.new(DEFAULT_SETTINGS, SETTINGS_FILE_NAME)
    _client = WebSocketClient.new()
    _tp_client = TrustedPlatformClient.new()
    _app_id = 0
    _fetch_player_data_callback = EnjinCallback.new(self, "_fetch_player_data")
    _unlink_player_callback = EnjinCallback.new(self, "_unlink_player")

    _settings.save()
    _settings.load()

    var _err_connection_established = _client.connect(
        "connection_established", self, "_connection_established"
    )
    var _err_connection_error = _client.connect("connection_error", self, "_connection_error")
    var _err_data_received = _client.connect("data_received", self, "_data_received")


func _ready():
    # Check if the settings have been configured.
    if ! _settings_valid():
        # If not then quit.
        get_tree().quit()
    emit_signal("show_loading")


func connect_to_server():
    # Initiate connection to server.
    var _err_client_connect = _client.connect_to_url(
        "%s:%d" % [_settings.data().connection.host, _settings.data().connection.port]
    )


func _process(_delta):
    # Check if connected to the server and poll for packet data if true.
    if _client.get_connection_status() != WebSocketClient.CONNECTION_DISCONNECTED:
        _client.poll()


func _connection_established(_protocol):
    init_handshake()


func _connection_error():
    print("Enjin: Connection Error")


func _data_received():
    print("Data received from server.")
    var peer = _client.get_peer(1)
    var raw_packet = peer.get_packet()
    if not peer.was_string_packet():
        return
    # Decode the received packet.
    var packet = WebSocketHelper.decode_json(raw_packet)
    if packet.id == PacketIds.PLAYER_AUTH:
        # Authenticate the client.
        handle_auth(packet)


func _settings_valid() -> bool:
    var __settings = _settings.data()
    return true


func handle_auth(packet):
    var session = packet.session
    _app_id = packet.app_id
    _tokens = packet.tokens
    # Authenticate the TrustedPlatformClient with the session token.
    _tp_client.get_state().auth_user(session.accessToken)
    if _tp_client.get_state().is_authed():
        print("Player client authenticated!")
        # Fetch player's data.
        fetch_player_data()
    else:
        print("Unable to authenticate player client.")


func fetch_player_data():
    var input = GetUserInput.new()
    # Create udata and assign callback.
    var udata = {"callback": _fetch_player_data_callback}
    # Return result for authenticated player.
    input.me(true)
    # Include player's identities.
    input.user_i.with_identities(true)
    # Include identity linking qr codes.
    input.identity_i.with_linking_code_qr(true)
    # Include identity wallets.
    input.identity_i.with_wallet(true)
    # Send get user request.
    _tp_client.user_service().get_user(input, udata)


func load_identity():
    var linking_code = _identity.linkingCodeQr
    if linking_code and ! linking_code.empty():
        # Download and display the QR code to the player.
        download_and_show_qr_code(linking_code)
        return

    # Get the wallet from the identity.
    var wallet = _identity.wallet
    if ! wallet:
        return

    # Get the balances from the wallet.
    var balances = wallet.balances

    # Iterate over balances and update game state.
    for bal in balances:
        # Check if player has the crown token.
        if bal.id == _tokens.crown.id and bal.value > 0:
            player['crowns'] = bal.value
        # Check if the player has the key token.
        elif bal.id == _tokens.key.id and bal.value > 0:
            player['keys'] = bal.value
        # Check if the player has the health upgrade token.
        elif bal.id == _tokens.health_upgrade.id and bal.value > 0:
            player['health_shards'] = bal.value
        # Check if player has any coin tokens.
        elif bal.id == _tokens.coin.id:
            player['coins'] = bal.value

    emit_signal("player_loaded")


func get_identity(identities):
    for identity in identities:
        var app_id = int(identity.appId)
        if app_id == _app_id:
            return identity
    return null


func download_and_show_qr_code(url: String):
    # Create and add new HTTPRequest to the scene.
    var http_request = HTTPRequest.new()
    add_child(http_request)
    # Connect request complete signal.
    http_request.connect("request_completed", self, "_qr_code_request_complete")
    # Send request
    var http_error = http_request.request(url)
    if http_error != OK:
        print("An error occurred in the HTTP request.")


func init_handshake():
    var settings = _settings.data()

    if settings.player.name.empty():
        emit_signal("show_name_input")
    else:
        emit_signal("show_loading")
        # Start authentication process by handshaking with server.
        handshake()


func handshake():
    var packet = {"id": PacketIds.HANDSHAKE, "name": _settings.data().player.name}
    WebSocketHelper.send_packet(_client, packet, 1, WebSocketPeer.WRITE_MODE_TEXT)


func send_token(name: String, amount: int):
    var packet = {
        "id": PacketIds.SEND_TOKEN,
        "token": _tokens[name].id,
        "amount": amount,
        "recipient_wallet": _identity.wallet.ethAddress
    }
    WebSocketHelper.send_packet(_client, packet, 1, WebSocketPeer.WRITE_MODE_TEXT)


func exit_entered(_body):
    # Send collected coins to the player's wallet.
    send_token("coin", player.coins)
    $"../Timer".set_wait_time(.5)
    $"../Timer".start()
    yield($"../Timer", "timeout")


func coin_grabbed(_body):
    send_token("coin", 1)


func key_grabbed(_body):
    send_token("key", 1)


func crown_grabbed(_body):
    send_token("crown", 1)


func _fetch_player_data(udata: Dictionary):
    var gql = udata.gql
    if gql.has_errors():
        print("Errors: %s" % PoolStringArray(udata.gql.get_errors()).join(","))
    elif gql.has_result():
        # Get the identity for the configured app.
        _identity = get_identity(gql.get_result().identities)

        if _identity == null:
            get_tree().quit()

        var linking_code = _identity.linkingCodeQr
        if linking_code and ! linking_code.empty():
            # Download and display the QR code to the player.
            download_and_show_qr_code(linking_code)
            return

        emit_signal("player_fetched")


func _qr_code_request_complete(_result, _response_code, _headers, body):
    # Create image from body
    var image = Image.new()
    var image_error = image.load_png_from_buffer(body)
    if image_error != OK:
        print("Unable to load qr code from url.")

    emit_signal("show_qr", image)


func health_upgrade_grabbed(_body):
    send_token("health_upgrade", 1)


func unlink_player():
    print("Unlinking identity: %s" % _identity)
    if not _identity:
        return
    var id = _identity.id
    if ! id:
        return

    var input = UnlinkIdentityInput.new()
    var udata = {"callback": _unlink_player_callback}
    input.id(id)
    # Requests new QR code url.
    input.identity_i.with_linking_code_qr(true)
    _tp_client.wallet_service().unlink_identity(input, udata)


func _unlink_player(udata: Dictionary):
    var gql: EnjinGraphqlResponse = udata.gql
    if gql.has_errors():
        print("Unlinking player failed: qql errors")
    elif gql.has_result():
        var result: Dictionary = gql.get_result()
        # Gets the new QR code image
        download_and_show_qr_code(result.linkingCodeQr)


func clear_name():
    _settings.data().player.name = ""
    _settings.save(true)
    _settings.load()
    print("Cleared name, current settings: %s" % _settings.data())


func update_name(name: String = "") -> bool:
    if name.empty() or name == _settings.data().player.name:
        return false

    # Checks if name contains characters other than numbers or letters
    var characters = name.to_ascii()
    for i in range(0, len(characters)):
        var ch = characters[i]
        #       [0,...,9]                  [A,...,Z]                  [a,...,z]
        if not ((ch >= 48 and ch <= 57) or (ch >= 65 and ch <= 90) or (ch >= 97 and ch <= 122)):
            return false
    print('Updating player name: %s' % name)
    _settings.data().player.name = name
    _settings.save(true)
    _settings.load()
    print("Updated name %s , current settings: %s" % [name, _settings.data()])
    return true


func player_name() -> String:
    return _settings.data().player.name
