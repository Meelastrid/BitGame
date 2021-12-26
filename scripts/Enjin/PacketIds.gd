class_name PacketIds

# Client sends HANDSHAKE packet to initiate authentication process.
# Client sends HANDSHAKE packet to initiate authentication process.
# Player sends SEND_TOKEN packet to inform the server
# to send a token to the clients wallet.
enum { HANDSHAKE, PLAYER_AUTH, SEND_TOKEN }
