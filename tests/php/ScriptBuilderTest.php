<?php
/**
 * Copyright © 2022 by Renaud Guillard (dev@nore.fr)
 * Distributed under the terms of the MIT License, see LICENSE
 *
 * @package XML
 */
use NoreSources\XML\XSH\ScriptBuilder;
use PHPUnit\Framework\TestCase;

class ScriptBuilderTest extends TestCase
{

	public function testShebang()
	{
		$b = new ScriptBuilder();
		foreach ([[false, false],
			'bash' => '#!/usb/bin/env bash',
			'my-interpreter' => '#!/usb/bin/env my-interpreter',
			'/full/path' => '#!/full/path',
			'#!/unnecessary/path' => '#!/unnecessary/path'
		] as $k => $test) {
			if (\is_array($test))
			{
				$value = $test[0];
				$expected = $test[1];
			}
			else
			{
				$value = $k;
				$expected = $test;
			}
			$b->shebang($value);
			$this->assertEquals($expected, $b->getShebang(),
				'Shebang for ' . \strval($value));
		}
	}

	public function testRender()
	{
		$expectedFile = $this->getExpectedFile(__METHOD__);
		$builder = new ScriptBuilder();
		$builder->shebang("#!/foo/bar")
			->search(\preg_replace('/\.php$/', '', __FILE__))
			->functions("wtf")
			->body("echo 'Calling the imported function function'")
			->body("ns_wtf");
		$actual = \trim($builder->render());
		$expected = file_get_contents($expectedFile);
		$expected = \trim(\str_replace("\r\n", "\n", $expected));
		$this->assertEquals($expected, $actual, 'Render');
	}

	public function getExpectedFile($method)
	{
		return __DIR__ . '/'
			. \preg_replace ('/.*\\\\/', '', static::class)
			. '.' . \preg_replace('/.*::/', '', $method) . '.expected';
	}
}
