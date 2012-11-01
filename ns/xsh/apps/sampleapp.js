/**
 * Copyright (c) 2011 by Renaud Guillard (dev@niao.fr)
 * Distributed under the terms of the BSD License, see LICENSE
 */

function UiExtension() 
{
	this.ui = null;
	this.app = null;
}

UiExtension.prototype.onExecute = function(evt)
{
	try
	{
		if (evt.executed && evt.exitValue == 0 && confirm("Quit ?"))
		{
			this.app.quitApplication();
		}
	}
	catch(e)
	{
		this.mw.trace(e)
	}
}

UiExtension.prototype.ExecuteEventHandler = function(o)
{
	this.uix = o;
}

UiExtension.prototype.ExecuteEventHandler.prototype.handleEvent = function(e)
{
	this.uix.onExecute(e);
}

var uix = new UiExtension();

function onInitialize(mw, app)
{
	uix.mw = mw;
	uix.app = app;
	mw.addEventListener("execute", new uix.ExecuteEventHandler(uix), false);
}