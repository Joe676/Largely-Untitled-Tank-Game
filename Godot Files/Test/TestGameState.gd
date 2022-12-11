extends GutTest

func test_ready():
    #GameState is AutoLoaded - should be in the tree before running this test
    #Arrange
    var game_tree = get_tree()
    
    #Assert
    assert_connected(game_tree, GameState, "network_peer_connected", "_player_connected")
    assert_connected(game_tree, GameState, "network_peer_disconnected", "_player_disconnected")

func test_start_game():
    #Arrange
    Network.create_server()
    watch_signals(GameState)

    #Act
    GameState.start_game()

    #Assert
    assert_true(get_tree().get_network_peer().refuse_new_connections, "Should refuse new connections after game starts.")
    assert_eq(GameState.state, GameState.State.IN_GAME, "Should change state on game start.")
    assert_signal_emitted(GameState, "start_game", "Should emit start_game signal")

# func test_finish_round():
#     #Act
#     GameState.finish_round()
#     #Assert
#     assert_eq(GameState.state, GameState.State.GAME_STOPPED, "Finishing round should stop game.")

    
# func test_start_round():
#     #Arrange
#     Network.create_server()
#     watch_signals(GameState)

#     #Act
#     GameState.start_round()

#     #Assert
#     assert_eq(GameState.state, GameState.State.IN_GAME, "Should change state on round start.")
#     assert_signal_emitted(GameState, "start_round", "Should emit start_round signal")
