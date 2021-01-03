<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css"
        integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous">
    <title>Document</title>
</head>

<body>
    <?php
    $email= $_POST['email'];
    $name= $_POST['user'];
    $password = $_POST['password'];    
    if(isset($_POST['submit'])) {
      // Check if name has been entered
      if(empty($_POST['user'])) {
        $errName= 'Please enter your user name';
      }
      // Check if email has been entered and is valid
      else if(empty($_POST['email'])) {
        $errEmail = 'Please enter a valid email address';
      }
      // check if a password has been entered and if it is a valid password
      else if(empty($_POST['password']) || (preg_match("/^.*(?=.{8,})(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z]).*$/", $_POST["password"]) === 0)) {
        $errPass = '<p class="errText">Password must be at least 8 characters and must contain at least one lower case letter, one upper case letter and one digit</p>';
      } else {
        echo "The form has been submitted";
      }
    }
  ?>
    <div class="container">
        <form role="form" method="post" action="<?php echo htmlspecialchars($_SERVER[" PHP_SELF"]);?>">
            <div class="form-group row">
                <label for="inputEmail" class="col-sm-2 col-form-label">Email</label>
                <div class="col-sm-10">
                    <input type="email" class="form-control" id="inputEmail" name="email" placeholder="Email">
                    <?php echo $errEmail; ?>
                </div>
            </div>
            <div class="form-group row">
                <label for="inputUser" class="col-sm-2 col-form-label">User Name</label>
                <div class="col-sm-10">
                    <input type="text" class="form-control" id="inputUser" name="user" placeholder="Username">
                    <?php echo $errName; ?>
                </div>
            </div>
            <div class="form-group row">
                <label for="inputPassword3" class="col-sm-2 col-form-label">Password</label>
                <div class="col-sm-10">
                    <input type="password" class="form-control" id="inputPassword" name="password"
                        placeholder="Password">
                    <?php echo $errPass; ?>
                </div>
            </div>
            <div class="form-group row">
                <div class="offset-sm-2 col-sm-10">
                    <input type="submit" value="Sign in" name="submit" class="btn btn-primary" />
                </div>