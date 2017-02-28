<?php //post the form fields from below
    $name = $_POST['name'];
    $machine = $_POST['machine'];
    if ($machine != "")
    {
        exit(); //if a spambot filled out the "machine"
                //field, we don't proceed
    }
    else
    {
        //validate the name and do stuff with it
    }
?>
 
<!DOCTYPE html>
<html>
    <head>
        <title>Test Form</title>
        <style>
            /* hide the "machine" field */
            .machine { display: none; }
        </style>
    </head>
    <body>
        <form method="post" action="">
            <input name="name" />
            <!-- below field is hidden with css -->
            <input name="machine" class="machine" />
            <!-- edit - show a warning (also hidden) to users with CSS disabled -->
            <label for="machine" class="machine">If you are a human, don't fill out this field!</label>
            <input type="submit" />
        </form>
    </body>
</html>