<?php
  $servername = "localhost";
  $username = "root";
  $password = "";
  $database = "ARQA";
  // Create connection
  $conn = mysqli_connect($servername, $username, $password,$database);

  if($_SERVER['REQUEST_METHOD'] == 'POST'){

    $tablename = $_POST["tablename"];   //辨識物件名稱
    $num = (int) $_POST['num']; //難易度決定題數

    $sql = "SELECT * FROM 
        (SELECT * FROM $tablename ORDER BY RAND() ) AS result 
        LIMIT $num;";

    // Check if there are results
      if ($result = mysqli_query($conn, $sql))
      {
      $resultArray = array();
      $tempArray = array();

      // Loop through each row in the result set
      while($row = $result->fetch_object())
      {
        // Add each row into our results array
        $tempArray = $row;
        array_push($resultArray, $tempArray);
      }
      echo json_encode($resultArray);
      }
  }
?>
