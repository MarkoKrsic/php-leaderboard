#HTTP.gd - Written by Marko Krsic - MIT License - CC0

extends Node
onready var player = get_tree().get_current_scene().find_node("Player")
onready var level = get_tree().get_current_scene().find_node("Level")
var contest
var SecretKey = "***SECRETKEY***"
var use_ssl=true
var score
var playername
var highgame
var hashed1
var hashed2
var query
var suburl
var rankurl
var rankingurl
var ranking
var rank5
var submitted = false

#HTTPRequest nodes
onready var submit = $SUBMIT
onready var rank = $GETRANK
onready var ranks = $GETTOP5

func _ready():
	score = player.highscore
	playername = str(player.playerID)
	#SAMPLE HASH - YOU MUST MATCH THE CONTENTS OF THE EXPECTED HASH IN THE PHP FILE FOR THIS TO WORK. 
	hashedevent = ("EVENTHASH"+SecretKey).md5_text())
	query = "" #<-----GODOT BUG REQUIRES EMPTY QUERY AND CONTENTS AS PART OF URL . SEE GODOT 3.3 DOCS.
	suburl = ("https://example.com/foo.php?name="+playername+"&score="+str(score)+"&synca="+str(hashed1))
	rankurl = ("https://example.com/foo.php?name="+playername+"&score="+str(score)+"&syncb="+str(hashed1))
	rankingurl = ("https://example.com/foo.php?name="+playername+"&score="+str(score)+"&updatekey="+str(hashed1))

#SUBMITS SCORE TO LEADERBOARD - UPDATES IF NAME MATCHES. You need to add logic to your end of the player or level script to only submit highscores.
# I.e. score = player.highscore will only submit the highscore if you have matching logic in the player node script, 
# if the logic is missing it will overwrite with whatever score you submit, lower or higher.

func _getscore():
	submit.request(suburl, [] ,use_ssl, HTTPClient.METHOD_POST, query)
	print(suburl)

#Button signal
func _on_SubmitScore_pressed():
	if player.playerID == "ANON":
		level._RankError()
	else:
		_getscore()
# Get's rank based on PHP script only, function must be present and sync request must match (i.e synca, syncb, updatekey)

func _getrank():
	rank.request(rankurl, [] ,use_ssl, HTTPClient.METHOD_GET, query)
	#SANITY CHECK
	print(rankurl)

func _on_SUBMIT_request_completed(result, response_code, headers, body):
    #SANITY CHECK
	print (body.get_string_from_utf8())
	if response_code == 200:
		submitted == true
		_getrank()
	else:
		level._scoreError()
		pass

func _on_GETRANK_request_completed(result, response_code, headers, body):
	 ranking = (body.get_string_from_utf8())
	 level._drawResults() # <--- make your own function in a seperate script that does what you want to display the result.

# Get's TOP 5 rank based on PHP script only, function must be present and sync request must match (i.e synca, syncb, updatekey)
func _gettop5():
	ranks.request(rankingurl, [] ,use_ssl, HTTPClient.METHOD_GET, query)

func _on_GETTOP5_request_completed(result, response_code, headers, body):
	
    #SANITY CHECK
    print(response_code)

# PHP will send over a formatted body, make it into a string.	
    rank5 = (body.get_string_from_utf8())
	
    #SANITY CHECK
    print(body.get_string_from_utf8())
	print(rank5)
	
    if response_code == 200:
        level._drawResults() # <--- make your own function in a seperate script that does what you want to display the result.

func _on_Leaderboard_pressed():
	_gettop5()



