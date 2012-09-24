/**
 * Copyright (c) 2011 by Renaud Guillard (dev@niao.fr)
 * Distributed under the terms of the BSD License, see LICENSE 
 */

function onInitialize(mw, app)
{
	var optionId = mw.getOptionIdByName("output");
	if (optionId)
	{
		var optionValueControl = document.getElementById(optionId + ":value");
		if (optionValueControl)
		{
			var appUri = app.getApplicationURI();
			if (optionValueControl.value.length == 0 && appUri)
			{
				var file = Components.classes["@mozilla.org/file/local;1"].createInstance(Components.interfaces.nsILocalFile);
				file.initWithPath(appUri.path);
							
				optionValueControl.value = (file.parent) ? file.parent.path : file.path;	
			}			 
		}
	}
}