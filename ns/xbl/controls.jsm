/**
* Copyright (c) 2011 by Renaud Guillard (dev@niao.fr)
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
	/*Components.classes['@mozilla.org/consoleservice;1'].getService(Components.interfaces.nsIConsoleService)
	.logStringMessage("mode " + this.mode);*/
	if (this.mode == "folder")
	{
		return fp.modeGetFolder;
	}
	else if (this.mode == "save")
	{
		return fp.modeSave;
	}
	return fp.modeOpen;
}

FSItemSelectionDialog.prototype.browse = function()
{
	var filePicker = Components.classes["@mozilla.org/filepicker;1"].createInstance(Components.interfaces.nsIFilePicker);
	filePicker.init(this.window, this.title, this.filePickerMode(filePicker));
	
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
			result.isValid = true;
			result.path = filePicker.file.path;
		}
	}
	catch (error)
	{
		alert(error);
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
			node.removeAttribute("disabled");
		}
		else
		{
			node.setAttribute("disabled", true);
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
			n.setAttribute("disabled", true);
			n.setAttribute("hidden", true);
		}
		else
		{
			n.removeAttribute("disabled");
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
			n.setAttribute("disabled", true);
			n.setAttribute("hidden", true);
		}
		else
		{
			n.removeAttribute("disabled");
			n.removeAttribute("hidden");
		}
	}
}
