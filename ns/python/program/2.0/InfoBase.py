""" Program options and subcommand infos """
from Validators import *

class InfoUtil:
    @classmethod
    def cli_option_name(self, name):
        """Current option name as it appears on the command line"""
        if (name == None) or (len(name) == 0):
            return ""
        elif len(name) == 1:
            return "-" + name
        return "--" + name

class OptionInfo:
        
    def __init__(self, var=None):
        self.varname = var
        self.value = None
        self.owner = None
        self.present = False
        self.short_names = []
        self.long_names = []
        self.validators = []
        
    def set_names(self, option_names=()):
        for n in option_names:
            if len(n) > 1:
                self.long_names.append(n)
            else:
                self.short_names.append(n)
                
    def validate_presence(self, context):
        "Check if the option can be present at this time"
        owner = self.owner
        child = self
        while isinstance(owner, GroupOptionInfo):
            if owner.present and (owner.type == GroupOptionType.Exclusive): 
                if (owner.selected_option != child):
                    context.error("Option " + context.cli_option_name + " can't be set due to exclusive group rule")
                    return False
            child = owner 
            owner = owner.owner
            
        return True

    def set_value(self, value):
        self.value = value
        self.set_present()

    def set_present(self, fromOption=None):
        self.present = True
        if self.owner:
            self.owner.set_present(self)

    def validate(self, context, value):
        for v in self.validators:
            if not v.validate(self, context, value):
                return False
            
        return True
                    
    def names(self):
        return self.short_names + self.long_names
    
class GroupOptionType:
    Default = 1
    Exclusive = 2
    
class GroupOptionInfo(OptionInfo):
    options = None
    selected_option = None
    
    def __init__(self, var=None, type=GroupOptionType.Default):
        OptionInfo.__init__(self, var)
        self.options = []
        self.selected_option = None
        self.type = type
           
    def set_present(self, fromOption=None):
        self.present = True
        if isinstance(fromOption, OptionInfo):
            self.selected_option = fromOption
        if self.owner:
            self.owner.set_present(self)
                         
    def add_option(self, info):
        self.options.append(info)
        info.owner = self          
        
class SwitchOptionInfo(OptionInfo):
    def __init__(self, var):
        OptionInfo.__init__(self, var)
        self.value = False
        self.validators.append(UnexpectedValueValidator())
        
class ArgumentOptionInfo(OptionInfo):
    default = None
    
    def __init__(self, var, default=None):
        OptionInfo.__init__(self, var)
        self.default = default
        self.value = self.default
        
class MultiArgumentOptionInfo(OptionInfo):
    def __init__(self, var):
        OptionInfo.__init__(self, var)
        self.value = []
        
    def append_value(self, value):
        "@todo check min max"
        self.set_present()
        self.value.append(value)
        return True
    
class OptionRootInfo:
    options = None
    option_names = None
        
    def __init__(self):
        self.options = []
        self.option_names = {}
    
    def add_option_names(self, info):
        for n in info.names():
            self.option_names[n] = info
            
        if isinstance(info, GroupOptionInfo) and len(info.options):
            for o in info.options:
                self.add_option_names(o)

    def add_option(self, info):
        self.options.append(info)
        self.add_option_names(info)
                   
class SubcommandInfo(OptionRootInfo):
    name = ""
    aliases = None
    
    def __init__(self, name):
        OptionRootInfo.__init__(self)
        self.name = name
        self.aliases = []
    
class ProgramInfo(OptionRootInfo):
    subcommands = None
    subcommand_names = None
    values = None
        
    def __init__(self):
        OptionRootInfo.__init__(self)
        self.subcommands = []
        self.subcommand_names = {}
        self.values = []
         
    def add_subcommand_names(self, info):
        self.subcommand_names[info.name] = info
        for n in info.aliases:
            self.subcommand_names[n] = info
            
    def add_subcommand(self, info):
        self.subcommands.append(info)
        self.add_subcommand_names(info)    
 
