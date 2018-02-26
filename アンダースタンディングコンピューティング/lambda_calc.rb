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
end



# one = LCFunction.new(:p,LCFunction.new(:x,LCCall.new(LCVariable.new(:p),LCVariable.new(:x))))
# increment = LCFunction.new(:n,LCFunction.new(:p,LCFunction.new(:x,LCCall.new(LCCall.new(LCVariable.new(:n),LCVariable.new(:p)),LCVariable.new(:x)))))
# add = LCFunction.new(:m,LCFunction.new(:n,LCCall.new(LCCall.new(LCVariable.new(:n),increment),LCVariable.new(:m))))

# expression = LCVariable.new(:x)
# expression.replace(:x,LCFunction.new(:y,LCVariable.new(:y)))
# expression.replace(:z,LCFunction.new(:y,LCVariable.new(:y)))
# expression = LCCall.new(LCCall.new(LCCall.new(LCVariable.new(:a),LCVariable.new(:b)),LCVariable.new(:c)),LCVariable.new(:b))
# expression.replace(:a,LCVariable.new(:x))

# expression = LCFunction.new(:y,LCCall.new(LCVariable.new(:x),LCVariable.new(:y)))
# expression.replace(:x,LCVariable.new(:z))
# expression.replace(:y,LCVariable.new(:z))

# expression = LCCall.new(LCCall.new(LCVariable.new(:x),LCVariable.new(:y)),LCFunction.new(:y,LCCall.new(LCVariable.new(:y),LCVariable.new(:x))))
# expression.replace(:x,LCVariable.new(:z))
# expression.replace(:y,LCVariable.new(:z))

# function = LCFunction.new(:x,LCFunction.new(:y,LCCall.new(LCVariable.new(:x),LCVariable.new(:y))))
# argument = LCFunction.new(:z,LCVariable.new(:z))
# function.call(argument)

# expression = LCCall.new(LCCall.new(add,one),one)
# while expression.reducible?
#     puts expression
#     expression = expression.reduce
# end
# puts expression