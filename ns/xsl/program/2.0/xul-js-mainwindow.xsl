<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright (c) 2011 by Renaud Guillard (dev@niao.fr) -->
<!-- Javascript code base of a xul application based on program schema -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">

	<import href="./xul-base.xsl" />
	<import href="../../languages/javascript.xsl" />
	
	<output method="text" encoding="utf-8" />
	
	<template match="text()">
		<value-of select="normalize-space(.)" />
	</template>

	<template name="prg.xul.optionSpecs">
		<param name="optionNode" select="." />
		<variable name="exclusiveGroup" select="$optionNode/../../self::prg:group[@type = 'exclusive']" />
		<text>type: "</text>
		<call-template name="str.elementLocalPart">
			<with-param name="node" select="." />
		</call-template>
		<text>", parent: </text>
		<choose>
			<when test="$optionNode/../../self::prg:group">
				<text>"</text>
				<call-template name="prg.optionId">
					<with-param name="optionNode" select="$optionNode/../../self::prg:group" />
				</call-template>
				<text>"</text>
			</when>
			<otherwise>
				<text>null</text>
			</otherwise>
		</choose>
		<text>, optionName: </text>
		<choose>
			<when test="$optionNode/prg:names/prg:long">
				<text>"--</text>
				<value-of select="$optionNode/prg:names/prg:long[1]" />
				<text>"</text>
			</when>
			<when test="$optionNode/prg:names/prg:short">
				<text>"-</text>
				<value-of select="$optionNode/prg:names/prg:short[1]" />
				<text>"</text>
			</when>
			<otherwise>
				<text>null</text>
			</otherwise>
		</choose>
		<text>, uiMode: </text>
		<choose>
			<when test="$optionNode/prg:ui/@mode">
				<text>"</text>
				<value-of select="$optionNode/prg:ui/@mode" />
				<text>"</text>
			</when>
			<otherwise>
				"default"
			</otherwise>
		</choose>
		<text>, hiddenValue: </text>
		<choose>
			<when test="$optionNode/prg:ui/prg:value">
				<text>"</text>
				<value-of select="$optionNode/prg:ui/prg:value" />
				<text>"</text>
			</when>
			<when test="$optionNode/prg:ui/prg:values">
				<text>[</text>
				<for-each select="$optionNode/prg:ui/prg:values">
					<text>"</text>
					<value-of select="prg:value" />
					<text>"</text>
					<if test="position() != last()">
						<text>, </text>
					</if>
				</for-each>
				<text>]</text>
			</when>
			<otherwise>
				null
			</otherwise>
		</choose>
	</template>

	<!-- Main  -->
	<template match="/"><![CDATA[
function MainWindow(app)
{
	this.app = app;
	
	this.globalId = "::global::";
	
	this.options = 
	{
		"::global::" : 
		{
]]><for-each select="prg:program/prg:options/* | prg:program/prg:options//prg:options/*">
		<text>			"</text>
		<call-template name="prg.optionId" />
		<text>": {</text>
		<call-template name="prg.xul.optionSpecs" />
		<text>}</text>
		<if test="position() != last()">
			<text>,</text>
			<call-template name="endl" />
		</if>
	</for-each><![CDATA[
		}]]><if test="/prg:program/prg:subcommands">
		<text>,</text>
		<call-template name="endl" />
	</if>
		<for-each select="/prg:program/prg:subcommands/prg:subcommand">
			<text>		"</text>
			<value-of select="prg:name" />
			<text>":</text>
			<call-template name="endl" />
			<text>		{</text>
			<call-template name="endl" />
			<for-each select="prg:options/* | prg:options//prg:options/*">
				<text>			"</text>
				<call-template name="prg.optionId" />
				<text>": {</text>
				<call-template name="prg.xul.optionSpecs" />
				<text>}</text>
				<if test="position() != last()">
					<text>,</text>
					<call-template name="endl" />
				</if>
			</for-each>
			<call-template name="endl" />
			<text>		}</text>
			<if test="position() != last()">
				<text>,</text>
				<call-template name="endl" />
			</if>
		</for-each><![CDATA[
	};
	
	this.values = 
	{
		"::global::" : 
		[
]]><for-each select="/prg:program/prg:values/*">
		<text>			"</text>
		<call-template name="prg.xul.valueId">
			<with-param name="valueNode" select="." />
			<with-param name="index" select="position()" />
		</call-template>
		<text>"</text>
		<if test="position() != last()">
			<text>,</text>
			<call-template name="endl" />
		</if>
	</for-each><![CDATA[
		]]]><if test="/prg:program/prg:subcommands">
		<text>,</text>
		<call-template name="endl" />
	</if>
		<for-each select="/prg:program/prg:subcommands/prg:subcommand">
			<text>		"</text>
			<value-of select="prg:name" />
			<text>":</text>
			<call-template name="endl" />
			<text>		[</text>
			<call-template name="endl" />
			<for-each select="prg:values/*">
				<text>			"</text>
				<call-template name="prg.xul.valueId">
					<with-param name="index" select="position()" />
				</call-template>
				<text>"</text>
				<if test="position() != last()">
					<text>,</text>
					<call-template name="endl" />
				</if>
			</for-each>
			<call-template name="endl" />
			<text>		]</text>
			<if test="position() != last()">
				<text>,</text>
				<call-template name="endl" />
			</if>
		</for-each><![CDATA[
	};
	
	this.optionNames = 
	{
		"::global::" : 
		{
]]><for-each select="prg:program/prg:options/*/prg:names/* | prg:program/prg:options//prg:options/*/prg:names/*">
		<text>			"</text>
		<value-of select="." />
		<text>": "</text>
		<call-template name="prg.optionId">
			<with-param name="optionNode" select="../.." />
		</call-template>
		<text>"</text>
		<if test="position() != last()">
			<text>,</text>
			<call-template name="endl" />
		</if>
	</for-each><![CDATA[
		}]]><if test="/prg:program/prg:subcommands">
		<text>,</text>
		<call-template name="endl" />
	</if>
		<for-each select="/prg:program/prg:subcommands/prg:subcommand">
			<text>		"</text>
			<value-of select="prg:name" />
			<text>":</text>
			<call-template name="endl" />
			<text>		{</text>
			<call-template name="endl" />
			<for-each select="prg:options/*/prg:names/* | prg:options//prg:options/*/prg:names/*">
				<text>			"</text>
				<value-of select="." />
				<text>": "</text>
				<call-template name="prg.optionId">
					<with-param name="optionNode" select="../.." />
				</call-template>
				<text>"</text>
				<if test="position() != last()">
					<text>,</text>
					<call-template name="endl" />
				</if>
			</for-each>
			<call-template name="endl" />
			<text>		}</text>
			<if test="position() != last()">
				<text>,</text>
				<call-template name="endl" />
			</if>
		</for-each><![CDATA[	
	};
	
	this.subCommand = null;
	
	this.globalValueCount = ]]><choose>
		<when test="/prg:program/prg:values">
			<value-of select="count(/prg:program/prg:values/prg:value)" />
		</when>
		<otherwise>
			<text>0</text>
		</otherwise>
	</choose>
		<text>;</text><![CDATA[
	
	Components.utils.import("resource://ns/xbl/controls.jsm");	
	this.optionChangeEventListener = new EventForwarder (this, this.handleOptionChange);
	this.valueChangeEventListener = new EventForwarder (this, this.handleValueChange);
}

MainWindow.prototype.initialize = function()
{
	for (var g in this.options)
	{
		var gs = this.options[g];
		for (var id in gs)
		{
			var option = document.getElementById(id);
			if (option)
			{
				option.addEventListener("change", this.optionChangeEventListener, true);
				option.initialize();
			}
		}
	}
	
	for (var g in this.values)
	{
		var gs = this.values[g];
		for (var index in gs)
		{
			var id = gs[index];
			var value = document.getElementById(id);
			if (value)
			{
				value.addEventListener("change", this.valueChangeEventListener, true);
			}
		}
		
		this.updateValueControls(g);
	}
	
	// Load user-defined post initialization
	var onInitializeURI = "chrome://]]><value-of select="$prg.xul.appName" /><![CDATA[/content/]]><value-of select="$prg.xul.appName" /><![CDATA[-user.js";
	var user = {};
	var scriptLoader = Components.classes["@mozilla.org/moz/jssubscript-loader;1"].getService(Components.interfaces.mozIJSSubScriptLoader);
	try
	{
		scriptLoader.loadSubScript(onInitializeURI, user);
		
		if (typeof(user.onInitialize) == "function")
		{
			try
			{
				user.onInitialize(this, this.app);
			}
			catch (e)
			{
				this.trace("User-defined initialization function failed: " + e);
			}
		}
	}
	catch (e) {}
	
	
	this.updatePreview();
}

MainWindow.prototype.trace = function(str)
{
	var s = "MainWindow: " + str + "\n"; 
	dump(s);
	Components.classes['@mozilla.org/consoleservice;1'].getService(Components.interfaces.nsIConsoleService).logStringMessage(s);
}

MainWindow.prototype.debug = function(str, e)
{
]]><if test="$prg.debug"><![CDATA[dump(str + ((e) ? "" : "\n"));]]></if><![CDATA[
}

MainWindow.prototype.setRowEnabled = function(e, value)
{
	var r = e;
	while (r && r.localName != "row")
	{
		r = r.parentNode;
	}
	
	if (r)
	{
		//this.trace("enable row = " + value);
		var nh = new NodeHelper;
		nh.enableNode(r, value, true);
	}
}

MainWindow.prototype.setRowVisible = function(e, visible)
{
	var r = e;
	while (r && r.localName != "row")
	{
		r = r.parentNode;
	}
	
	if (r)
	{
		if (visible)
		{
			r.removeAttribute("hidden");
		}
		else
		{
			r.setAttribute("hidden", true);
		}
	}
}

MainWindow.prototype.setGroupVisible = function(e, visible)
{
	for (var g in this.options)
	{
		var gs = this.options[g];
		for (var id in gs)
		{
			var specs = gs[id];
			var option = document.getElementById(id);
			if (specs.parent == e.id)
			{
				//this.trace("set visible " + id + " " + visible);
				this.setRowVisible(option, visible);
				if (specs.type == "group")
				{
					this.setGroupVisible(option, visible);
				}
			}
		}
	}	
}

MainWindow.prototype.addInputToMultiValue = function(baseId)
{
	var source = document.getElementById(baseId + ":input");
	var target = document.getElementById(baseId + ":proxy");
	if (source.value.length)
	{
		target.addElement(source.value);
	}
}

MainWindow.prototype.RebuildObserver = function(app)
{
	this.application = app;
}

MainWindow.prototype.RebuildObserver.prototype.observe = function(subject, topic, data)
{
	try
	{
		var process = subject.QueryInterface(Components.interfaces.nsIProcess);
		if (topic == "process-failed")
		{
			alert("Failed to launch process");
			return;
		}
		else if (process.exitValue)
		{
			alert("Process exit value: " + process.exitValue);
			return;
		}
	}
	catch(e)
	{
		return;
	}
	
	document.location = document.location;
}

MainWindow.prototype.rebuildWindow = function(path, args)
{
	var args = new Array();
	var commandPath = unescape(this.app.getApplicationPathString() + "sh/_rebuild.sh"); 
	this.executeCommand(commandPath, args, new this.RebuildObserver(this)); 
}

MainWindow.prototype.getOptionIdByName = function(name, subcommand)
{
	var g = (subcommand) ? this.optionNames[subcommand] : this.optionNames[this.globalId];
	if (g)
	{
		return g[name];
	}
	
	return null;
}

MainWindow.prototype.getOptionArguments = function(option, specs)
{
	var result = new Array();
	if (specs.uiMode == "disabled")
	{
		return result;
	}
	
	//this.trace(specs.optionName);
	
	if (specs.type == "switch")
	{
		result.push(specs.optionName);
	}
	else if (specs.type == "argument")
	{
		result.push(specs.optionName);
		var value = (specs.uiMode == "hidden") ? specs.hiddenValue : option.value;
		result.push(value);
	}
	else if (specs.type == "multiargument")
	{
		result.push(specs.optionName);
		var values = (specs.uiMode == "hidden") ? specs.hiddenValue : option.value;
		for (var i in values)
		{
			result.push(values[i]);
		}
	}
	
	return result;
}

MainWindow.prototype.getOptionSetArguments = function(group)
{
	var result = new Array();
	var groupSpecs = this.options[group];
	for (var id in groupSpecs)
	{
		var option = document.getElementById(id);
		if ((!option) || option.isSet)
		{
			var r = this.getOptionArguments(option, groupSpecs[id]);
			for (var i = 0; i < r.length; i++)
			{
				result.push(r[i]);
			}
		}
	}
	
	return result;
}

MainWindow.prototype.getValueSetArguments = function(group)
{
	var result = new Array();
	var groupIds = this.values[group];
	for (var index in groupIds)
	{
		var id = groupIds[index];
		//this.trace(id);
		var v = document.getElementById(id);
		if (!v)
		{
			continue;
		}
		
		if (!v.isSet)
		{
			break;
		}
		
		//this.trace(id + ": " + v.isSet + " " + typeof(v.value));
		
		if (typeof(v.value) == "string")
		{
			//this.trace(id + ": add " + v.value);
			result.push(v.value);
		}
		else if (typeof(v.value) == "object")
		{
			for (var item in v.value)
			{
				//this.trace(id + ": add " + v.value[item]);
				result.push(v.value[item]);
			}
		}
	}
	
	return result;
}

MainWindow.prototype.getCommandArguments = function()
{
	var result = this.getOptionSetArguments(this.globalId);
	
	if (this.subcommand)
	{
		result.push(this.subcommand);
		
		var ov = this.getOptionSetArguments(this.subcommand);
		for (var o = 0; o < ov.length; o++)
		{
			result.push(ov[o]);
		}
		
		var vv = this.getValueSetArguments(this.subcommand);
		for (var v = 0; v < vv.length; v++)
		{
			result.push(vv[v]);
		} 
		
	}
	else
	{
		var vv = this.getValueSetArguments(this.globalId);
		for (var v = 0; v < vv.length; v++)
		{
			result.push(vv[v]);
		}
	}
		
	return result;
}

MainWindow.prototype.handleOptionChange = function(event, object)
{
	try
	{
		if (event.target.optionType == "group")
	  	{
	  		if (!event.target.isSet)
	  		{
	  			var radioGroupId = event.target.id + ":group";
	  			//object.trace("handleOptionChange get " + radioGroupId); 
	  			var radioGroup = document.getElementById(radioGroupId);
	  			radioGroup.selectedIndex = -1;
	  		}	
		}
		else if (event.target.parent)
		{
			//object.trace("handleOptionChange: activate parent:" + event.target.parent.id);
			event.target.parent.isSet = true;
		}
	}
	catch (e)
	{
		object.trace("handleOptionChange error: " + e);
	}
  
	object.updatePreview(); 
}

MainWindow.prototype.updateValueControls = function(group)
{
	var g = (group) ? group : ((this.subcommand) ? this.subcommand : this.globalId);
	//this.trace("Update values of group " + g);
	var groupIds = this.values[g];
	var isSet = true;
	var first = true;
	for (var index in groupIds)
	{
		var id = groupIds[index];
		var ctrl = document.getElementById(id);
		if (ctrl)
		{
			//this.trace(ctrl.id + " " + isSet);
			this.setRowEnabled(ctrl, isSet);
			
			first = false;
			if (isSet)
			{
				isSet = ctrl.isSet;
			}
		}
	}
}

MainWindow.prototype.handleValueChange = function(event, object)
{
	try
	{
		//object.trace("value change " + event.target.id);
		object.updateValueControls();
	}
	catch (e)
	{
		object.trace("handleValueChange error: " + e);
	}
  
	object.updatePreview(); 
}

MainWindow.prototype.updatePreview = function()
{
	var command = "]]><value-of select="/prg:program/prg:name" /><![CDATA[";
	var args = this.getCommandArguments();
	this.setPreview(command + " " + args.join(" "));
}
	
MainWindow.prototype.setPreview = function(str)
{
	var ctrl = document.getElementById("commandline-preview");
	ctrl.value = str;
}

MainWindow.prototype.ExecuteObserver = function(app)
{
	this.application = app;
}

MainWindow.prototype.ExecuteObserver.prototype.observe = function(subject, topic, data)
{
	var res = true;
	var evt = document.createEvent("UIEvents");
	
	evt.initUIEvent("execute", true, true, window, 1);
	evt.executed = true;
	
	try
	{
		var process = subject.QueryInterface(Components.interfaces.nsIProcess);
		evt.exitValue = process.exitValue;
		
		if (topic == "process-failed")
		{
			alert("Failed to launch process");
			evt.executed = false;
			res = false;
		}
		else if (process.exitValue)
		{
			alert("Process exit value: " + process.exitValue);
			res = false;
		}
	}
	catch (e)
	{
		alert("Unable to get process state");
		evt.executed = false;
		res = false;
	}
	
	this.application.dispatchEvent(evt);
	return res;
}


MainWindow.prototype.execute = function()
{
	var args = this.getCommandArguments();
	var command = "]]><value-of select="/prg:program/prg:name" /><![CDATA[";
	this.setPreview(command + " " + args.join(" "));
	
	var commandPath = unescape(this.app.getApplicationPathString()) + "sh/]]><value-of select="$prg.xul.appName" /><![CDATA[.sh"; 
	this.executeCommand(commandPath, args, new this.ExecuteObserver(this));
}

MainWindow.prototype.executeCommand = function(path, args, observer)
{
	//this.trace(path + " " + args.join(""));
	
	try
	{
		// create an nsILocalFile for the executable
		var file = Components.classes["@mozilla.org/file/local;1"].createInstance(Components.interfaces.nsILocalFile);
		file.initWithPath(path);
	}
	catch (err)
	{
		this.trace("Failed to initialize process file '" + path  + "': " + err);
		return false;
	}
	
	try
	{
		// create an nsIProcess
		var process = Components.classes["@mozilla.org/process/util;1"].createInstance(Components.interfaces.nsIProcess);
		process.init(file);
	}
	catch (err)
	{
		this.trace("Failed to initialize process '" + path  + "': " + err);
		return false;
	}
	
	try
	{
		process.runAsync(args, args.length, observer);
	}
	catch (err)
	{
		this.trace("Failed to run process: " + err);
		return false;
	}
	
	
	
	
	return true;
}

MainWindow.prototype.addEventListener = function(e, h, w)
{
	window.addEventListener(e, h, w)
}

MainWindow.prototype.dispatchEvent = function(e)
{
	window.dispatchEvent(e);
}

MainWindow.prototype.removeEventListener = function(e, h, w)
{
	window.removeEventListener(e, h, w)
}

]]></template>

</stylesheet>
