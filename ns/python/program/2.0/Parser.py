# -*- coding: utf-8 -*-
""" Copyright © 2012 by Renaud Guillard """
""" Distributed under the terms of the MIT License, see LICENSE """

""" Parser and parser result """

from Info import *
from Base import *
import textwrap
 
class OptionResultContainer:
    """A dynamic class where each attribute is an option result"""
    pass
   
class ParserResultUtil:
    
    @classmethod
    def get_option_attr(cls, o):
        """Return the name of the variable in a parser result"""
        if len(o.varname) > 0:
            return o.varname
        elif len(o.long_names) > 0:
            return o.long_names[0].replace("-", "_")
        elif len(o.short_names) > 0:
            return o.short_names[0]
        else:
            return None

    @classmethod
    def set_options(cls, e, options, root = None):
        """Fill the OptionResultContainer instance""" 
        r = root
        if r == None:
            r = e;
        
        for o in options:
            attr = ParserResultUtil.get_option_attr(o)
            value = None
            if isinstance(o, SwitchOptionInfo):
                value = bool(o.value)
            if isinstance(o, ArgumentOptionInfo):
                value = o.value
            if isinstance(o, MultiArgumentOptionInfo):
                value = o.value
            if isinstance(o, GroupOptionInfo):
                value = GroupOptionResult(o, r)

            if (attr != None):
                setattr(e, attr, value)
                if (r != e):
                    setattr(r, attr, value)

    UsageIndentText = "\t"

    @classmethod
    def format(cls, text, level = 1, subsequent_level = 1):
        return textwrap.fill(text, width=80, initial_indent = cls.UsageIndentText * level, subsequent_indent = cls.UsageIndentText * subsequent_level)
    
    @classmethod
    def option_usage(cls, optionInfo, level = 1, usageFlags = Usage.AllInfos):
        isRaw = (usageFlags & Usage.Raw)
        msg = ""
        abstract = ((usageFlags & Usage.Abstract) == Usage.Abstract)
        details =  ((usageFlags & Usage.Details) == Usage.Details)
        if (abstract):
            tmp = optionInfo.documentation.abstract
            if not isRaw and len(optionInfo.documentation.option_names):
                tmp = optionInfo.documentation.option_names + ": " + tmp
            if len(tmp) > 0:
                msg = msg + cls.format(tmp, level, level + 1) + "\n"
            
        if (details):
            msg = msg + str(usageFlags) + " " + str(Usage.Details) 
            if (len(optionInfo.documentation.value_description)):
                for t in optionInfo.documentation.value_description.splitlines():
                    if len(t) > 0:
                        msg = msg + cls.format(t, level + 1, level + 2) + "\n"
                        
            tmp = optionInfo.documentation.details
            if len(tmp) > 0:
                msg = msg + cls.format(tmp, level + 1, level + 1) + "\n"
        
        if isinstance(optionInfo, GroupOptionInfo):
            for o in optionInfo.options:
                msg = msg + cls.option_usage(o, level + 1, usageFlags)
                
        return msg
    
    @classmethod
    def usage(cls, programInfo, result, usageFlags = Usage.AllInfos):
        """ Return the program usage string """
        msg = ""
        isSubcommand = isinstance(result, ParserResult) and result.subcommand
        isRaw = (usageFlags & Usage.Raw)
        abstract = ((usageFlags & Usage.Abstract) == Usage.Abstract)
        details =  ((usageFlags & Usage.Details) == Usage.Details) 
        info = programInfo
        if isSubcommand:
            info = programInfo.subcommand_names[result.subcommand.name]
        
        if not isRaw:
            msg = programInfo.name
            if isSubcommand:
                msg = msg + " " + result.subcommand.name
            if (len(info.documentation["abstract"]) > 0):
                msg = msg + ": " + str(info.documentation["abstract"])
            msg = msg + "\n"
            
            if (usageFlags & Usage.Inline):
                msg = msg + "Usage:\n" + cls.UsageIndentText
                if isSubcommand:
                    msg = msg + programInfo.name + " " 
                msg = msg + info.name + " " 
        
        if (usageFlags & Usage.Inline):
            msg = msg + info.usage["inline"]
            
        if (abstract):
            if not isRaw:
                msg = msg + "with:\n"
                
            for o in info.options:
                msg = msg + cls.option_usage(o, 1, usageFlags)
        
        if isSubcommand:
            if not isRaw and (abstract):
                msg = msg + "Global options:\n"
                for o in programInfo.options:
                    msg = msg + cls.option_usage(o, 1, usageFlags)
            
        return msg

class GroupOptionResult:
    """A special class to represent a group option result"""
    
    def __init__(self, info, root):
        self.options = OptionResultContainer()
        self.is_set = info.present
        ParserResultUtil.set_options(self.options, info.options, root)
        if info.type == GroupOptionType.Exclusive:
            if isinstance(info.selected_option, OptionInfo):
                attr = ParserResultUtil.get_option_attr(info.selected_option)
                setattr(self, "selected_option", getattr(self.options, attr))
                setattr(self, "selected_option_name", attr)
            else:
                setattr(self, "selected_option", None)
                setattr(self, "selected_option_name", "")
                             
class SubcommandResult:
    def __init__(self, info):
        self.name = info.name
        self.options = OptionResultContainer()
        ParserResultUtil.set_options(self.options, info.options)
         
class ParserResult:
    def __init__(self, context, info):
        self.issues = context.issues
        self.options = OptionResultContainer()
        ParserResultUtil.set_options(self.options, info.options)
        self.values = info.values
        self.subcommand = None 
        
        if isinstance(context.subcommand, SubcommandInfo):
            self.subcommand = SubcommandResult(context.subcommand)
              
    @property
    def is_valid(self):
        return (len(self.issues["errors"]) == 0)
        
class Parser:
    
    def get_option(self, programInfo, context, arg):
        o = None
        if isinstance(context.subcommand, SubcommandInfo):
            o = context.subcommand.option_names.get(arg, None)
            
        if not isinstance(o, OptionInfo):
            o = programInfo.option_names.get(arg, None)
            
        return o
        
    def get_subcommand(self, programInfo, context, arg):
        """Get the subcommand associated with the given name"""
        return programInfo.subcommand_names.get(arg, None)
    
    def process_value(self, programInfo, context, arg):
        "Process value, option argument or subocmment depending on context"
        if isinstance(context.option, OptionInfo):
            context.debug("Treat '" + str(arg) + "' as " + context.cli_option_name + " argument " + str(context.option))
            if context.option.validate(context, arg):
                if isinstance(context.option, SwitchOptionInfo):
                    context.debug(" Set switch")
                    context.option.set_value(True)
                    context.unset_current_option()
                elif isinstance(context.option, ArgumentOptionInfo):
                    context.debug(" Set value " + str(arg) + " to option " + context.cli_option_name)
                    context.option.set_value(arg)
                    context.unset_current_option() 
                elif isinstance(context.option, MultiArgumentOptionInfo):
                    if context.option.append_value(arg):
                        context.option_args.append(arg)
                    else:
                        context.debug(" Can't add value " + arg + " to option " + context.cli_option_name + " max reached ?")
                        context.unset_current_option()
                        programInfo.values.append(arg)
              
            else:
                context.debug("Failed to validate")
                if isinstance(context.option, ArgumentOptionInfo):
                    context.unset_current_option()
                    
        elif (context.subcommand == None and (len(programInfo.values) == 0)):
            context.debug(" Attempt to get subcommand")
            context.subcommand = self.get_subcommand(programInfo, context, arg)
            if context.subcommand == None:
                context.debug(" Treat as value")
                programInfo.values.append(arg)
        else:
            context.debug("Add as value")
            programInfo.values.append(arg)
        
        if (arg != None) and len(arg) > 0:
            context.state &= ~State.ArgumentExpected
                     
    def parse(self, programInfo, argv):
        context = Context()
                
        for index in range(len(argv)):
            arg = argv[index]
            context.debug("Processing command line argument: " + arg)
            
            context.state &= ~State.GluedValue
                        
            if (context.state & State.EndOfOptions):
                context.debug("value (forced - EndOfOptions)" + arg)
                programInfo.values.append(arg)
                continue
            elif (arg == "--"):
                context.debug("End of options")
                context.state |= State.EndOfOptions
                if context.option:
                    if isinstance(context.option, ArgumentOptionInfo):
                        if context.option.value == None or len(context.option.value) == 0:
                            context.error("Missing argument for option " + context.cli_option_name)
                    if isinstance(context.option, MultiArgumentOptionInfo):
                        if len(context.option_args) == 0:
                            context.error("Missing argument(s) for option " + context.cli_option_name)
                            
                context.unset_current_option()
                context.set_argument_skipping(False, 0)
                continue
            elif (arg == "-"):
                context.debug("end of option argument(s)")
                context.unset_current_option()
                context.set_argument_skipping(False, 0)
            elif (len(arg) >= 2) and (arg[0:2] == "\\-"):
                context.debug("escaped value")
                if (context.state & State.SkipArgument):
                    context.debug("Skip value, subcommand or option arg")
                    context.skip_argument()
                else:
                    context.debug("Process Value, subcommand or option arg")
                    self.process_value(programInfo, context, arg[1:len(arg)])
                continue
            elif (context.state & State.ArgumentExpected):
                context.debug("argument (forced - ArgumentExpected)" + arg)
                self.process_value(programInfo, context, arg)
                continue
            elif (len(arg) > 2) and (arg[0:2] == "--"):
                context.debug("Long option")
                context.set_argument_skipping(False, 0)
                context.unset_current_option()
                
                option = arg[2:len(arg)]
                value = None
                equalSignIndex = option.find("=");
                
                if equalSignIndex > 0:
                    value = option[equalSignIndex + 1:len(option)]
                    option = option[0:equalSignIndex]
                    context.state |= State.GluedValue
                else:
                    context.debug(" No glued value")
                                            
                context.option = self.get_option(programInfo, context, option)
                if isinstance(context.option, OptionInfo):
                    context.option_name = option
                    context.debug(" Found valid option " + option)
                    if context.option.validate_presence(context):
                        if isinstance(context.option, ArgumentOptionInfo) or isinstance(context.option, MultiArgumentOptionInfo):
                            context.state |= State.ArgumentExpected
                        if ((value != None) and (len(value) >= 0)) or isinstance(context.option, SwitchOptionInfo): 
                            self.process_value(programInfo, context, value)
                    else:
                        if isinstance(context.option, ArgumentOptionInfo):
                            context.set_argument_skipping(True, 1)
                        elif isinstance(context.option, MultiArgumentOptionInfo):
                            "Skip one argument or more ?"
                            """context.set_argument_skipping(True, -1)"""
                            context.set_argument_skipping(True, 1)
                        context.unset_current_option()
                else:
                    context.error("Invalid option name " + Util.cli_option_name(option))
                                
            elif (len(arg) > 1 and (arg[0] == "-")):
                tail = arg[1:len(arg)]
                context.set_argument_skipping(False, 0)
                context.debug("Short option(s) " + tail)
                
                while (len(tail) > 0):
                    option = tail[0]
                    tail = tail[1:len(tail)]
                    context.option = self.get_option(programInfo, context, option)
                    if isinstance(context.option, OptionInfo):
                        context.option_name = option
                        context.debug(" option=" + option)
                        context.debug(" tail=" + tail)
                        if isinstance(context.option, SwitchOptionInfo):
                            if context.option.validate_presence(context):
                               self.process_value(programInfo, context, None)
                            else:
                                "just forget this switch option"
                                context.unset_current_option()
                        elif isinstance(context.option, ArgumentOptionInfo) or isinstance(context.option, MultiArgumentOptionInfo):
                            if context.option.validate_presence(context):
                                context.state |= State.ArgumentExpected
                                if len(tail) > 0:
                                    self.process_value(programInfo, context, tail)
                            else:
                                if isinstance(context.option, ArgumentOptionInfo) and len(tail) == 0:
                                    "Ignore the next argument"
                                    context.set_argument_skipping(True, 1)
                                elif isinstance(context.option, MultiArgumentOptionInfo):
                                    "Ignore all subsequent arguments (until a new option is found)"
                                    "Skip one argument or more ?"
                                    """context.set_argument_skipping(True, -1)"""
                                    context.set_argument_skipping(True, 1)
                                context.unset_current_option()
                            "Forget remaining characters in any case"
                            break
                    else:
                        context.error("Invalid option name " + Util.cli_option_name(option))
                        break
            
            else:
                if (context.state & State.SkipArgument):
                    context.debug("Skip value, subcommand or option arg")
                    context.skip_argument()
                else:
                    context.debug("Process Value, subcommand or option arg")
                    self.process_value(programInfo, context, arg)
                
        if isinstance(context.option, ArgumentOptionInfo):
            if context.option.value == None:
                context.error("Missing argument for option " + context.cli_option_name)
                
        if isinstance(context.option, MultiArgumentOptionInfo):
            if len(context.option.value) == 0:
                context.error("Missing argument(s) for option " + context.cli_option_name)
                
        for o in programInfo.options:
            if o.required and not o.present:
                context.error("Option " + Util.cli_option_name(o.default_name) + " is required")
            if isinstance(o, MultiArgumentOptionInfo) and o.present:
                if len(o.value) < o.min:
                    context.error("No enough argument given to " + Util.cli_option_name(o.default_name))
                
        if isinstance(context.subcommand, SubcommandInfo):
            for o in context.subcommand.options:
                if o.required and not o.present:
                    context.error("Option " + Util.cli_option_name(o.default_name) + " of " + context.subcommand.name +  " subcommand is required")
           
        return ParserResult(context, programInfo)   
