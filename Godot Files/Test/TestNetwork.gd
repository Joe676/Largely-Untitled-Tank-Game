extends GutTest

func after_each():
    get_tree().set_network_peer(null)

func test_ready():
    #Network is AutoLoaded - should be in the tree before running this test
    #Arrange
    var game_tree = get_tree()
    #Assert
    assert_not_null(Network, "Should have populated on start.")
    assert_true(Network.ip_address in IP.get_local_addresses(), "Should find an IP address.")
    assert_connected(game_tree, Network, "connected_to_server", "_connected_to_server")
    assert_connected(game_tree, Network, "server_disconnected", "_server_disconnected")
    assert_connected(game_tree, Network, "network_peer_connected", "_player_connected")
    assert_connected(game_tree, Network, "network_peer_disconnected", "_player_disconnected")
    assert_true(Network in game_tree.root.get_children(), "Should be in the tree.") 

func test_create_server():
    #Act
    Network.create_server()
    #Assert
    assert_true(get_tree().has_network_peer(), "Should have the network peer.")
    assert_true(get_tree().is_network_server(), "Should be the server.")

func test_join_server_failed():
    #Arrange
    var ip = "improper ip address"

    #Act
    var joined = Network.join_server(ip)

    #Assert
    assert_false(joined, "Should not find server")
    assert_false(get_tree().has_network_peer(), "Should not be networked after failure.")

func test_disconnect_from_network():
    #Arrange
    Network.create_server()

    #Act
    Network.disconnect_from_network()

    #Assert
    assert_false(get_tree().has_network_peer(), "Should not be networked after disconnecting.")
    assert_eq(Global.get_all_players().size(), 0, "Players should be cleared.")
    