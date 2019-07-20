/**
* Copyright © 2011 - 2020 by Renaud Guillard (dev@nore.fr)
* Distributed under the terms of the MIT License, see LICENSE
*/

var EXPORTED_SYMBOLS = ["FSItemSelectionDialog", "EventForwarder","NodeHelper", "AnonymousNodesHelper"];

// / File dialog box helper
function FSItemSelectionDialog(window)
{
	this.window = window;
	this.value = null;
	this.mode = "file";
	this.title = "Select a file";
	this.filters = [];
	this.filterAll = true;
	this.filterAllTitle = "All";
}

FSItemSelectionDialog.prototype.trace = function(msg)
{
	Components.classes['@mozilla.org/consoleservice;1'].getService(Components.interfaces.nsIConsoleService)
		.logStringMessage(msg);
	dump(msg + "\n");
}

FSItemSelectionDialog.prototype.importFilters = function(str)
{
	var rx = /([^\|]+)\|([^\|]+)/
	
	this.filters = [];
	var r;	
	while (r = rx.exec(str))
	{
		if (r == null)
		{
			return;
		}
		
	    this.filters.push( {name: r[1] + " (" + r[2] + ")", pattern: r[2]} );
	    
	    str = str.substring(r[0].length)
	}	
}

FSItemSelectionDialog.prototype.filePickerMode = function(fp)
{
	if (this.mode == "folder")
	{
		return fp.modeGetFolder;
	}
	else if (this.mode == "save")
	{
		return fp.modeSave;
	}
	else if (this.mode == "multi")
	{
		return fp.modeOpenMultiple;
	}
	return fp.modeOpen;
}

FSItemSelectionDialog.prototype.browse = function()
{
	var filePicker = Components.classes["@mozilla.org/filepicker;1"].createInstance(Components.interfaces.nsIFilePicker);
	var mode = this.filePickerMode(filePicker);
	filePicker.init(this.window, this.title, mode);
	
	for (var i = 0; i < this.filters.length; i++)
	{
		filePicker.appendFilter(this.filters[i].name, this.filters[i].pattern);
	}
	
	if (this.filterAll || this.filters.length == 0)
	{
		filePicker.appendFilter(this.filterAllTitle, "*");
	}
	
	var result = 
	{
		isValid: false,
		path: ""
	};
	
	try
	{
		var returnValue = filePicker.show();
		if (returnValue != filePicker.returnCancel)
		{
			if (mode == filePicker.modeOpenMultiple)
			{
				result.paths = [];
				var files = filePicker.files;
				while (files.hasMoreElements()) 
			    {
			    	var p = files.getNext().QueryInterface(Components.interfaces.nsILocalFile).path;
			        result.paths.push(p);
			    }
			}
			else
			{
				result.paths = [ filePicker.file.path ];
			}
			
			result.path = result.paths[0];
			result.isValid = true;
		}
	}
	catch (error)
	{
		this.trace(error);
	}
	
	return result;
};

// / Generic Event handler to forward a control event to a specific object
function EventForwarder(object, method)
{
	this.object = object;
	this.method = method;
}

EventForwarder.prototype.handleEvent = function(event)
{
	this.method(event, this.object);
}

function NodeHelper()
{
}

NodeHelper.prototype.enableNode = function (node, enabled, recursive)
{
	try
	{
		/*
		Components.classes['@mozilla.org/consoleservice;1'].getService(Components.interfaces.nsIConsoleService)
		.logStringMessage("enableNode " + node.localName + "("  + node.getAttribute("class") + ") " + enabled + " " + recursive);
		*/
		
		if (enabled)
		{
			node.disabled = false;
			//node.removeAttribute("disabled");
		}
		else
		{
			//node.setAttribute("disabled", true);
			node.disabled = true;
		}
		
		if (recursive)
		{
			this.enableChildren(node, enabled, true);
		}
	}
	catch(e)
	{
		Components.classes['@mozilla.org/consoleservice;1'].getService(Components.interfaces.nsIConsoleService).logStringMessage("enableNode " + e);
	}
}

NodeHelper.prototype.enableChildren = function (root, enabled, recursive)
{
	try
	{
		for (var i = 0; i < root.children.length; i++)
		{
			this.enableNode(root.children[i], enabled, recursive);
		}
	}
	catch(e)
	{
		Components.classes['@mozilla.org/consoleservice;1'].getService(Components.interfaces.nsIConsoleService).logStringMessage("enableChildren " + e);
	}
}

NodeHelper.prototype.showOnly = function(nodes, index)
{
	for (var i = 0; i < nodes.length; i++)
	{
		var n = nodes[i];
		if (n == null)
		{
			dump("NodeHelper.showOnly: invalid index " + i + "\n");
		}
		if (i != index)
		{
			//n.setAttribute("disabled", true);
			n.disabled = true;
			n.setAttribute("hidden", true);
		}
		else
		{
			n.disabled = false;
			//n.removeAttribute("disabled");
			n.removeAttribute("hidden");
		}
	}
}

// / Anonymous controls manipulation
function AnonymousNodesHelper(doc, control)
{
	this.document = doc;
	this.control = control;
	this.nodes = this.document.getAnonymousNodes(this.control);
}

AnonymousNodesHelper.prototype.showOnly = function(index)
{
	for (var i = 0; i < this.nodes.length; i++)
	{
		var n = this.nodes[i];
		if (i != index)
		{
			//n.setAttribute("disabled", true);
			n.disabled = true;
			n.setAttribute("hidden", true);
		}
		else
		{
			n.disabled = false;
			//n.removeAttribute("disabled");
			n.removeAttribute("hidden");
		}
	}
}
