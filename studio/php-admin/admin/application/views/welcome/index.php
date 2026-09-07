Login Sesstion
<pre>

<?php 
echo "<pre>";
var_dump(hasAccess('student_view1,student_view'));
echo "</pre>";

echo "Role : " . get_role();
echo "<br>";
echo "is_login : "; var_dump(is_login());

echo "<br><br>";
echo "getUserData : <pre>"; print_r(getUserData()); echo "</pre>";

echo "<br>";
echo "getAccess : <pre>"; print_r(getAccess()); echo "</pre>";

?>

</pre>