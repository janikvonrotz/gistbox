<!--
#--------------------------------------------------#
# Title: Check MySQL DB Connection
#--------------------------------------------------#
# File name: CheckDBConnection.php
# Description: 
# Tags: mysql, php, connection, check
# Project: 
#
# Author: Janik von Rotz
# Author Contact: www.janikvonrotz.ch
#
# Create Date: 2013-05-14
# Last Edit Date: 2013-05-14
# Version: 1.0.0
#
# License: 
# This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
# To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
# send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
#--------------------------------------------------#
-->

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>MySQL Connection Test</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<style type="text/css">
#wrapper {
     width: 600px;
     margin: 20px auto 0;
     font: 1.2em Verdana, Arial, sans-serif;
}
input {
     font-size: 1em;
}
#submit {
     padding: 4px 8px;
}
</style>
</head>

<body>

<div id="wrapper">

<?php
     $action = htmlspecialchars($_GET['action'], ENT_QUOTES);
?>

<?php if (!$action) { ?>

     <h1>MySQL connection test</h1>

<form action="<?php echo $_SERVER['PHP_SELF']; ?>?action=test" id="mail" method="post">

     <table cellpadding="2">
          <tr>
               <td>Hostname</td>
               <td><input type="text" name="hostname" id="hostname" value="" size="30" tabindex="1" /></td>
               <td>(usually "localhost")</td>
          </tr>
          <tr>
               <td>Username</td>
               <td><input type="text" name="username" id="username" value="" size="30" tabindex="2" /></td>
               <td></td>
          </tr>
          <tr>
               <td>Password</td>
               <td><input type="text" name="password" id="password" value="" size="30" tabindex="3" /></td>
               <td></td>
          </tr>
          <tr>
               <td>Database</td>
               <td><input type="text" name="database" id="database" value="" size="30" tabindex="4" /></td>
               <td>(optional)</td>
          </tr>
          <tr>
               <td></td>
               <td><input type="submit" id="submit" value="Test Connection" tabindex="5" /></td>
               <td></td>
          </tr>
     </table>

</form>

<?php } ?>

<?php if ($action == "test") {

// The variables have not been adequately sanitized to protect against SQL Injection attacks: http://us3.php.net/mysql_real_escape_string

     $hostname = trim($_POST['hostname']);
     $username = trim($_POST['username']);
     $password = trim($_POST['password']);
     $database = trim($_POST['database']);

     $link = mysql_connect("$hostname", "$username", "$password");
          if (!$link) {
               echo "<p>Could not connect to the server '" . $hostname . "'</p>\n";
             echo mysql_error();
          }else{
               echo "<p>Successfully connected to the server '" . $hostname . "'</p>\n";
//               printf("MySQL client info: %s\n", mysql_get_client_info());
//               printf("MySQL host info: %s\n", mysql_get_host_info());
//               printf("MySQL server version: %s\n", mysql_get_server_info());
//               printf("MySQL protocol version: %s\n", mysql_get_proto_info());
          }
     if ($link && !$database) {
          echo "<p>No database name was given. Available databases:</p>\n";
          $db_list = mysql_list_dbs($link);
          echo "<pre>\n";
          while ($row = mysql_fetch_array($db_list)) {
               echo $row['Database'] . "\n";
          }
          echo "</pre>\n";
     }
     if ($database) {
    $dbcheck = mysql_select_db("$database");
          if (!$dbcheck) {
             echo mysql_error();
          }else{
               echo "<p>Successfully connected to the database '" . $database . "'</p>\n";
               // Check tables
               $sql = "SHOW TABLES FROM `$database`";
               $result = mysql_query($sql);
               if (mysql_num_rows($result) > 0) {
                    echo "<p>Available tables:</p>\n";
                    echo "<pre>\n";
                    while ($row = mysql_fetch_row($result)) {
                         echo "{$row[0]}\n";
                    }
                    echo "</pre>\n";
               } else {
                    echo "<p>The database '" . $database . "' contains no tables.</p>\n";
                    echo mysql_error();
               }
          }
     }
}
?>

</div><!-- end #wrapper -->
</body>
</html>