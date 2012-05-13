<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 by Renaud Guillard (dev@niao.fr) -->

<!-- Javascript code base of a xul application based on program schema -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">

	<import href="./xul-base.xsl" />
	<import href="../../languages/javascript.xsl" />

	<output method="text" encoding="utf-8" />

	<template match="text()">
		<value-of select="normalize-space(.)" />
	</template>

	<!-- Main -->
	<template match="/"><![CDATA[var EXPORTED_SYMBOLS = [ "]]><value-of select="$prg.xul.js.applicationInstanceName" /><![CDATA[" ];

function Application()
{
	this.ioService = Components.classes["@mozilla.org/network/io-service;1"].getService(Components.interfaces.nsIIOService);
}

// Print a message in the shell and in the javascript console
Application.prototype.trace = function(str)
{
	dump(str + "\n");
	Components.classes['@mozilla.org/consoleservice;1'].getService(Components.interfaces.nsIConsoleService).logStringMessage(str);
}

// Trace message if the application was generated with the prg.debug parameter to true()
Application.prototype.debug = function(str, e)
{
]]><if test="$prg.debug"><![CDATA[dump(str + ((e) ? "" : "\n"));]]></if><![CDATA[
}

// Exit application
Application.prototype.quitApplication = function()
{
	var appStartup = Components.classes['@mozilla.org/toolkit/app-startup;1'].getService(Components.interfaces.nsIAppStartup);
	appStartup.quit(Components.interfaces.nsIAppStartup.eAttemptQuit);
	return true;
}

// Return the file URI of the application path (where application.ini resides) 
Application.prototype.getApplicationURI = function()
{
	try
	{
		var chromePath = Components.classes["@mozilla.org/file/directory_service;1"].getService(Components.interfaces.nsIProperties).get("AChrom",Components.interfaces.nsIFile);
		var chromeUri = this.ioService.newFileURI(chromePath);
		var appUri = this.ioService.newURI(chromeUri.resolve(chromeUri.path + ".."), null, null);
	
		//this.trace("chromeUri " + chromeUri.path);
		//this.trace("appUri " + appUri.path);
		
		return appUri;
	}
	catch (e)
	{
		this.trace("getApplicationURI:" + e);
		return null;
	}	
}

// Return the file URI of the application path (where application.ini resides) as a string
Application.prototype.getApplicationPath = function()
{
	var appUri = this.getApplicationURI();
	if (appUri)
	{
		return unescape(appUri.path);
	}
	
	return "";
}

// Return the directory where the application folder (linux) or application bundle (Mac OS X) is located
Application.prototype.getBundleURI = function()
{
	var relativePath = "..]]><if test="$prg.xul.platform = 'macosx'"><![CDATA[/../..]]></if><![CDATA[";
	try
	{
		var appUri = this.getApplicationURI();
		var bundleUri = this.ioService.newURI(appUri.resolve(appUri.path + relativePath), null, null);
		return bundleUri;
	}
	catch (e)
	{
		this.trace("getBundleURI:" + e);
	}
	
	return null;
}

// Return the directory where the application folder (linux) or application bundle (Mac OS X) is located
Application.prototype.getBundlePath = function()
{
	try
	{
		var bundleUri = this.getBundleURI();
		return unescape(bundleUri.path);
	}
	catch (e)
	{
		this.trace("getBundlePath:" + e);
	}	
	
	return "";
}

Application.prototype.getBundleName = function()
{
	try
	{
		var relativePath = "..]]><if test="$prg.xul.platform = 'macosx'"><![CDATA[/..]]></if><![CDATA[";
		var appUri = this.getApplicationURI();
		var rootUri = this.ioService.newURI(appUri.resolve(appUri.path + relativePath), null, null);
		
		var file = Components.classes["@mozilla.org/file/local;1"].createInstance(Components.interfaces.nsILocalFile);
		file.initWithPath(rootUri.path);
		return unescape(file.leafName);
	}
	catch (e)
	{
		this.trace("getBundleName:" + e);
	}
		
	return "";
}

// Application object instance
var ]]><value-of select="$prg.xul.js.applicationInstanceName" /><![CDATA[ = new Application();

]]></template>

</stylesheet>
