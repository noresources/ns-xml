<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 - 2021 by Renaud Guillard (dev@nore.fr) -->
<stylesheet xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program" version="1.0">
	<output method="text" encoding="utf-8" />
	<param name="interpreter">
		<text>php</text>
	</param>
	<include href="../../../ns/xsl/languages/php.xsl" />

	<template match="prg:databinding/prg:variable">
		<value-of select="normalize-space(.)" />
	</template>

	<template match="/">
		<text>#!/usr/bin/env </text>
		<value-of select="$interpreter" />
		<text><![CDATA[
<?php
$scriptPath = dirname (realpath(__FILE__));
require_once ($scriptPath . '/program-lib.php' );

function echol ($line) {
	echo ($line . PHP_EOL);
}
function echolist ($iterable) {
	$first = true;
	foreach ($iterable as $a) {
		if (!$first) {
			echo ', ';
		}
		$first = false;
		echo '"' . $a . '"';
	}

	echo (PHP_EOL);
}

function echovalue($arg) {
	if (is_bool($arg)) {
		echo (($arg) ? 'True' : 'False');
	}
	else if (is_array($arg)){
		echo implode(' ', $arg);
	} else {
		echo $arg;
	}
	echo (PHP_EOL);
}

$info = new \TestProgramInfo;
$parser = new \Parser($info);
$result = $parser->parse($_SERVER['argv']);

$args = $_SERVER['argv'];
array_shift($args);
$displayHelp = false;
foreach ($args as $arg) {
	if ($arg == '__help__') {
		$displayHelp = true;
		break;
	}
}

echo 'CLI: ';
echolist ($args);
echol ('Value count: ' . $result->valueCount());
echo ('Values: '); echolist ($result);
$errors = $result->getMessages(\Message::ERROR);
$errorCount = count($errors);
echol ('Error count: ' . $errorCount);
if ($errorCount > 0) {
	foreach ($args as $arg) {
		if ($arg == '__msg__') {
			echol ('Errors');
			foreach ($errors as $e) {
				echol ('- ' . $e);
			}
		}
	}
} 
echol ('Subcommand: ' . ($result->subcommandName ? $result->subcommandName : ''));  
]]></text>
		<!-- Global args -->
		<if test="/prg:program/prg:options">
			<variable name="root" select="/prg:program/prg:options" />
			<apply-templates select="$root//prg:switch | $root//prg:argument | $root//prg:multiargument | .//prg:group" />
		</if>
		<for-each select="/prg:program/prg:subcommands/*">
			<if test="./prg:options">
				<text>if ($result->subcommandName == "</text>
				<apply-templates select="prg:name" />
				<text>")</text>
				<value-of select="'&#10;'" />
				<text>{</text>
				<call-template name="code.block">
					<with-param name="content">
						<apply-templates select=".//prg:switch | .//prg:argument | .//prg:multiargument | .//prg:group" />
					</with-param>
				</call-template>
				<value-of select="'&#10;'" />
				<text>}</text>
				<value-of select="'&#10;'" />
			</if>
		</for-each><![CDATA[if ($displayHelp)  {
	$usage = new UsageFormat;
	$usage->format = UsageFormat::DETAILED_TEXT;
	echo ($info->usage($usage, $result->subcommandName));
	exit (0);
}]]>
	</template>

	<template name="prg.php.unittest.variablePrefix">
		<param name="node" select="." />
		<choose>
			<when test="$node/self::prg:subcommand">
				<apply-templates select="$node/prg:name" />
				<text>_</text>
			</when>
			<when test="$node/..">
				<call-template name="prg.php.unittest.variablePrefix">
					<with-param name="node" select="$node/.." />
				</call-template>
			</when>
		</choose>
	</template>

	<template name="prg.php.unittest.variableNameTree">
		<param name="node" />
		<param name="leaf" select="true()" />

		<choose>
			<when test="$node/self::prg:subcommand">
				<text>$result->subcommand["</text>
			</when>
			<when test="$node/self::prg:program">
				<text>$result["</text>
			</when>
			<when test="$node/../..">
				<call-template name="prg.php.unittest.variableNameTree">
					<with-param name="node" select="$node/../.." />
					<with-param name="leaf" select="false()" />
				</call-template>
			</when>
		</choose>
		<!-- <if test="$node/self::prg:group and not($leaf)">
			<text>.options.</text>
			</if> -->
		<if test="$leaf">
			<apply-templates select="$node/prg:databinding/prg:variable" />
			<text>"]</text>
		</if>
	</template>

	<template match="//prg:switch | //prg:argument | //prg:multiargument">
		<if test="./prg:databinding/prg:variable">
			<text>echo("</text>
			<call-template name="prg.php.unittest.variablePrefix" />
			<apply-templates select="./prg:databinding/prg:variable" />
			<text>="); echovalue(</text>
			<call-template name="prg.php.unittest.variableNameTree">
				<with-param name="node" select="." />
			</call-template>
			<text>->value());</text>
			<value-of select="'&#10;'" />
		</if>
	</template>

	<template match="//prg:group">
		<if test="./prg:databinding/prg:variable">
			<text>echo</text>
			<if test="not(./@type = 'exclusive')">
				<text>l</text>
			</if>
			<text>("</text>
			<call-template name="prg.php.unittest.variablePrefix" />
			<apply-templates select="./prg:databinding/prg:variable" />
			<text>=");</text>
			<if test="./@type = 'exclusive'">
				<text> echovalue(</text>
				<call-template name="prg.php.unittest.variableNameTree">
					<with-param name="node" select="." />
				</call-template>
				<text>->value());</text>
			</if>
			<value-of select="'&#10;'" />
		</if>
	</template>
</stylesheet>
