"""Value validators"""
import os
import math
from Base import Util

class Validator:
    def __init__(self, name):
        self.name = name
            
    def error(self, ctx, text):
        msg = ""
        if ctx.option:
            msg = msg + ctx.cli_option_name + ": "
        """if (len(self.name) > 0):
            msg = msg + "[" + self.name + "] "
             """
           
        msg = msg + text 
        ctx.error(msg)
            
class UnexpectedValueValidator(Validator):
    """Only accept null or empty string as valid value"""
    def validate(self, info, ctx, value):
        if (value == None) or (len(str(value)) == 0):
            return True
        self.error(ctx, "Unexpected value for option" + str(info))
        return False
        
    def __init__(self):
        Validator.__init__(self, "Unexpected value")
        
class RestrictedValueValidator(Validator):
    """Check the value against a list of values"""
    def __init__(self, values = ()):
        Validator.__init__(self, "Restricted value")
        self.__values = values
        
    def validate(self, info, ctx, value):
        for v in self.__values:
            if v == value:
                return True
        self.error(ctx, "Invalid argument value. Expect " + Util.value_list_display(self.__values, ", ", " or ", "'", "'"))
        return False
       
class NumberValidator(Validator):
    def __init__(self, minValue = "NaN", maxValue = "NaN"):
        self.min = float(minValue)
        self.max = float(maxValue)

    def validate(self, info, ctx, value):
        if (value == None):
            self.error(ctx, "Argument is not a number")
            return False
        
        try:
            v = float(value)
        except ValueError:
            self.error(ctx, "Argument is not a number")
            return False
                
        if not math.isnan(self.min) and (v < self.min):
            self.error(ctx, "Argument have to be superior or equal to " + str(self.min) + ". " + str(v) + " given")
            return False
        
        if not math.isnan(self.max) and (v > self.max):
            self.error(ctx, "Argument have to be inferior or equal to " + str(self.max) + ". " + str(v) + " given")
            return False
        
        return True
            
class PathValidator(Validator):
    def __init__(self, typeList, accessString):
        Validator.__init__(self, "Path type")
        self.types = typeList
        self.accessString = accessString
        
    def access(self, path):
        if len(self.accessString) > 0:
            for a in self.accessString:
                if a == "r" and not os.access(path, os.R_OK):
                    self.error(ctx, "Path is not readable")
                    return False
                if a == "w" and not os.access(path, os.W_OK):
                    self.error(ctx, "Path is not writable") 
                    return False
                if a == "x" and not os.access(path, os.X_OK):
                    self.error(ctx, "Path is not executable")
                    return False
        return True
        
    def validate(self, info, ctx, value):
        if not os.path.exists(value):
            self.error(ctx, "Path does not exists")
            return False
        if len(self.types) > 0:
            for t in self.types:
                if (t == "file") and os.path.isfile(value):
                    return self.access(value)
                if (t == "folder") and os.path.isdir(value):
                    return self.access(value)
                if (t == "symlink") and os.path.islink(value):
                    return self.access(value)
            
            self.error(ctx, "Invalid path type. Expect " + Util.value_list_display(self.types))
            return False
        else:
            return self.access(value)
    