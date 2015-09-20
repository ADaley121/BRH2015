<?php
session_start();
include ("includes/password.php");
include("includes/common.php");
include ("includes/sendemail.php");
include("includes/register_include.php");
include("includes/config.php");
	if(isset($_POST["Signup"])) {
		$error_message = "";
		$mysqli = open_mysqli();
		$username = transformPOST($_POST["email"]);
		$firstname = transformPOST($_POST["firstname"]);
		$lastname = transformPOST($_POST["lastname"]);
		$password = $_POST["password"];
		$passwordConfirm = $_POST["password1"];
		$phonenumber = transformPOST($_POST["phonenumber"]);
		$phonetest = isValidPhone($phonenumber);
		if(empty($username)){
			$error_message .= 'You forgot your email. <br />';
		}
		if(empty($password)){
			$error_message .= 'You forgot your password. <br />';
		}
		if(empty($passwordConfirm)){
			$error_message .= 'You must confirm your password. <br />';
		}
		if($password!=$passwordConfirm){
			$error_message .= 'Passwords do not match. <br />';
		}
		if(empty($firstname)){
			$error_message .= 'You forgot your first name. <br />';
		}
		if(empty($lastname)){
			$error_message .= 'You forgot your last name. <br />';
		}
		if(empty($phonenumber)){
			$error_message .= 'You forgot your phone number. <br />';
		}
		if(!$phonetest){
			$error_message .= 'Invalid phone number. <br />';
		}
		if (!filter_input(INPUT_POST, "email", FILTER_VALIDATE_EMAIL) || !strpos($username, "@cornell.edu")) {
			$error_message .= 'Invalid Cornell email. <br />';
		}
		$result = $mysqli->query("SELECT * FROM Users WHERE username = '$username'");
		if($result->num_rows > 0) {
			$error_message .= 'Email already registered. <br />';
		}
		if($error_message == ""){
            $username = strtolower($username);
			$passwordhash = password_hash($password,PASSWORD_BCRYPT);
			$userhash = password_hash(mcrypt_create_iv(10, MCRYPT_DEV_RANDOM),PASSWORD_BCRYPT);
			$add = $mysqli->query("INSERT INTO Users (username,passwordHash,firstName,lastName,".
				"telephone,active,verifyHash,hashExpiration) VALUES ('$username','$passwordhash','$firstname','$lastname','$phonenumber',0,'$userhash',DATE_ADD(NOW(),INTERVAL 1 DAY))");
			if($add){
				if(send_email($firstname,$username,$userhash)){
					$_SESSION["username"] = $username;
					$_SESSION["firstname"] = $firstname;
					$_SESSION["userhash"] = $userhash;
					header('Location: activation.php');
				}else{
					$error_message .= 'Failed to send confirmation email. <br />';
				}
			}
			else{
				$error_message .= 'Failed to add new user. <br />';										
			}
		}
	}
?>


<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="icon" href="../../favicon.ico">

    <title>Uber Reservations Registrations</title>

    <!-- Bootstrap core CSS -->
    <link href="bootstrap.min.css" rel="stylesheet">

    <!-- Custom styles for this template -->
    <link href="stylesheet1.css" rel="stylesheet">

    <!-- Just for debugging purposes. Don't actually copy these 2 lines! -->
    <!--[if lt IE 9]><script src="../../assets/js/ie8-responsive-file-warning.js"></script><![endif]-->
    <script src="../../assets/js/ie-emulation-modes-warning.js"></script>

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>

  <body>

    <nav class="navbar navbar-inverse navbar-fixed-top">
      <div class="container">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="#">Uber Reservations</a>
        </div>
        <div id="navbar" class="navbar-collapse collapse">
        </div><!--/.navbar-collapse -->
      </div>
    </nav>

    <!-- Main jumbotron for a primary marketing message or call to action -->
    <div class="jumbotron">
      <div class="container">
        <h1>Sign up/ Registration Page</h1>
			<form>
			  <div class="form-group">
				<label for="Email">Email address:</label>
				<input type="email" class="form-control" id="Email" placeholder="Email">
			  </div>
			  <div class="form-group">
				<label for="Password1">Make a password for our site/ your account:</label>
				<input type="password" class="form-control" id="Password1" placeholder="Password">
			  </div>
			  <div class="form-group">
				<label for="Password2">Retype the password:</label>
				<input type="password" class="form-control" id="Password2" placeholder="Verify Password">
			  </div>
			  <div class="form-group">
				<label for="Email">Uber account email:</label>
				<input type="email" class="form-control" id="Email" placeholder="Uber Email">
			  </div>
			  <div class="form-group">
				<label for="Password1">Uber Password:</label>
				<input type="password" class="form-control" id="Password3" placeholder="Uber Password">
			  </div>
			  <button type="submit" class="btn btn-default">Submit</button>
			</form>
      </div>
    </div>

    <div class="container">

	  <br><br><br><br><br><br><br>
	  	  <br><br>
      <hr>

      <footer>
        <p>&copy; Vincent Pan //Big Red Hacks 2015</p>
      </footer>
    </div> <!-- /container -->


    <!-- Bootstrap core JavaScript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
    <script src="../../dist/js/bootstrap.min.js"></script>
    <!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
    <script src="../../assets/js/ie10-viewport-bug-workaround.js"></script>
  </body>
</html>
