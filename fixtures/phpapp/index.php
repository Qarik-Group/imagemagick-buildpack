<?php
$output = shell_exec('convert -version');
echo "<h1>ImageMagick</h1><pre>$output</pre>";
?>
