"""Parser and parser result"""
from InfoBase import *

class State:
    Undef = 0
    EndOfOptions = 1
    GluedValue = 2
    SkipArgument = 3
    ArgumentExpected = 4
   
class Context:
    state = None
    "State flags"
    option = None
    "Current option reference"
    option_name = None
    "Current option name (without minus sign(s))"
    option_args = None
    "current options arguments"
    subcommand = None
    skip_count = 0
    issues = None
    
    def __init__(self):
        self.state = State.Undef
        self.option = None
        self.option_name = ""
        self.option_args = []
        self.subcommand = None
        self.skip_count = 0
        self.issues = {"debug": [], "notice": [], "warnings": [], "errors": []}
            
    def unset_current_option(self):
        self.option = None
        self.option_name = ""
        
    def set_argument_skipping(self, b, count):
        if b:
            self.state |= State.SkipArgument
            self.skip_count = count
        else:
            self.state &= ~State.SkipArgument
            self.skip_count = 0
        
    def skip_argument(self):
        self.skip_count = self.skip_count - 1
        if self.skip_count == 0:
            self.state &= ~State.SkipArgument
    
    @property
    def cli_option_name(self):
        """Current option name as it appears on the command line"""
        return InfoUtil.cli_option_name(self.option_name)
    
    def add_issue(self, level, message):
        if level == "fatalerror":
            print "Fatal error: " + message
            return   
        self.issues[level].append(message)
        
    def debug(self, message):
        self.add_issue("debug", message)
        
    def notice(self, message):
        self.add_issue("notices", message)
        
    def warning(self, message):
        self.add_issue("warnings", message)
        
    def error(self, message):
        self.add_issue("errors", message) 
 
class OptionResultContainer:
    """A dynamic class where each attribute is an option result"""
    pass
   
class ParserResultUtil:
    @classmethod
    def get_option_attr(self, o):
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
    def set_options(self, e, options, root = None):
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

class GroupOptionResult:
    """A special class to represent a group option result"""
    
    def __init__(self, info, root):
        self.__options = OptionResultContainer()
        self.__is_set = info.present
        ParserResultUtil.set_options(self.__options, info.options, root)
        if info.type == GroupOptionType.Exclusive:
            setattr(self, "selected_option", info.selected_option)
            if isinstance(info.selected_option, OptionInfo):
                setattr(self, "selected_option_name", ParserResultUtil.get_option_attr(info.selected_option))
                    
    @property
    def options(self):
        """Option results"""
        return self.__options
    
    @property
    def is_set(self):
        """Indicates if at least one option of the group was present on the commnad line"""
        return self.__is_set
                             
class SubcommandResult:
    __name = None
    __options = None
    
    def __init__(self, info):
        self.__name = info.name
        
    @property
    def name(self):
        return self.__name
    
class ParserResult:
    __issues = None
    __subcommand = None
    __options = None
    __values = None
    
    def __init__(self, context, info):
        self.__issues = context.issues
        self.__options = OptionResultContainer()
        ParserResultUtil.set_options(self.options, info.options)
        self.__values = info.values 
        
        if isinstance(context.subcommand, SubcommandInfo):
            self.__subcommand = SubcommandResult(context.subcommand)
              
    @property
    def issues(self):
        return self.__issues
    
    @property
    def values(self):
        return self.__values
    
    @property
    def subcommand(self):
        return self.__subcommand
    
    @property
    def options(self):
        return self.__options
        
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
              
                        
        elif (context.subcommand == None):
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
                        context.unset_current_option()
                        if isinstance(context.option, ArgumentOptionInfo):
                            context.set_argument_skipping(True, 1)
                        elif isinstance(context.option, MultiArgumentOptionInfo):
                            context.set_argument_skipping(True, -1)
                else:
                    context.debug(" Option " + option + " not found in " + str(programInfo.option_names.keys()))
                                
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
                                    context.set_argument_skipping(True, -1)
                                context.unset_current_option()
                            "Forget remaining characters in any case"
                            break
                    else:
                        context.error("Invalid option name -" + option)
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
           
        return ParserResult(context, programInfo)   
                    
                            
