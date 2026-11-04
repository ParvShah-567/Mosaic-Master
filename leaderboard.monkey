Import mojo 
Import brl
Import tfont 
Import OS 
Global Assessment:Game_app

Function Main()
	Assessment = New Game_app
End 
'test score array for the ranking
Global PlayerScore:GameScore[5]'this hosuld match to the num of lines in rank.txt

Class Game_app Extends App
	Field menu:Image ' declares the menu image
	Field enterName:Image ' declares the entername image
	Field enterScore:Image ' declares the enterscore image
	Field leaderboard:Image ' declares the  leaderboard image
	Field name:String = "" ' declares the name string
	Field score:String = "" ' declares the score string
	' declares the gloabl variabeles needed for fonts and gamestate
	Global GameState:String  = "MENU" 
	Global NameFont:TFont ' inbuilt monkey X class
	Global RankFont:TFont 'used to handle fonts 
	
	Method OnCreate() ' initialises the variables, to data folder
		menu = LoadImage("menu.png") 
		enterName = LoadImage("enterName.png")
		enterScore = LoadImage("enterScore.png")
		leaderboard = LoadImage("leaderboard.png")
		NameFont = New TFont("Helvetica.ttf", 75,[255,255,255])' the 255 means all white, 0 means all black
		RankFont = New TFont("Helvetica.ttf", 50,[255,255,255]) ' there are 3, red, green, blue
		LoadRanking()'call the function to initialise the testscores array
	End 
	
	Method OnUpdate()
		Select GameState 
			Case "MENU" 
				If KeyHit(KEY_1) Then 'when 1 pressed, it allows user to 
					GameState = "NAME" ' enter their name
				Endif 
				
				If KeyHit(KEY_2) Then 'when 2 pressed, it allows user to 
					GameState = "CHECK LEADERBOARD" ' check the leaderboard
				Endif 
				
				If KeyHit(KEY_ESCAPE) Then ' when esc is pressed
					ExitApp(0) 				' user exits app
				Endif 
			
			Case "NAME" 
				If KeyHit(KEY_ESCAPE) Then ' press esc to esc game
					GameState = "MENU" 
				Endif 
				While name.Length < 16 'if name length is less than 16
					Local char = GetChar() 'get next char input
					If Not char Exit ' if there is no input then exit
					If char>=32 
						name += String.FromChar(char) 'add char to the name string
					Endif 
				End 
				If KeyHit(KEY_BACKSPACE) Then 'removes last char from name
					If (name.Length>0) Then name = name[0..name.Length-1] 
				Endif 
				If KeyHit(KEY_ENTER) Then 
					GameState = "ENTER NAME + SCORE" ' enter to progress the gamestate
				Endif 
			Case "ENTER NAME + SCORE" 
				If KeyHit(KEY_ESCAPE) Then GameState = "MENU" 'esc to return to menu
				If KeyHit(KEY_N) Then GameState = "NAME" ' N to change the name
				While score.Length<4 'while score length is less than 4 char
					Local char=GetChar() ' get next char input
					If Not char Exit ' if no input then exit
					If char>= 48 And char<= 57 
						score += String.FromChar(char) 'add char to score string
					Endif 
				End 
				If KeyHit (KEY_BACKSPACE) Then 'removes last char from name
					If (score.Length>0) Then score = score[0..score.Length-1]
				Endif  
				If KeyHit(KEY_ENTER) Then 
					writeNameAndScore(name,score)'function writes the name & score to score_file.txt 
					UpdateScore(name,Int(score)) 'function updates the leaderboard with new score
					name ="" 'clear name varibale
					score="" 'clear score variable
					'scores= bubbleSort(scores)
					GameState = "MENU" 'return to main menu
				Endif 
			Case "CHECK LEADERBOARD" 
				If KeyHit(KEY_ESCAPE) Then ' if ESC pressed
					GameState = "MENU"	' return to menu
				Endif				  
		End Select 
	End Method 
	
	
	Method OnRender() ' displays most of the content
		Select GameState 
			Case "MENU" 
				DrawImage menu, 0,0 'display the menu image 
			Case "NAME"
				Cls 0,0,0
				DrawImage enterName, 0,0 'display enterName image
				NameFont.DrawText(name, 120,190 ) ' x y coords to place the name
			Case "ENTER NAME + SCORE"
				Cls 0,0,0 
				DrawImage enterScore, 0,0'display enterScore image
				NameFont.DrawText(score,200,190) ' x y coords to place the score 
			Case "CHECK LEADERBOARD"
				Cls 0,0,0
				DrawImage leaderboard, 0,0 
				For Local rank=0 Until 5 'loop through top 5 ranks, made sure to keep same num as rank.txt file
					RankFont.DrawText(""+(rank+1)+") "+ PlayerScore[rank].name+": "+PlayerScore[rank].score,100,130+(rank*75))
				Next 							'disply the rank number, player name and score
		End Select  
	End Method 
' final end 
End 

Function bubbleSort:GameScore[](list:GameScore[])
	Local size:Int = list.Length	'length of list
	Local swapped:Bool = True	'to go into loop
	Local count:Int = 0	'number of passes
	
		While (count <= size-1) And (swapped = True)	'while not all players are checked
			swapped = False									'no swaps yet made
			For Local index = 0 Until (size-(count+1))		'goes through all players individually 
				If list[index].score < list[index+1].score Then	'checks if 1st score is less than 2nd score
					swapped = True								'then the swap takes place
					'player positions swapped if yes
					Local tempScore:Int = list[index].score	'to temporarily hold values of player name + score for swap
					Local tempName:String = list[index].name
					list[index].score = list[index+1].score		'swaps score
					list[index].name = list[index+1].name		'swaps name
					list[index+1].score = tempScore
					list[index+1].name = tempName
				Endif
			Next
			count += 1 ' moves onto next index in array
		End
	Return list
End
 

Function writeNameAndScore:Int(name:String, score:String)'function writes name and score to score_file
	Local score_file:FileStream
					' this is the file path to the score file txt, which gets appended
	score_file = FileStream.Open("C:\Users\parvs\OneDrive\Desktop\my puzzle game\leaderboard\leaderboard\leaderboard\leaderboard.data\score_File.txt","a")
	score_file.WriteString(score+"," + name + "~r~n") ' write the score and name to the file, seperate by comma and newline
	score_file.Close ' closes trhe file
	Return 1
End Function 
	
' Function to load ranking data from file and transfer it to PlayerScore array
Function LoadRanking() 
	Local score_file:FileStream 'declares the following local variables for this function
	Local scores_data:String 
	Local index:Int 
	Local itemCount:Int 
	Local name:String 
	Local mark:Int 
		' this is the file path for the rank txt, it opens the file in read mode 
	score_file = FileStream.Open("C:\Users\parvs\OneDrive\Desktop\my puzzle game\leaderboard\leaderboard\leaderboard\leaderboard.data\rank.txt","r")
	'reads the entire contetn of the file as a single string
	scores_data = score_file.ReadString() 
	'closes the file after reading
	score_file.Close() 
	
	'intialise index For storing scores in testScores arrays
	index = 0 ' bottom line: loops each line in score_file
	For Local score:String = Eachin scores_data.Split("~n") 
		itemCount = 0 
		For Local item:String = Eachin score.Split(",") ' loop through each item in line, split by comma
			If itemCount = 0 Then 
				mark = Int(item) ' convert the score to int and store in mark
			End 
			If itemCount =1 Then ' if itemCount = 1 then 
				name = item 		' store name in name variable 
			End
			itemCount += 1'increment item counter
		Next 
		'Store the score and name in the PlayerScore array as new GameScore object
		PlayerScore[index] = New GameScore(mark,name) 
		index += 1	'increment index 
	Next 
End Function 

'Function unpdates rank file if score is within the top 3
Function UpdateScore:Void(St_name:String,St_score:Int)
	Local count:Int   'array index variable
	Local score_file:FileStream  'file stream variable
	Local score_data:String 'file string variable
	
	count =-1'count initialised
	'identifies rank position and score added to rank file
	Repeat
		count+=1
		'checks if new score is above the score at this array position
		If St_score>PlayerScore[count].score Then
			'contents of array are reassigned to make space for the new score
			For Local row = 4 Until 0 Step - 1   ' shift entires down to make room for the new score in the top 5 rank
				PlayerScore[row].score = PlayerScore[row-1].score
				PlayerScore[row].name = PlayerScore[row-1].name
			Next
			'now new score and name are in allocated array position
			PlayerScore[count].score = St_score
			PlayerScore[count].name = St_name
			count = 4 ' stops further replacement after top 5 rank are processed
		Endif
	Until (count = 4) ' changed to stop after reaching the 5th rank
	'updates ranking in the file
	score_file = FileStream.Open("C:\Users\parvs\OneDrive\Desktop\my puzzle game\leaderboard\leaderboard\leaderboard\leaderboard.data\score_File.txt","a")
	
	'How contents are written in the rank file
	For Local row = 0 Until 5 'for top 5 rank
		If row <= 4 Then ' 0 is inlcusive so that means we limit to 4
			score_file.WriteString(PlayerScore[row].score +","+PlayerScore[row].name+"~n")
		Else
			score_file.WriteString(PlayerScore[row].name+","+PlayerScore[row].name)
		Endif
	Next
	'File closed
	score_file.Close()
End Function 

'to create the objects for the test scores array
Class GameScore 
	Field score:Int 
	Field name:String 
	'constructor for creating new object
	Method New(score:Int,name:String)
		Self.score = score
		Self.name = name 
	End 
End Class