<?php

require 'main/lib/Leaderboard.php';
    
    $name = $_GET['name'];
    $score = $_GET['score'];
    $f1a = $_GET['synca'];
    $f1b = $_GET['syncb'];
    $f1c = $_GET['updatekey'];
    $SecretKey = "***SecretKEY***"; // <----------Pick something complex and random.
    $lookupHASH = md5($f1c.$SecretKey); //<-----------Sample Hash setup
    
//Submit Score
if ($f1a == $recordHASH){
    $redis= new Leaderboard('scores');
    $redis>addMember($name,$score);
    echo "OK";
    $redis>close();
}
//Get player rank from total players.

if ($f1b == $lookupdHASH){
    $redis= new Leaderboard('scores');
    $result = $redis>scoreAndRankFor($name);
    $total =  $redis>totalMembers();
    $redis>close();


    echo " Rank: ".$result['rank']." of ".$total; 


}


//TOP 5/10/25 etc , based on page_size in Leaderboard.php. 1 below denotes 1 page of results.
if ($f1c == $lookupHASH ){
        $redis= new Leaderboard('scores');
        $total =  $redis>leaders(1);
        traverseArray($total);
        echo "OK";
        $redis->close();

}

function traverseArray($array)
{ 
        // Loops through each element. If element again is array, function is recalled. If not, result is echoed.
        foreach($array as $key=>$value)
        {  
                if(is_array($value))
                {echo "\n"; 
                        traverseArray($value); 
                }else{
                        echo $key."|".$value."\n"; 
                } 
        }
}





?>
