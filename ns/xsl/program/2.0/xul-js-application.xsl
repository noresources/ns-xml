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
}

Application.prototype.trace = function(str)
{
	dump(str + "\n");
	Components.classes['@mozilla.org/consoleservice;1'].getService(Components.interfaces.nsIConsoleService).logStringMessage(str);
}

Application.prototype.debug = function(str, e)
{
]]><if test="$prg.debug"><![CDATA[dump(str + ((e) ? "" : "\n"));]]></if><![CDATA[
}

Application.prototype.quitApplication = function()
{
	var appStartup = Components.classes['@mozilla.org/toolkit/app-startup;1'].getService(Components.interfaces.nsIAppStartup);
	appStartup.quit(Components.interfaces.nsIAppStartup.eAttemptQuit);
	return true;
}

Application.prototype.getApplicationURI = function()
{
	try
	{
		var ioService = Components.classes["@mozilla.org/network/io-service;1"].getService(Components.interfaces.nsIIOService);
		var chromePath = Components.classes["@mozilla.org/file/directory_service;1"].getService(Components.interfaces.nsIProperties).get("AChrom",Components.interfaces.nsIFile);
		var chromeUri = ioService.newFileURI(chromePath);
		var appUri = ioService.newURI(chromeUri.resolve(chromeUri.path + ".."), null, null);
	
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

Application.prototype.getApplicationPathString = function()
{
	var appUri = this.getApplicationURI();
	if (appUri)
	{
		return appUri.path;
	}
	
	return "";
}

var ]]><value-of select="$prg.xul.js.applicationInstanceName" /><![CDATA[ = new Application();

]]></template>

</stylesheet>
