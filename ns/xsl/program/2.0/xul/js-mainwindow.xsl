<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Javascript code base of a xul application based on program interface definition schema -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">

	<xsl:import href="../../../languages/javascript.xsl" />
	<xsl:import href="base.xsl" />
		
	<xsl:output method="text" encoding="utf-8" />
	
	<xsl:template match="text()">
		<xsl:value-of select="normalize-space(.)" />
	</xsl:template>
	
	<xsl:template match="prg:name">
		<xsl:value-of select="normalize-space(.)" />
	</xsl:template>

	<xsl:template name="prg.xul.optionSpecs">
		<xsl:param name="optionNode" select="." />
		<xsl:variable name="exclusiveGroup" select="$optionNode/../../self::prg:group[@type = 'exclusive']" />
		<xsl:text>type: "</xsl:text>
		<xsl:call-template name="str.elementLocalPart">
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
		<xsl:text>", parent: </xsl:text>
		<xsl:choose>
			<xsl:when test="$optionNode/../../self::prg:group">
				<xsl:text>"</xsl:text>
				<xsl:call-template name="prg.optionId">
					<xsl:with-param name="optionNode" select="$optionNode/../../self::prg:group" />
				</xsl:call-template>
				<xsl:text>"</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>null</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>, optionName: </xsl:text>
		<xsl:choose>
			<xsl:when test="$optionNode/prg:names/prg:long">
				<xsl:text>"--</xsl:text>
				<xsl:value-of select="$optionNode/prg:names/prg:long[1]" />
				<xsl:text>"</xsl:text>
			</xsl:when>
			<xsl:when test="$optionNode/prg:names/prg:short">
				<xsl:text>"-</xsl:text>
				<xsl:value-of select="$optionNode/prg:names/prg:short[1]" />
				<xsl:text>"</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>null</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>, uiMode: </xsl:text>
		<xsl:choose>
			<xsl:when test="$optionNode/prg:ui/@mode">
				<xsl:text>"</xsl:text>
				<xsl:value-of select="$optionNode/prg:ui/@mode" />
				<xsl:text>"</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				"default"
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>, hiddenValue: </xsl:text>
		<xsl:choose>
			<xsl:when test="$optionNode/prg:ui/prg:value">
				<xsl:text>"</xsl:text>
				<xsl:value-of select="$optionNode/prg:ui/prg:value" />
				<xsl:text>"</xsl:text>
			</xsl:when>
			<xsl:when test="$optionNode/prg:ui/prg:values">
				<xsl:text>[</xsl:text>
				<xsl:for-each select="$optionNode/prg:ui/prg:values">
					<xsl:text>"</xsl:text>
					<xsl:value-of select="prg:value" />
					<xsl:text>"</xsl:text>
					<xsl:if test="position() != last()">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:for-each>
				<xsl:text>]</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				null
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Main  -->
	<xsl:template match="/"><![CDATA[
function MainWindow(app)
{
	this.app = app;
	
	this.globalId = "::global::";
	
	this.options = 
	{
		"::global::" : 
		{
]]><xsl:for-each select="prg:program/prg:options/* | prg:program/prg:options//prg:options/*">
		<xsl:text>			"</xsl:text>
		<xsl:call-template name="prg.optionId" />
		<xsl:text>": {</xsl:text>
		<xsl:call-template name="prg.xul.optionSpecs" />
		<xsl:text>}</xsl:text>
		<xsl:if test="position() != last()">
			<xsl:text>,</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>
	</xsl:for-each><![CDATA[
		}]]><xsl:if test="/prg:program/prg:subcommands">
		<xsl:text>,</xsl:text>
		<xsl:value-of select="$str.endl" />
	</xsl:if>
		<xsl:for-each select="/prg:program/prg:subcommands/prg:subcommand">
			<xsl:text>		"</xsl:text>
			<xsl:apply-templates select="prg:name" />
			<xsl:text>":</xsl:text>
			<xsl:value-of select="$str.endl" />
			<xsl:text>		{</xsl:text>
			<xsl:value-of select="$str.endl" />
			<xsl:for-each select="prg:options/* | prg:options//prg:options/*">
				<xsl:text>			"</xsl:text>
				<xsl:call-template name="prg.optionId" />
				<xsl:text>": {</xsl:text>
				<xsl:call-template name="prg.xul.optionSpecs" />
				<xsl:text>}</xsl:text>
				<xsl:if test="position() != last()">
					<xsl:text>,</xsl:text>
					<xsl:value-of select="$str.endl" />
				</xsl:if>
			</xsl:for-each>
			<xsl:value-of select="$str.endl" />
			<xsl:text>		}</xsl:text>
			<xsl:if test="position() != last()">
				<xsl:text>,</xsl:text>
				<xsl:value-of select="$str.endl" />
			</xsl:if>
		</xsl:for-each><![CDATA[
	};
	
	this.values = 
	{
		"::global::" : 
		[
]]><xsl:for-each select="/prg:program/prg:values/*">
		<xsl:text>			"</xsl:text>
		<xsl:call-template name="prg.xul.valueId">
			<xsl:with-param name="valueNode" select="." />
			<xsl:with-param name="index" select="position()" />
		</xsl:call-template>
		<xsl:text>"</xsl:text>
		<xsl:if test="position() != last()">
			<xsl:text>,</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>
	</xsl:for-each><![CDATA[
		]]]><xsl:if test="/prg:program/prg:subcommands">
		<xsl:text>,</xsl:text>
		<xsl:value-of select="$str.endl" />
	</xsl:if>
		<xsl:for-each select="/prg:program/prg:subcommands/prg:subcommand">
			<xsl:text>		"</xsl:text>
			<xsl:apply-templates select="prg:name" />
			<xsl:text>":</xsl:text>
			<xsl:value-of select="$str.endl" />
			<xsl:text>		[</xsl:text>
			<xsl:value-of select="$str.endl" />
			<xsl:for-each select="prg:values/*">
				<xsl:text>			"</xsl:text>
				<xsl:call-template name="prg.xul.valueId">
					<xsl:with-param name="index" select="position()" />
				</xsl:call-template>
				<xsl:text>"</xsl:text>
				<xsl:if test="position() != last()">
					<xsl:text>,</xsl:text>
					<xsl:value-of select="$str.endl" />
				</xsl:if>
			</xsl:for-each>
			<xsl:value-of select="$str.endl" />
			<xsl:text>		]</xsl:text>
			<xsl:if test="position() != last()">
				<xsl:text>,</xsl:text>
				<xsl:value-of select="$str.endl" />
			</xsl:if>
		</xsl:for-each><![CDATA[
	};
	
	this.optionNames = 
	{
		"::global::" : 
		{
]]><xsl:for-each select="prg:program/prg:options/*/prg:names/* | prg:program/prg:options//prg:options/*/prg:names/*">
		<xsl:text>			"</xsl:text>
		<xsl:value-of select="." />
		<xsl:text>": "</xsl:text>
		<xsl:call-template name="prg.optionId">
			<xsl:with-param name="optionNode" select="../.." />
		</xsl:call-template>
		<xsl:text>"</xsl:text>
		<xsl:if test="position() != last()">
			<xsl:text>,</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>
	</xsl:for-each><![CDATA[
		}]]><xsl:if test="/prg:program/prg:subcommands">
		<xsl:text>,</xsl:text>
		<xsl:value-of select="$str.endl" />
	</xsl:if>
		<xsl:for-each select="/prg:program/prg:subcommands/prg:subcommand">
			<xsl:text>		"</xsl:text>
			<xsl:apply-templates select="prg:name" />
			<xsl:text>":</xsl:text>
			<xsl:value-of select="$str.endl" />
			<xsl:text>		{</xsl:text>
			<xsl:value-of select="$str.endl" />
			<xsl:for-each select="prg:options/*/prg:names/* | prg:options//prg:options/*/prg:names/*">
				<xsl:text>			"</xsl:text>
				<xsl:value-of select="." />
				<xsl:text>": "</xsl:text>
				<xsl:call-template name="prg.optionId">
					<xsl:with-param name="optionNode" select="../.." />
				</xsl:call-template>
				<xsl:text>"</xsl:text>
				<xsl:if test="position() != last()">
					<xsl:text>,</xsl:text>
					<xsl:value-of select="$str.endl" />
				</xsl:if>
			</xsl:for-each>
			<xsl:value-of select="$str.endl" />
			<xsl:text>		}</xsl:text>
			<xsl:if test="position() != last()">
				<xsl:text>,</xsl:text>
				<xsl:value-of select="$str.endl" />
			</xsl:if>
		</xsl:for-each><![CDATA[	
	};
	
	this.subCommand = null;
	
	this.globalValueCount = ]]><xsl:choose>
		<xsl:when test="/prg:program/prg:values">
			<xsl:value-of select="count(/prg:program/prg:values/prg:value)" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>0</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
		<xsl:text>;</xsl:text><![CDATA[
	
	Components.utils.import("resource://ns/xbl/controls.jsm");	
	this.optionChangeEventListener = new EventForwarder (this, this.handleOptionChange);
	this.valueChangeEventListener = new EventForwarder (this, this.handleValueChange);
	
	this.status = "default";
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
		this.updateValueControls(g, true);
	}
	
	// Load user-defined post initialization
	var onInitializeURI = "chrome://]]><xsl:value-of select="$prg.xul.appName" /><![CDATA[/content/]]><xsl:value-of select="$prg.xul.appName" /><![CDATA[-user.js";
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
]]><xsl:if test="$prg.debug"><![CDATA[dump(str + ((e) ? "" : "\n"));]]></xsl:if><![CDATA[
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


MainWindow.prototype.setControlEnabled = function(v)
{
	
	var uiElementIds = ["prg.xul.ui.subcommandList", "prg.xul.ui.executuiElement"];
	for (var i in uiElementIds)
	{
		var uiElement = document.getElementById(uiElementIds[i]);
		if (uiElement)
		{
			uiElement.disabled = !v;
		}	
	}
	
	var suffixes = ["", ":value", ":value:fsbutton", ":value:proxy", ":value:input" ];
	
	for (var g in this.options)
	{
		var gs = this.options[g];
		for (var id in gs)
		{
			var specs = gs[id];
			if (specs.uiMode == "default")
			{
				for (var s in suffixes)
				{
					var option = document.getElementById(id + suffixes[s]);
					if (option)
					{
						option.disabled = !v;
					}	
				}
			}
		}
	}
	
	this.updateValueControls(null, v);
}

MainWindow.prototype.enable = function(newStatus)
{
	if (newStatus)
	{
		this.status = newStatus;
	}
	
	this.setControlEnabled(true)
}

MainWindow.prototype.disable = function(newStatus)
{
	if (newStatus)
	{
		this.status = newStatus;
	}
	
	this.setControlEnabled(false)
}

MainWindow.prototype.addInputToMultiValue = function(baseId, sourceElement)
{
	var source = sourceElement ? sourceElement : document.getElementById(baseId + ":input");
	var target = document.getElementById(baseId + ":proxy");
	if (source.values)
	{
		for (var i in source.values)
		{
			if (source.values[i].length)
			{
				target.addElement(source.values[i]);
			}
		}
	}
	else if (source.value && source.value.length)
	{
		target.addElement(source.value);
	}
}

MainWindow.prototype.RebuildObserver = function(mw)
{
	this.mainWindow = mw;
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
	var commandPath = this.app.getApplicationPath() + "sh/_rebuild.sh"; 
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
		// Allways add 'end-of-option-arg' marker
		result.push("-");
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
		var o = event.target;
		//object.trace("handleOptionChange: " + o.id + " ("+o.isSet+")");
		if (o.optionType == "group")
	  	{
	  		if (!o.isSet)
	  		{
	  			var radioGroupId = o.id + ":group";
	  			//object.trace("handleOptionChange get " + radioGroupId); 
	  			var radioGroup = document.getElementById(radioGroupId);
	  			radioGroup.selectedIndex = -1;
	  		}
		}
		
		//object.trace("handleOptionChange parent:" + o.parent);
				
		if (o.parent)
		{
			//object.trace("handleOptionChange: activate parent:" + o.parent.id);
			o.parent.set(true);
		}
	}
	catch (e)
	{
		//object.trace("handleOptionChange error: " + e);
	}
  
	object.updatePreview(); 
}

MainWindow.prototype.updateValueControls = function(group, enabled)
{
	var g = (group) ? group : ((this.subcommand) ? this.subcommand : this.globalId);
	//this.trace("Update values of group " + g);
	var groupIds = this.values[g];
	var isSet = enabled;
	for (var index in groupIds)
	{
		var id = groupIds[index];
		var ctrl = document.getElementById(id);
		if (ctrl)
		{
			ctrl.removeEventListener("change", this.valueChangeEventListener, true);
			
			//this.trace("set " + ctrl.id + " " + isSet);
			this.setRowEnabled(ctrl, isSet);
			
			if (isSet)
			{
				isSet = ctrl.isSet;
			}
			
			ctrl.addEventListener("change", this.valueChangeEventListener, true);
		}
	}
}

MainWindow.prototype.handleValueChange = function(event, object)
{
	try
	{
		//object.trace("value change " + event.target.id);
		object.updateValueControls(null, true);
	}
	catch (e)
	{
		//object.trace("handleValueChange error: " + e);
	}
  
	object.updatePreview(); 
}

MainWindow.prototype.updatePreview = function()
{
	var command = "]]><xsl:apply-templates select="/prg:program/prg:name" /><![CDATA[";
	var args = this.getCommandArguments();
	this.setPreview(command + " " + args.join(" "));
}
	
MainWindow.prototype.setPreview = function(str)
{
	var ctrl = document.getElementById("commandline-preview");
	ctrl.value = str;
}

MainWindow.prototype.ExecuteObserver = function(mw)
{
	this.mainWindow = mw;
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
		evt.mainWindow = this.mainWindow;
		evt.application = this.mainWindow.app;		
		
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
	
	this.mainWindow.dispatchEvent(evt);
	
	this.mainWindow.enable("default");
	
	return res;
}


MainWindow.prototype.execute = function()
{
	if (this.status == "execute")
	{
		return;
	}
	this.disable("execute");
	
	var args = this.getCommandArguments();
	var command = "]]><xsl:apply-templates select="/prg:program/prg:name" /><![CDATA[";
	this.setPreview(command + " " + args.join(" "));
	
	var commandPath = this.app.getApplicationPath() + "sh/]]><xsl:value-of select="$prg.xul.appName" /><![CDATA["; 
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
		this.enable("default");
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
		this.enable("default");
		return false;
	}
	
	try
	{
		process.runAsync(args, args.length, observer);
	}
	catch (err)
	{
		this.trace("Failed to run process: " + err);
		this.enable("default");
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

]]></xsl:template>

</xsl:stylesheet>
