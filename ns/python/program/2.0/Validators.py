"""Value validators"""

class Validator:
    __name = ""
    
    def __init__(self, name):
        self.__name = name
    
    @property
    def name(self):
        return self.__name
            
class UnexpectedValueValidator(Validator):
    def validate(self, info, ctx, value):
        if (value == None) or (len(str(value)) == 0):
            return True
        ctx.error(self.name + ": Unexpected value for option" + str(info))
        return False
        
    def __init__(self):
        Validator.__init__(self, "Unexpected value")
        
class RestrictedValueValidator(Validator):
    def __init__(self, values = ()):
        Validator.__init__(self, "Restricted value")
        self.__values = values
        
    def validate(self, info, ctx, value):
        for v in self.__values:
            if v == value:
                return True
        ctx.error(self.name + " expect " + self.expected_string)
        return False
       
    @property
    def expected_string(self):
        c = len(self.__values)
        i = 0
        s = ""
        for v in self.__values:
            if i > 0:
                if i == (c - 1):
                    s = s + " or "
                else:
                    s = s + ", "
            s = s + "'" + str(v) + "'"
            i = i + 1
        return s