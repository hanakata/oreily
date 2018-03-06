class SKISymbol < Struct.new(:name)
    def to_s
        name.to_s
    end

    def inspect
        to_s
    end

    def combinator
        self
    end

    def arguments
        []
    end

    def callable?(*arguments)
        false
    end

    def reducible?
        false
    end

    def as_a_function_of(name)
        if self.name == name
            I
        else
            SKICall.new(K,self)
        end
    end

    def to_iota
        self
    end
end

class SKICall < Struct.new(:left,:right)
    def to_s
        "#{left}[#{right}]"
    end

    def inspect
        to_s
    end

    def combinator
        left.combinator
    end

    def arguments
        left.arguments + [right]
    end

    def reducible?
        left.reducible? || right.reducible? || combinator.callable?(*arguments)
    end

    def reduce
        if left.reducible?
            SKICall.new(left.reduce,right)
        elsif right.reducible?
            SKICall.new(left,right.reduce)
        else
            combinator.call(*arguments)
        end
    end

    def as_a_function_of(name)
        left_function = left.as_a_function_of(name)
        right_function = right.as_a_function_of(name)

        SKICall.new(SKICall.new(S,left_function),right_function)
    end

    def to_iota
        SKICall.new(left.to_iota,right.to_iota)
    end
end

class SKICombinator < SKISymbol
    def as_a_function_of(name)
        SKICall.new(K,self)
    end
end

S,K,I = [:S, :K, :I].map { |name| SKICombinator.new(name) }

def S.call(a,b,c)
    SKICall.new(SKICall.new(a,c),SKICall.new(b,c))
end

def K.call(a,b)
    a
end

def I.call(a)
    a
end

def S.callable?(*arguments)
    arguments.length == 3
end

def K.callable?(*arguments)
    arguments.length == 2
end

def I.callable?(*arguments)
    arguments.length == 1
end

class LCVariable < Struct.new(:name)
    def to_s
        name.to_s
    end

    def inspect
        to_s
    end

    def replace(name,replacement)
        if self.name == name
            replacement
        else
            self
        end
    end

    def callable?
        false
    end

    def reducible?
        false
    end
    def to_ski
        SKISymbol.new(name)
    end
end

class LCCall < Struct.new(:left, :right)
    def to_s
        "#{left}[#{right}]"
    end

    def inspect
        to_s
    end

    def replace(name,replacement)
        LCCall.new(left.replace(name,replacement),right.replace(name,replacement))
    end

    def callable?
        false
    end

    def reducible?
        left.reducible? || right.reducible? || left.callable?
    end

    def reduce
        if left.reducible?
            LCCall.new(left.reduce,right)
        elsif right.reducible?
            LCCall.new(right.reduce,right)
        else
            left.call(right)
        end
    end

    def to_ski
        SKICall.new(left.to_ski,right.to_ski)
    end
end

class LCFunction < Struct.new(:parameter, :body)
    def to_s
        "-> #{parameter} { #{body} }"
    end

    def inspect
        to_s
    end

    def replace(name,replacement)
        if parameter == name
            self
        else
            LCFunction.new(parameter,body.replace(name,replacement))
        end
    end

    def call(argument)
        body.replace(parameter,argument)
    end

    def callable?
        false
    end

    def reducible?
        false
    end

    def to_ski
        body.to_ski.as_a_function_of(parameter)
    end
end

IOTA =SKICombinator.new('ι')
def IOTA.call(a)
    SKICall.new(SKICall.new(a,S),K)
end

def IOTA.callable?(*arguments)
    arguments.length == 1
end

def S.to_iota
    SKICall.new(IOTA,SKICall.new(IOTA,SKICall.new(IOTA,SKICall.new(IOTA,IOTA))))
end

def K.to_iota
    SKICall.new(IOTA,SKICall.new(IOTA,SKICall.new(IOTA,IOTA)))
end
def I.to_iota
    SKICall.new(IOTA,IOTA)
end

# x = SKISymbol.new(:x)
# expression = SKICall.new(SKICall.new(S,K),SKICall.new(I,x))

# y,z = SKISymbol.new(:y), SKISymbol.new(:z)
# S.call(x,y,z)

# expression = SKICall.new(SKICall.new(S,x),SKICall.new(S,y))
# expression
# combinator = expression.combinator
# arguments = expression.arguments
# combinator.call(*arguments)

# original = SKICall.new(SKICall.new(S,K),I)
# function = original.as_a_function_of(:x)
# function.reducible?
