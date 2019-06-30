<?php
  $servername = "localhost";
  $username = "root";
  $password = "";
  $database = "test";
  // Create connection
  $conn = mysqli_connect($servername, $username, $password,$database);

  if($_SERVER['REQUEST_METHOD'] == 'POST'){

    $label = $_POST["label"];   //辨識物件名稱
    $num = (int) $_POST['num']; //難易度決定題數

    $sql = "SELECT * FROM 
        (SELECT * FROM plant_questions ORDER BY RAND() ) AS result 
        LIMIT $num;";


    // Check if there are results
      if ($result = mysqli_query($conn, $sql))
      {
      // If so, then create a results array and a temporary one
      // to hold the data
      $resultArray = array();
      $tempArray = array();

      // Loop through each row in the result set
      while($row = $result->fetch_object())
      {
        // Add each row into our results array
        $tempArray = $row;
        array_push($resultArray, $tempArray);
  
      }

      // Finally, encode the array to JSON and output the results
      echo json_encode($resultArray);
      }
  }
  
?>
