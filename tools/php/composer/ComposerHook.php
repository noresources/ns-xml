<?php

namespace NoreSources\NSXML\Composer;

use NoreSources\XSLT as xslt;

class ComposerHook
{

	public static function updateAmalgamation()
	{
		$projectPath = __DIR__ . '/../../..';
		$bundleFilesPath = $projectPath . '/resources/bundle';

		$csv = fopen($bundleFilesPath . '/xsl.csv', 'r');
		while ($entry = fgetcsv($csv))
		{
			$path = $projectPath . '/' . $entry[0];

			$xslt = new xslt\XSLTStylesheet();
			$xslt->load($path);
			$xslt->consolidate();
			
			file_put_contents (preg_replace ('/^(.*)\.xsl$/', '\1.bundle.xsl', $path), $xslt->saveXML());
		}
		fclose($csv);
		
		$csv = fopen($bundleFilesPath . '/xsd.csv', 'r');
		while ($entry = fgetcsv($csv))
		{
			$path = $projectPath . '/' . $entry[0];
			$dom = new \DOMDocument('1.0', 'utf-8');
			$dom->load($path);
			$dom->xinclude();			
			file_put_contents (preg_replace ('/^(.*)\.xsl$/', '\1.bundle.xsl', $path), $dom->saveXML());
		}
		fclose($csv);
			
	}
}