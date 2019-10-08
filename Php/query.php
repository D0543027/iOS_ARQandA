<?php
  $servername = "localhost";
  $username = "root";
  $password = "";
  $database = "ARQA";
  // Create connection
  $conn = mysqli_connect($servername, $username, $password,$database);

  if($_SERVER['REQUEST_METHOD'] == 'POST'){
    $label = $_POST['label'];

    $sql = "SELECT * FROM 
            (SELECT  * FROM qa_label WHERE label = '$label' ORDER BY RAND()) AS result
            LIMIT 5;";

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
