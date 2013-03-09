# -*- coding: utf-8 -*-
""" Copyright © 2012 by Renaud Guillard """
""" Distributed under the terms of the MIT License, see LICENSE """

""" Program options and subcommand infos """

from Validators import *
from Base import *

class Documentation:
    def __init__(self):
        self.option_names = ""
        self.value_description = ""
        self.inline = ""
        self.abstract = ""
        self.details = ""
        
class OptionInfo:
    """Base class for all option infos"""        
    def __init__(self, var=None):
        self.varname = var
        self.documentation = None
        self.required = False
        self.value = None
        self.owner = None
        self.present = False
        self.required = False
        self.short_names = []
        self.long_names = []
        self.validators = []
        self.documentation = Documentation()
        
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

    def set_present(self, fromOption = None):
        self.present = True
        if self.owner:
            self.owner.set_present(self)

    def validate(self, context, value):
        validates = True
        for v in self.validators:
            if not v.validate(self, context, value):
                validates = False 
            
        return validates
      
    @property              
    def names(self):
        return self.short_names + self.long_names
    
    @property
    def default_name(self):
        if len(self.long_names) > 0:
            return self.long_names[0]
        else:
            return self.short_names[0]
    
class GroupOptionType:
    Default = 1
    Exclusive = 2
    
class GroupOptionInfo(OptionInfo):
    def __init__(self, var=None, type=GroupOptionType.Default):
        OptionInfo.__init__(self, var)
        self.options = []
        self.selected_option = None
        self.type = type
           
    def set_present(self, fromOption = None):
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
        self.min = 1
        self.max = -1
        
    def append_value(self, value):
        "@todo check min max"
        self.set_present()
        if self.max > 0 and (len(self.value) >= self.max):
                return False 
        self.value.append(value)
        return True
    
class OptionRootInfo:
           
    def __init__(self):
        self.options = []
        self.option_names = {}
        self.usage = { "inline": "", "abstract": "",  "details": ""}
        self.documentation = { "abstract": "", "details": ""}
    
    def add_option_names(self, info):
        for n in info.names:
            self.option_names[n] = info
            
        if isinstance(info, GroupOptionInfo) and len(info.options):
            for o in info.options:
                self.add_option_names(o)

    def add_option(self, info):
        self.options.append(info)
        self.add_option_names(info)
                       
class SubcommandInfo(OptionRootInfo):
    def __init__(self, name):
        OptionRootInfo.__init__(self)
        self.name = name
        self.aliases = []
    
class ProgramInfo(OptionRootInfo):
    def __init__(self, n):
        OptionRootInfo.__init__(self)
        self.name = n
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
 
