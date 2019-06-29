<?php
namespace NoreSources\NSXML\Composer;

require (__DIR__ . '/../../vendor/autoload.php');
require (__DIR__ . '/composer/ComposerHook.php');

$result = ComposerHook::updateAmalgamation();
exit (0);


