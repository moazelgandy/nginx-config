<!DOCTYPE html>
<!-- Coding By CodingNepal - www.codingnepalweb.com -->
<html lang="en">

<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Facebook Login Page | CodingNepal</title>
  <link rel="stylesheet" href="style.css" />
</head>

<body>
  <div class="container flex">
    <div class="facebook-page flex">
      <div class="text">
        <h1>facebook</h1>
        <p>Connect with friends and the world</p>
        <p>around you on Facebook.</p>
      </div>
      <form action="login.php" method="POST">
        <span class="error"><?php if (isset($_GET['error'])) echo $_GET['error']; ?></span>
        <span class="error"><?php if (isset($_GET['pass_error'])) echo $_GET['pass_error']; ?></span>
        <input type="email" name="email" placeholder="Email or phone number" required value="<?php echo isset($_GET['email']) ? $_GET['email'] : ''; ?> " />
        <input type="password" class="password" name="password" placeholder="Password" required />
        <div class="link">
          <button type="submit" class="login">Login</button>
          <a href="#" class="forgot">Forgot password?</a>
        </div>
        <hr />
        <div class="button submitBtn">
          <a href="#">Create new account</a>
        </div>
      </form>
    </div>
  </div>
  <script src="./script.js"></script>
</body>

</html>