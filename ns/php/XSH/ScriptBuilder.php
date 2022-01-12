<?php

/**
 * Copyright © 2021 by Renaud Guillard (dev@nore.fr)
 * Distributed under the terms of the MIT License, see LICENSE
 *
 * @package XML
 */
namespace NoreSources\XML\XSH;

/**
 * XSH script builder
 *
 * Aggregates XSH function definition and shell script code
 * and render it as shell script for the targeted interpreter.
 */
class ScriptBuilder
{

	/**
	 * Script builder flag
	 *
	 * Add shebang line to script output
	 */
	const SHEBANG = 0x01;

	public function __construct()
	{
		$this->functions = [];
		$this->bodyParts = [];
		$this->searchPaths = [
			__DIR__ . '/../../../ns/xsh/lib'
		];
		$this->flags = 0;
	}

	/**
	 * Add library search path
	 *
	 * @param string $path
	 *        	Directory to add
	 * @return $this
	 */
	public function search($path)
	{
		\array_unshift($this->searchPaths, $path);
		return $this;
	}

	/**
	 *
	 * @param boolean|string $value
	 *        	If string. Set interpreter to this value.
	 * @return $this
	 */
	public function shebang($value)
	{
		unset($this->cache);
		$this->flags &= ~self::SHEBANG;
		if (!$value)
			return $this;

		$this->flags |= self::SHEBANG;
		if (\is_string($value))
			return $this->interpreter($value);

		return $this;
	}

	/**
	 * Set interpreter type or path
	 *
	 * @param string $interpreter
	 *        	Interpreter type (Ex: "bash", "python") or
	 *        	absolute path (Ex: "/bin/sh")
	 * @throws \InvalidArgumentException
	 * @return $this
	 */
	public function interpreter($interpreter)
	{
		unset($this->cache);
		if (!\is_string($interpreter))
			throw new \InvalidArgumentException('string expected');
		if (\strpos($interpreter, '#!') === 0)
			$interpreter = \substr($interpreter, 2);
		$this->interpreter = $interpreter;
		return $this;
	}

	/**
	 *
	 * @param string|\DOMElement $functions
	 *        	ns-xml function library short path or \DOMElement containing function
	 *        	definition(s)
	 * @param string|array|NULL $names
	 *        	A list of function names to it from $functions
	 * @throws \InvalidArgument
	 * @return $this
	 */
	public function functions($functions, $names = null)
	{
		unset($this->cache);
		if ($functions instanceof \DOMElement)
		{
			$this->functions[] = [
				'DOM' => $functions,
				'names' => $names
			];

			return $this;
		}

		if (!\is_file($functions))
		{
			foreach ($this->searchPaths as $searchPath)
			{
				$path = $searchPath . '/' . $functions . '.xsh';
				if (\file_exists($path))
				{
					$functions = $path;
					break;
				}
			}
		}

		if (!\file_exists($functions))
			throw new \InvalidArgument(
				'File, DOMElement or function library identifier expected.');

		$functions = \realpath($functions);

		$this->functions[] = [
			'file' => $functions,
			'names' => $names
		];

		return $this;
	}

	/**
	 *
	 * @param string $body
	 * @param boolean $append
	 *        	If true, append $body to the current builder body
	 * @return $this
	 */
	public function body($body, $append = true)
	{
		unset($this->cache);
		if (!$append)
		{
			$this->bodyParts = [];
		}

		$this->bodyParts[] = $body;
		return $this;
	}

	/**
	 * Build the XML document
	 *
	 * @return \DOMDocument XSH document
	 */
	public function build()
	{
		$interpreter = isset($this->interpreter) ? $this->interpreter : 'bash';
		$parameters = [];

		$implementation = new \DOMImplementation();

		$script = $implementation->createDocument(
			self::XSH_NAMESPACE_URI);
		$program = $script->createElementNS(self::XSH_NAMESPACE_URI,
			'xsh:program');
		$functions = $script->createElementNS(self::XSH_NAMESPACE_URI,
			'xsh:functions');
		$code = $script->createElementNS(self::XSH_NAMESPACE_URI,
			'xsh:code');
		$program->appendChild($functions);
		$program->appendChild($code);
		$script->appendChild($program);

		if ($this->flags & self::SHEBANG)
		{
			if (\preg_match(self::PATTERN_INTERPRETER_TYPE, $interpreter))
				$program->setAttribute('interpreterType', $interpreter);
			else
				$program->setAttribute('interpreterCommand',
					$interpreter);
		}

		$files = [];
		foreach ($this->functions as $entry)
		{
			$xpath = null;

			$names = $entry['names'];
			if (\is_string($names))
			{
				$names = [ $names ];
			}

			if (!\is_array($names))
			{
				$names = [];
			}

			if (\array_key_exists('DOM', $entry))
			{
				$element = $entry['DOM'];
				$doc = null;
				if ($element instanceof \DOMDocument)
					$doc = $element;
				elseif ($element instanceof \DOMElement)
					$doc = $element->ownerDocument;
				if (!$doc)
					continue;
				$xpath = new \DOMXpath($doc);
			}
			elseif (\array_key_exists('file', $entry))
			{
				$file = $entry['file'];
				if (\array_key_exists($file, $files))
					$xpath = $files[$file];
				else
				{
					$dom = new \DOMDocument('1.0', 'utf-8');
					$dom->load($file);
					$dom->xinclude();

					$xpath = new \DOMXPath($dom);
					$xpath->registerNamespace('xsh',
						self::XSH_NAMESPACE_URI);

					$files[$file] = $xpath;
				}
			}

			$selectors = \array_map(
				function ($name) {
					return '//xsh:function[@name="' . $name . '"]';
				}, $names);
			if (empty($selectors))
			{
				$selectors = [ '//xsh:function' ];
			}

			foreach ($selectors as $selector)
			{
				$nodes = $xpath->query($selector);
				foreach ($nodes as $node)
				{
					$node = $script->importNode($node, true);
					$functions->appendChild($node);
				}
			}
		}

		foreach ($this->bodyParts as $body)
		{
			$code->appendChild($script->createCDATASection($body));
		}

		return ($this->cache = $script);
	}

	/**
	 * Render XSH document to text
	 *
	 * @return string
	 */
	public function render()
	{
		$implementation = new \DOMImplementation();

		$stylesheet = $implementation->createDocument(
			self::XSLT_NAMESPACE_URI);
		$stylesheet->load(__DIR__ . '/../../xsl/languages/xsh.xsl');
		$stylesheet->xinclude();

		$processor = new \XSLTProcessor();
		$processor->importStylesheet($stylesheet);

		if (($this->flags & self::SHEBANG) != self::SHEBANG)
			$processor->setParameter('', 'xsh.printShebang', 'no');

		$result = $processor->transformToDoc($this->build());
		return $result->textContent . PHP_EOL;
	}

	/**
	 * Render script
	 *
	 * @return string
	 */
	public function __invoke()
	{
		return $this->render();
	}

	const PATTERN_INTERPRETER_TYPE = '/^[a-z0-9][a-z0-9_-]*$/i';

	/**
	 *
	 * @var string[]
	 */
	private $searchPaths;

	/**
	 *
	 * @var string
	 */
	private $interpreter;

	/**
	 *
	 * @var array
	 */
	private $functions;

	/**
	 *
	 * @var array
	 */
	private $bodyParts;

	/**
	 *
	 * @var integer
	 */
	private $flags;

	/**
	 *
	 * @var \DOMDocument
	 */
	private $cache;

	const XSLT_NAMESPACE_URI = 'http://www.w3.org/1999/XSL/Transform';

	const XSH_NAMESPACE_URI = 'http://xsd.nore.fr/xsh';
}
