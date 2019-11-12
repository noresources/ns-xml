<?php
namespace NoreSources\NSXML\Composer;

use NoreSources\XSLT\Stylesheet;

class ComposerHook
{

	public static function updateAmalgamation()
	{
		$projectPath = __DIR__ . '/../../..';
		$projectPath = \realpath($projectPath);
		$bundleFilesPath = $projectPath . '/resources/bundle';

		$csv = fopen($bundleFilesPath . '/xsl.csv', 'r');
		while ($entry = fgetcsv($csv))
		{
			$path = $projectPath . '/' . $entry[0];
			$path = \realpath($path);
			$outputPath = preg_replace('/^(.*)\.xsl$/', '\1.bundle.xsl', $path);

			echo ('Consolidate: ');
			echo (\substr($path, \strlen($projectPath) + 1) . ' -> ' .
				\substr($outputPath, \strlen($projectPath) + 1) . PHP_EOL);

			$xslt = Stylesheet::consolidateFile($path);

			file_put_contents($outputPath, $xslt->saveXML());
		}
		fclose($csv);

		$csv = fopen($bundleFilesPath . '/xsd.csv', 'r');
		while ($entry = fgetcsv($csv))
		{
			$path = $projectPath . '/' . $entry[0];
			$path = \realpath($path);
			$outputPath = preg_replace('/^(.*)\.xsl$/', '\1.bundle.xsl', $path);

			echo ('Consolidate: ');
			echo (\substr($path, \strlen($projectPath) + 1) . ' -> ' .
				\substr($outputPath, \strlen($projectPath) + 1) . PHP_EOL);

			$dom = new \DOMDocument('1.0', 'utf-8');
			$dom->load($path);
			$dom->xinclude();
			file_put_contents($outputPath, $dom->saveXML());
		}
		fclose($csv);
	}
}