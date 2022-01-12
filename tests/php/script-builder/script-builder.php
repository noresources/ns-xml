<?php
namespace NoreSources\XML\XSH;

require_once (__DIR__ . '/../../../vendor/autoload.php');

$builder = new ScriptBuilder();

$builder->shebang("#!/foo/bar")
	->search(__DIR__)
	->functions("wtf")
	->body("echo 'Calling the imported function function'")
	->body("ns_wtf");

echo ($builder() . PHP_EOL);

